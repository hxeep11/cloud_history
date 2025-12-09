########Human Error Reduce Function  #######################################
#
#  COPYRIGHT 2015 LG CNS. ALL RIGHTS RESERVED.
#  Version :1.1
#
#  2023.10.21  add "--skip-function" option for "alias which"
#
#  This script set config Terminal Color devided by Server Type.
#  Production Server is RED. #  DR Server is BLUE. #  Test Server is normal.
#  And make function that check hostname before run high risk commands like rm or shutdown.
#
################################################################

#### Select Server Type : PROD/DR/TEST ####
TYPE=`ls -al /ISC/sorc001/HER |egrep "PROD|DR|TEST"|awk '{print $NF}'`

#### PS config ####
case ${TYPE} in
 PROD) PS1="$(printf '\033[0m')""$(printf '\033[1;33m')"[P]`uname -n`::`whoami`::'$PWD'" #""$(printf '\033[0;44m ')" ;;
 DR)   PS1="$(printf '\033[0m')""$(printf '\033[1;34m')"[DR]`uname -n`::`whoami`::'$PWD'" #""$(printf '\033[0;44m ')" ;;
 TEST) PS1="$(printf '\033[0m')""$(printf '\033[1;35m')"[T]`uname -n`::`whoami`::'$PWD'" #""$(printf '\033[0m ')" ;;
esac

is_ubuntu=$(cat /etc/os-release  | grep "^NAME"  | awk -F"\"" '{print $2}'| awk '{print $1}')

#### set alias ####
alias rm='rm -i'

case $(uname) in
 Linux)
         alias ls='ls --color=never'
         alias ll='ls -l --color=never'
         alias egrep='egrep --color=never'
         alias fgrep='fgrep --color=never'
         alias grep='grep --color=never'
         alias l.='ls -d .* --color= never'
         alias kill='/ISC/sorc001/HER/HER_kill.sh'
         if [ $is_ubuntu != "Ubuntu" ]
         then
                alias which='which --tty-only --skip-alias --skip-function --show-dot --show-tilde'
         fi
         ;;
 *)
        alias kill='/ISC/sorc001/HER/HER_kill.sh'
        ;;
esac

#### make function ####
 function rm {
         echo ""
     echo "Your current host is             : $(uname -n)"
     echo "Your current directory is        : $PWD"
     echo "You are about to do the following: $(which rm) $@ "
     echo "Are you sure (enter HOSTNAME to proceed)?"
     read sure
     if [ $sure = "$(uname -n)" ] ; then
         $(which rm) "$@"
     else
         echo Cancelled.
     fi
 }
 function umount {
         echo ""
     echo "Your current host is             : $(uname -n)"
     echo "You are about to do the following: $(which umount) $@ "
     echo "Are you sure (enter HOSTNAME to proceed)?"
     read sure
     if [ $sure = "$(uname -n)" ] ; then
         $(which umount) "$@"
     else
         echo Cancelled.
     fi
 }
 function mv {
         echo ""
     echo "Your current host is             : $(uname -n)"
     echo "You are about to do the following: $(which mv) $@ "
     echo "Are you sure (enter HOSTNAME to proceed)?"
     read sure
     if [ $sure = "$(uname -n)" ] ; then
         $(which mv) "$@"
     else
         echo Cancelled.
     fi
 }
 function shutdown {
         echo ""
     echo "Your current host is             : $(uname -n)"
     echo "You are about to do the following: $(which shutdown) $@ "
     echo "Are you sure (enter HOSTNAME to proceed)?"
     read sure
     if [ $sure = "$(uname -n)" ] ; then
         $(which shutdown) "$@"
     else
         echo Cancelled.
     fi
 }
 function init {
         echo ""
     echo "Your current host is             : $(uname -n)"
     echo "You are about to do the following: $(which init) $@ "
     echo "Are you sure (enter HOSTNAME to proceed)?"
     read sure
     if [ $sure = "$(uname -n)" ] ; then
         $(which init) "$@"
     else
         echo Cancelled.
     fi
 }
 function reboot {
         echo ""
     echo "Your current host is             : $(uname -n)"
     echo "You are about to do the following: $(which reboot) "
     echo "Are you sure (enter HOSTNAME to proceed)?"
     read sure
     if [ $sure = "$(uname -n)" ] ; then
         $(which reboot)
     else
         echo Cancelled.
     fi
 }
 function halt {
         echo ""
     echo "Your current host is             : $(uname -n)"
     echo "You are about to do the following: $(which halt) "
     echo "Are you sure (enter HOSTNAME to proceed)?"
     read sure
     if [ $sure = "$(uname -n)" ] ; then
         $(which halt)
     else
         echo Cancelled.
     fi
 }