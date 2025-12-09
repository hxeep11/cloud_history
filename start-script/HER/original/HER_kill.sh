is_ubuntu=$(cat /etc/os-release  | grep "^NAME"  | awk -F"\"" '{print $2}') | awk '{print $1}'

if [ $is_ubuntu != "Ubuntu" ]
then
        alias which='which --tty-only --skip-alias --skip-function --show-dot --show-tilde'
fi

echo "Your current host is             : $(uname -n)"
echo "You are about to do the following: $(which kill) $@ "
echo "$(ps -ef |head -1)"
echo "$(ps -ef |grep $2|grep -v grep)"
printf "Are you sure (enter HOSTNAME to proceed)? "
read sure
if [ $sure = "$(uname -n)" ] ; then
    $(which kill) "$@"
else
    echo Cancelled.
fi