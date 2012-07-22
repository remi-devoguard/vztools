#!/bin/bash
#
# Name: vztool
#
# Purpose: manage actions like update, upgrade, etc on all CT in a single command
#
# Note: Only for Debian ATM
#
          

# -- Retrieve all running CT's ID
CTIDS=($(vzlist -H -o veid | sed s/\ //g | tr '\n' ' '))

# -- checkRequirements : Verify that all needed tools are presents
checkRequirements()
{
   if [[ $EUID -ne 0 ]]; then
       echo "This script must be run as root ! -- Error" 1>&2
       exit 1
   fi

    tools=( vzlist sed grep  tr)
    for tool in ${tools[@]} 
    do
        if !(which $tool >/dev/null); then
            echo -e "\t${tool} not found -- Error"
            exit 1
        fi
    done
}


# -- updateCT : update containers
updateCT()
{
    for CTID in ${CTIDS[@]}
        do
            echo "- Updating ${CTID}"
	    vzctl exec ${CTID} apt-get update
        done
}

# -- upgradeCT : upgrade containers
upgradeCT()
{
     for CTID in ${CTIDS[@]}
        do  
            echo "- Upgrading ${CTID}"
            vzctl exec ${CTID} apt-get upgrade
            read -p "Press Enter to continue..."
        done
}

# -- memoryCT : memory usage containers
memoryCT()
{
     for CTID in ${CTIDS[@]}
        do  
            echo "-  Memory ${CTID}"
            vzctl exec ${CTID} free -m
        done
}

# -- versionCT : distribution version containers
versionCT()
{
     for CTID in ${CTIDS[@]}
        do  
            echo -n "- CTID ${CTID}:  "
            vzctl exec ${CTID} cat /etc/debian_version
        done
}

# -- Main 
echo '  Vztools v0.1'
echo '  ------------'
checkRequirements

case "$1" in
  update)
      echo "___Updating :___"
      updateCT
      ;;
  upgrade)
      echo "___Upgrading :___"
      upgradeCT
      ;;
  memory)
      echo "___Memory :___"
      memoryCT
      ;;
  version)
      echo "___Version :___"
      versionCT
      ;;
   *)
      echo "  OPTIONS: "
      echo "      update  --> Update"
      echo "      upgrade --> Upgrade"
      echo "      memory  --> Check memory"
      echo "      version --> Check distro version"  
esac

