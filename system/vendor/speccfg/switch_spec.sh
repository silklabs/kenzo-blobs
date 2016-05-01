#!/system/bin/sh

# Copyright (c) 2013-2015 Qualcomm Technologies, Inc.
# All Rights Reserved.
# Confidential and Proprietary - Qualcomm Technologies, Inc.

export PATH=/system/bin:$PATH

strBakForReplace=".bakforspec"
strExcludeFiles="exclude.list"
strExcludeFolder="exclude"
strForLink=".link"
currentSpec=""
SourceFolder=""
DestFolder=""
BasePath=""
LocalFlag=""
mode=""

createFolder()
{
  local dirPath=$1
  if [ -d "$dirPath" ]
  then
    echo "Exist $dirPath"
  else
    createFolder "${dirPath%/*}"
    echo "mkdir and chmod $dirPath"
    mkdir "$dirPath"
    chmod 755 "$dirPath"
  fi
}

installFunc()
{
  local srcPath=$1
  local dstPath=$2
  local dstDir="${dstPath%/*}"
  createFolder $dstDir
  echo "installFunc $srcPath $dstPath $dstDir"
  if [ "${dstPath%$strForLink}" != "$dstPath" ]
  then
    dstPath="${dstPath%$strForLink}"
  fi
  if [ "${srcPath%$strForLink}" != "$srcPath" ]
  then
    if [ "${dstPath#${BasePath}/system/}" != "${dstPath}" ]
    then
      if [ -f "${srcPath%$strForLink}" ] || [ -h "${srcPath%$strForLink}" ]
      then
        if [ -f "$dstPath" ]
        then
          rm "$dstPath"
        fi
        mv "${srcPath%$strForLink}" $dstPath
        chmod 644 "$dstPath"
      fi
    else
      cp -p "${srcPath%$strForLink}" $dstPath
      chmod 644 "$dstPath"
    fi
  elif [ -h "$srcPath$strForLink" ]
  then
    installFunc "$srcPath$strForLink" $dstPath
  else
    if [ -f "$dstPath" ]
    then
      if [ -f "$dstPath$strBakForReplace$currentSpec" ]
      then
        rm "$dstPath$strBakForReplace$currentSpec"
      fi
      mv $dstPath $dstPath$strBakForReplace$currentSpec
    fi
    ln -s ${dstPath#$BasePath} "$srcPath$strForLink"
    installFunc "$srcPath$strForLink" $dstPath
  fi
}

uninstallFunc()
{
  local srcPath=$1
  local dstPath=$2
  echo "uninstallFunc $srcPath $dstPath"
  if [ "${dstPath%$strForLink}" != "$dstPath" ]
  then
    dstPath="${dstPath%$strForLink}"
  fi
  if [ "${srcPath%$strForLink}" != "$srcPath" ]
  then
    if [ "${dstPath#${BasePath}/system/}" != "${dstPath}" ]
    then
      if [ -f "$dstPath" ] || [ -h "$dstPath" ]
      then
        if [ -f "${srcPath%$strForLink}" ] || [ -h "${srcPath%$strForLink}" ]
        then
          rm $dstPath
        else
          if [ -f "${srcPath%$strForLink}" ]
          then
            rm "${srcPath%$strForLink}"
          fi
          mv $dstPath "${srcPath%$strForLink}"
          chmod 644 "${srcPath%$strForLink}"
        fi
      fi
    else
      rm $dstPath
    fi
    if [ -f "$dstPath$strBakForReplace$currentSpec" ]
    then
      if [ -f "$dstPath" ]
      then
        rm $dstPath
      fi
      mv $dstPath$strBakForReplace$currentSpec $dstPath
    fi
    rm $srcPath
  elif [ -h "$srcPath$strForLink" ]
  then
    uninstallFunc "$srcPath$strForLink" $dstPath
  else
    echo "Finish install"
  fi
}

installFolderFunc()
{
  local srcPath=$1
  local dstPath=$2
  for item in `ls -a $srcPath`
  do
    echo "find item=$item"
    if [ "$item" = "." ]
    then
      echo "current folder"
    else
      if [ "$item" = ".." ]
      then
        echo "upfolder"
      elif [ "$item" = ".preloadspec" ] || [ "$item" = "$strExcludeFiles" ]
      then
        echo "specflag"
      else
        if [ -f "$srcPath/$item" ]
        then
          installFunc "$srcPath/${item}" "$dstPath/${item}"
        elif [ -h "$srcPath/$item" ]
        then
          installFunc "$srcPath/${item}" "$dstPath/${item}"
        else
          if [ -d "$srcPath/$item" ]
          then
            installFolderFunc "$srcPath/${item}" "$dstPath/${item}"
          fi
        fi
      fi
    fi
  done
}

uninstallFolderFunc()
{
  local srcPath=$1
  local dstPath=$2
  for item in `ls -a $srcPath`
  do
    echo "uitem=$item"
    if [ "$item" = "." ]
    then
      echo "current folder"
    else
      if [ "$item" = ".." ]
      then
        echo "upfolder"
      elif [ "$item" = ".preloadspec" ] || [ "$item" = "$strExcludeFiles" ]
      then
        echo "specflag"
      else
        if [ -f "$srcPath/$item" ]
        then
          uninstallFunc "$srcPath/${item}" "$dstPath/${item}"
        elif [ -h "$srcPath/$item" ]
        then
          uninstallFunc "$srcPath/${item}" "$dstPath/${item}"
        else
          if [ -d "$srcPath/$item" ]
          then
            uninstallFolderFunc "$srcPath/${item}" "$dstPath/${item}"
          fi
        fi
      fi
    fi
  done
}

excludeFilesFunc()
{
  local srcPath=$1
  if [ -f "$srcPath" ]
  then
    echo "exclude the files in current spec"
    while read line
    do
      if [ -f "$DestFolder/$line" ]
      then
        local dstPath="$SourceFolder/$strExcludeFolder/$line"
        local dstDir="${dstPath%/*}"
        createFolder $dstDir
        if [ "${line#system/}" != "${line}" ]
        then
          mv $DestFolder/$line $dstPath
        else
          cp -p $DestFolder/$line $dstPath
        fi
      fi
    done < "$srcPath"
  fi
}

includeFilesFunc()
{
  local srcPath=$1
  if [ -f "$srcPath" ]
  then
    echo "restore the files excluded in previous spec"
    while read line
    do
      if [ -f "$SourceFolder/$strExcludeFolder/$line" ]
      then
        local dstPath="$DestFolder/$line"
        if [ "${line#system/}" != "${line}" ]
        then
          mv "$SourceFolder/$strExcludeFolder/$line" $dstPath
        else
          cp -p "$SourceFolder/$strExcludeFolder/$line" $dstPath
        fi
      fi
    done < "$srcPath"
  fi
}

getCurrentCarrier()
{
  local specPath=$1
  currentSpec=""
  if [ -f "$specPath" ]
  then
    . $specPath
    while read line
    do
      currentSpec=${line#*=}
    done < $specPath
  fi
}

makeFlagFolder()
{
  if [ -d "$DestFolder/data/switch_spec" ]
  then
    echo "no need to create flag"
  else
    mkdir "$DestFolder/data/switch_spec"
    chmod 770 "$DestFolder/data/switch_spec"
    if [ "$mode" != "compiling" ]
    then
      chown system:system "$DestFolder/data/switch_spec"
    fi
  fi
}

changeDirMode()
{
  local strCurPath=$1
  chmod 755 $strCurPath
  for item in `ls -a $strCurPath/`
  do
    if [ "$item" = "." ] || [ "$item" = ".." ]
    then
      echo ".."
    elif [ -f "$strCurPath/$item" ]
    then
      chmod 644 "$strCurPath/$item"
    elif [ -d "$strCurPath/$item" ]
    then
      changeDirMode "$strCurPath/$item"
    else
      echo "who is $strCurPath/$item"
    fi
  done
}

recoveryDataPartition()
{
  getCurrentCarrier "$DestFolder/system/vendor/speccfg/spec"
  installFolderFunc "$DestFolder/system/vendor/Default/data" "$DestFolder/data"
  if [ "$currentSpec" = "" ] || [  "$currentSpec" = "Default" ]
  then
    echo "Not find spec or default spec"
  else
    # Recovery the data partition for each spec
    local specPath=$1
    x=0
    while read line
    do
      if [ "$x" -ge "1" ]
      then
        installFolderFunc "$DestFolder/system/vendor/${line#*=}/data" "$DestFolder/data"
      fi
      let "x+=1"
    done < $specPath
  fi
}

prepareActionData()
{
  # Mark if user has operated switching by CarrierConfigure app
  local iSSwitchByAction="false"

  # Copy spec folder from $SwitchData/cache/system/vendor to /cache/temp
  if [ -f "$SwitchApp/cache/action" ]
  then
    mkdir -p "/cache/temp"
    local x=0
    while read line
    do
      if [ "$x" -ge "1" ]
      then
        local specItem="${line#*=}"
        if [ -d "$SwitchData/cache/system/vendor/$specItem" ]
        then
          cp -rf "$SwitchData/cache/system/vendor/$specItem" "/cache/temp/"
        fi
      fi
      let "x+=1"
    done < "$SwitchApp/cache/action"
    # Copy action spec list to $SwitchActionFlag
    cp -rf "$SwitchApp/cache/action" "$SwitchActionFlag"
    iSSwitchByAction="true"
  fi

  echo $iSSwitchByAction
}

getNewSpecList()
{
  local specList

  if [ -f "$SwitchActionFlag" ]
  then
    cp -rf "$SwitchActionFlag" "$SwitchFlag"
  fi

  if [ -f "$SwitchFlag" ]
  then
    local strNewSpec=""
    local newPackCount=0
    . "$SwitchFlag"
    if [ "$newPackCount" -ge "1" ]
    then
      local x=0
      while read line
      do
        if [ "$x" -ge "1" ]
        then
          local specItem="${line#*=}"
          specList[$x-1]=$specItem
        fi
        let "x+=1"
      done < $SwitchFlag
    else
      specList[0]=$strNewSpec
    fi
  fi
  echo ${specList[*]}
}

uninstallOldSpecList()
{
  local specPath=$1
  local specList
  if [ -f "$specPath" ]
  then
    local x=0
    while read line
    do
      if [ "$x" -ge "1" ]
      then
        specList[$x-1]="${line#*=}"
      fi
      let "x+=1"
    done < "$specPath"
  fi

  x="${#specList[@]}"
  while [ "$x" -gt "0" ]
  do
    let "x-=1"
    if [ "$x" -ge "1" ]
    then
      currentSpec=${specList[$x-1]}
    else
      currentSpec="Default"
    fi
    if [ "${specList[$x]}" != "Default" ]
    then
      uninstallFolderFunc "$SourceFolder/${specList[$x]}" "$DestFolder"
      includeFilesFunc "$SourceFolder/${specList[$x]}/$strExcludeFiles"
    fi
  done
  rm -rf $SourceFolder/$strExcludeFolder/*

  # Reinstall Default pack
  mv -f $DestFolder/system/build.prop.bakforspecDefault $DestFolder/system/build.prop
  uninstallFolderFunc "$SourceFolder/Default" "$DestFolder"
  if [ "$mode" = "running" ]
  then
    wipe data
  fi
  installFolderFunc "$SourceFolder/Default" "$DestFolder"
  echo "packCount=1" > $specPath
  echo "strSpec1=Default" >> $specPath
}

overrideRoProperty()
{
  local srcprop=$1
  local dstprop=$2
  local tempfile=${dstprop%/*}"/temp.prop"

  echo "Override ro.* property from $srcprop to $dstprop ..."

  while IFS=$'\n' read -r srcline
  do
    if [ "${srcline:0:1}" != "#" ] && [ "${srcline#*=}" != "${srcline}" ]
    then
      local flag=0
      while IFS=$'\n' read -r dstline
      do
        if [ "${srcline%%.*}" = "ro" ] && [ "${srcline%%[ =]*}" = "${dstline%%[ =]*}" ]
        then
          echo "Override $srcline ..."
          echo -E $srcline >> $tempfile
        else
          echo -E $dstline >> $tempfile
        fi
      done < $dstprop
      mv -f $tempfile $dstprop
    fi
  done < $srcprop

  chmod 644 $dstprop
}

installNewSpecList()
{
  local specList
  specList=(`echo "$@"`)

  if [ "${#specList[@]}" -eq "1" ] && [ "${specList[0]}" = "Default" ]
  then
    echo "Default spec already have been installed, do nothing here!"
  else
    # Check if the list is ready
    local x=0
    local y=0
    local newList
    if [ "${#specList[@]}" -ge "1" ]
    then
      while [ "$x" -lt "${#specList[@]}" ]
      do
        if [ "${specList[$x]}" != "" ]
        then
          # Copy spec folder from /cache/temp to /system/vendor
          if [ -d "/cache/temp/${specList[$x]}" ]
          then
            if [ -d "$SourceFolder/${specList[$x]}" ]
            then
              rm -rf "$SourceFolder/${specList[$x]}"
            fi
            cp -rf "/cache/temp/${specList[$x]}" "$SourceFolder/${specList[$x]}"
          fi
          if [ -d "$SourceFolder/${specList[$x]}" ]
          then
            newList[$y]=${specList[$x]}
            let "y+=1"
          fi
        fi
        let "x+=1"
      done

      # remove /cache/temp
      if [ -d "/cache/temp" ]
      then
        rm -rf "/cache/temp"
      fi
    fi

    # Install spec as list
    if [ "${#newList[@]}" -ge "1" ]
    then
      # Backup build.prop for Default
      cp -f $DestFolder/system/build.prop $DestFolder/system/build.prop.bakforspecDefault
      x=0
      echo "packCount=${#newList[@]}" > $LocalFlag
      while [ "$x" -lt "${#newList[@]}" ]
      do
        excludeFilesFunc "$SourceFolder/${newList[$x]}/$strExcludeFiles"
        changeDirMode "$SourceFolder/${newList[$x]}"
        installFolderFunc "$SourceFolder/${newList[$x]}" "$DestFolder"
        overrideRoProperty "$DestFolder/system/vendor/vendor.prop" "$DestFolder/system/build.prop"
        let "x+=1"
        currentSpec="${newList[$x-1]}"
        echo "strSpec$x=$currentSpec" >> $LocalFlag
      done
    fi
  fi
}

cleanOldSpecs()
{
  local specList
  specList=(`echo "$@"`)

  # When in step 1 of switching mode,
  # should ensure that action specs are not cleared.
  if [ "$mode" = "switching" ]
  then
     local actionSpecList
     actionSpecList=(`getNewSpecList`)
     specList+=("${actionSpecList[@]}")
  fi

  for item in `ls -a $SourceFolder`
  do
    if [ "$item" = "Default" ]
    then
      echo "Default spec, no need remove"
    elif [ "$item" = ".." ] || [ "$item" = "." ]
    then
      echo "Current path"
    elif [ -f "$SourceFolder/$item/.preloadspec" ]
    then
      echo "find $item"
      local x=0
      local flag=0
      while [ "$x" -lt "${#specList[@]}" ]
      do
        if [ "$item" = "${specList[$x]}" ]
        then
          flag=1
          break
        fi
        let "x+=1"
      done

      if [ "$flag" -eq "0" ]
      then
        rm -rf "$SourceFolder/$item"
      fi
    fi
  done
}

initSwitchingMode()
{
  if [ -f "$SwitchModeFlag" ]
  then
    . "$SwitchModeFlag"
    echo "Before mode = $mode"
  fi

  if [ "$mode" = "" ]
  then
    if [ "$DestFolder" != "" ]
    then
      # compiling mode means that switch carrier when compiling the source code
      # in Android.mk.
      mode="compiling"
    else
      if [ "$(prepareActionData)" = "true" ]
      then
        # switching mode means that switch carrier through CarrierConfigure App or
        # SIM Trigger, which includes two steps:
        # 1. switch to Default and clean the old specs
        # 2. switch to the new spec list
        mode="switching"
      else
        # running mode means that run switch_spec.sh to switch carrier
        # manully through cmd on DUT.
        mode="running"
      fi
    fi
    echo "mode=$mode" > "$SwitchModeFlag"
  fi
}

######Main function start######

if [ "$#" -eq "0" ]
then
  if [ -d "$DestFolder/data/switch_spec" ]
  then
    echo "check ok"
  else
    recoveryDataPartition "$DestFolder/system/vendor/speccfg/spec"
  fi
else
  SourceFolder="$1"
  DestFolder="$2"
  BasePath="$3"
  LocalFlag="$4"
  echo "SourceFolder=$SourceFolder DestFolder=$DestFolder BasePath=$BasePath LocalFlag=$LocalFlag"
  SwitchApp="$DestFolder/data/data/com.qualcomm.qti.carrierconfigure"
  SwitchData="$DestFolder/data/data/com.qualcomm.qti.loadcarrier"
  SwitchModeFlag="$DestFolder/system/vendor/speccfg/mode"
  SwitchActionFlag="$DestFolder/system/vendor/speccfg/action"
  SwitchFlag="$DestFolder/system/vendor/speccfg/spec.new"
  RmFlag="0"

  initSwitchingMode

  echo "Current mode = $mode"

  # Set the RmFlag for cleaning preset specs
  if [ -f "$SwitchApp/cache/rmflag" ]
  then
    RmFlag="1"
  fi

  if [ -d "$SourceFolder/$strExcludeFolder" ]
  then
    echo "no need to create excludefolder"
  else
    mkdir "$SourceFolder/$strExcludeFolder"
    chmod 770 "$SourceFolder/$strExcludeFolder"
  fi

  if [ "$#" -gt "4" ]
  then
    newSpecList="$5"
    echo "switchToSpec=${newSpecList[0]}"
    if [ "$#" -gt "5" ]
    then
      RmFlag="$6"
    fi
  else
    newSpecList=(`getNewSpecList`)

    # Clean all flag files
    if [ -f "$SwitchActionFlag" ]
    then
      rm -rf "$SwitchActionFlag"
    fi
    if [ -f "$SwitchFlag" ]
    then
      rm -rf "$SwitchFlag"
    fi
    if [ -f "$SwitchModeFlag" ]
    then
      rm -rf "$SwitchModeFlag"
    fi
  fi

  getCurrentCarrier "$LocalFlag"

  if [ "${#currentSpec}" -eq "0" ]
  then
    echo "No find spec, but need to install Default"
    installFolderFunc "$SourceFolder/Default" "$DestFolder"
    currentSpec="Default"
  fi

  uninstallOldSpecList "$LocalFlag"

  if [ "$RmFlag" -eq "1" ]
  then
    cleanOldSpecs "${newSpecList[*]}"
  fi

  if [ "${#newSpecList[@]}" -ge "1" ]
  then
    installNewSpecList "${newSpecList[*]}"
  fi

  chmod 644 "$LocalFlag"
  chmod 755 "$DestFolder/system/vendor/speccfg"
fi

makeFlagFolder

######Main function end######
