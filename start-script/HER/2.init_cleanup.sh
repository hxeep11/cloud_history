#!/bin/sh

#### Select Server Type : PROD/DR/TEST ####
TYPE=`ls -al /ISC/sorc001/HER |egrep "PROD|DR|TEST"|awk '{print $NF}'`

#### PS config ####
case ${TYPE} in
 PROD) PS1="$(printf '\033[0m')""$(printf '\033[1;33m')"[P]`uname -n`::`whoami`::'$PWD'" ;;
 DR)   PS1="$(printf '\033[0m')""$(printf '\033[1;34m')"[DR]`uname -n`::`whoami`::'$PWD'" ;;
 TEST) PS1="$(printf '\033[0m')""$(printf '\033[1;35m')"[T]`uname -n`::`whoami`::'$PWD'" ;;
esac

is_ubuntu=$(cat /etc/os-release  | grep "^NAME"  | awk -F"\"" '{print $2}' | awk '{print $1}')

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
         ;;
 *)
        alias kill='/ISC/sorc001/HER/HER_kill.sh'
        ;;
esac

#### make function (POSIX standard: function keyword removed) ####
rm () {
         echo ""
     echo "Your current host is             : $(uname -n)"
     echo "Your current directory is        : $PWD"
     echo "You are about to do the following: $(which rm) $@"
     echo "Are you sure (enter HOSTNAME to proceed)?"
     read sure
     if [ "$sure" = "$(uname -n)" ]; then
         $(which rm) "$@"
     else
         echo Cancelled.
     fi
}
umount () {
         echo ""
     echo "Your current host is             : $(uname -n)"
     echo "You are about to do the following: $(which umount) $@"
     echo "Are you sure (enter HOSTNAME to proceed)?"
     read sure
     if [ "$sure" = "$(uname -n)" ]; then
         $(which umount) "$@"
     else
         echo Cancelled.
     fi
}
mv () {
         echo ""
     echo "Your current host is             : $(uname -n)"
     echo "You are about to do the following: $(which mv) $@"
     echo "Are you sure (enter HOSTNAME to proceed)?"
     read sure
     if [ "$sure" = "$(uname -n)" ]; then
         $(which mv) "$@"
     else
         echo Cancelled.
     fi
}
shutdown () {
         echo ""
     echo "Your current host is             : $(uname -n)"
     echo "You are about to do the following: $(which shutdown) $@"
     echo "Are you sure (enter HOSTNAME to proceed)?"
     read sure
     if [ "$sure" = "$(uname -n)" ]; then
         $(which shutdown) "$@"
     else
         echo Cancelled.
     fi
}
init () {
         echo ""
     echo "Your current host is             : $(uname -n)"
     echo "You are about to do the following: $(which init) $@"
     echo "Are you sure (enter HOSTNAME to proceed)?"
     read sure
     if [ "$sure" = "$(uname -n)" ]; then
         $(which init) "$@"
     else
         echo Cancelled.
     fi
}
reboot () {
         echo ""
     echo "Your current host is             : $(uname -n)"
     echo "You are about to do the following: $(which reboot)"
     echo "Are you sure (enter HOSTNAME to proceed)?"
     read sure
     if [ "$sure" = "$(uname -n)" ]; then
         $(which reboot)
     else
         echo Cancelled.
     fi
}
halt () {
         echo ""
     echo "Your current host is             : $(uname -n)"
     echo "You are about to do the following: $(which halt)"
     echo "Are you sure (enter HOSTNAME to proceed)?"
     read sure
     if [ "$sure" = "$(uname -n)" ]; then
         $(which halt)
     else
         echo Cancelled.
     fi
}
EOF_FUNC

    # 5-5. 권한 설정
    chmod 700 "$HER_DIR/HER_FUNCTION.sh"
    chmod 700 "$HER_DIR/HER_kill.sh"

    # 5-6. .bash_profile 또는 .profile에 등록
    if [ "${ROOTSHELL}" = "bash" ]; then
        R_PROFILE="${ROOT_HOME}/.bash_profile"
    else
        R_PROFILE="${ROOT_HOME}/.profile"
    fi

    # 기존 HER 등록 부분은 Init Script에 포함된 Alias 설정보다 아래에 위치하므로, 
    # Alias 설정 전에 프로필 파일 경로를 다시 한 번 확인합니다.
    
    if grep -q "HER_FUNCTION.sh" "${R_PROFILE}"; then
        echo "Existing HER registration found. Cleaning up old registration..."
        sed -i '/### Human Error Reduce Function /d' "${R_PROFILE}"
        sed -i '\/ISC\/sorc001\/HER\/HER_FUNCTION.sh/d' "${R_PROFILE}"
    fi

    echo "" >> "${R_PROFILE}"
    echo "### Human Error Reduce Function ">> "${R_PROFILE}"
    echo ". ${HER_DIR}/HER_FUNCTION.sh" >> "${R_PROFILE}"
fi

echo "HER installation complete."
# ----------------------------------------------------
## 6. Alias 및 Kubernetes 환경 변수 설정 (기존 기능)
echo "--- Setting up shell aliases ---"

# ROOT 계정의 프로필 파일 경로 확인 (5.HER 섹션에서 R_PROFILE 변수가 설정됨)

# Alias 추가
echo "" >> "${R_PROFILE}"
echo "### Custom Aliases and K8s Setup" >> "${R_PROFILE}"
echo "alias k='kubectl'" >> "${R_PROFILE}"
echo "alias l='ls -l'" >> "${R_PROFILE}"
echo "alias ks='kubectl get services'" >> "${R_PROFILE}"
echo "alias kp='kubectl get pods -o wide'" >> "${R_PROFILE}"
echo "" >> "${R_PROFILE}"

echo "Aliases added to ${R_PROFILE}."

echo "--- System Initialization Completed ---"