chmod 700 ./HER_FUNCTION.sh
FUNC_DIR=`pwd`
ROOT_HOME=`cat /etc/passwd|grep ^root |awk -F: '{print $6}'`
ROOTSHELL=`cat /etc/passwd|grep ^root |awk -F/ '{print $NF}'`

 case ${ROOTSHELL} in
 bash) R_PROFILE=${ROOT_HOME}/.bash_profile ;;
 *)    R_PROFILE=${ROOT_HOME}/.profile ;;

 esac

echo >> ${R_PROFILE}
echo "### Human Error Reduce Function ">> ${R_PROFILE}
echo ". ${FUNC_DIR}/HER_FUNCTION.sh" >> ${R_PROFILE}