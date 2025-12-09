#!/bin/bash
# HER (Human Error Reduce) 기능 초기 설정 스크립트 - 최종 호환 버전

HER_DIR="/ISC/sorc001/HER"
ROOT_HOME=$(cat /etc/passwd|grep ^root |awk -F: '{print $6}')
ROOTSHELL=$(cat /etc/passwd|grep ^root |awk -F/ '{print $NF}')

# 1. dos2unix 설치 확인 및 설치
# 설치가 안 되어 있을 경우, 파일 생성 후 수동으로 \r 문자를 제거하기 위해 사용합니다.
if ! command -v dos2unix &> /dev/null; then
    if command -v apt &> /dev/null; then
        apt update && apt install -y dos2unix
    elif command -v yum &> /dev/null; then
        yum install -y dos2unix
    fi
fi

# 2. 디렉토리 생성
mkdir -p "$HER_DIR"

# 3. 서버 타입 지정 (예: TEST 서버로 지정)
# 필요에 따라 아래 줄을 'PROD' 또는 'DR'로 수정하여 사용하세요.
touch "$HER_DIR/TEST"

# 4. HER_kill.sh 파일 생성 (POSIX 호환)
cat << 'EOF_KILL' > "$HER_DIR/HER_kill.sh"
#!/bin/sh
is_ubuntu=$(cat /etc/os-release | grep "^NAME" | awk -F"\"" '{print $2}' | awk '{print $1}')

echo "Your current host is             : $(uname -n)"
echo "You are about to do the following: $(which kill) $@"
echo "$(ps -ef |head -1)"
echo "$(ps -ef |grep $2|grep -v grep)"
printf "Are you sure (enter HOSTNAME to proceed)? "
read sure
if [ "$sure" = "$(uname -n)" ]; then
    $(which kill) "$@"
else
    echo Cancelled.
fi
EOF_KILL

# 5. HER_FUNCTION.sh 파일 생성 (POSIX 호환: 'function' 키워드 제거)
cat << 'EOF_FUNC' > "$HER_DIR/HER_FUNCTION.sh"
#!/bin/sh
########Human Error Reduce Function  #######################################
#
#  COPYRIGHT 2015 LG CNS. ALL RIGHTS RESERVED.
#
################################################################

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

# 6. 권한 설정
chmod 700 "$HER_DIR/HER_FUNCTION.sh"
chmod 700 "$HER_DIR/HER_kill.sh"

# 7. **DOS 문자 제거 (핵심 수정)**
# 파일 생성 후 dos2unix를 실행하여 줄 바꿈 문자를 Linux 포맷으로 통일합니다.
if command -v dos2unix &> /dev/null; then
    dos2unix "$HER_DIR/HER_FUNCTION.sh"
    dos2unix "$HER_DIR/HER_kill.sh"
else
    # dos2unix가 없는 경우 sed로 \r 문자 수동 제거 (덜 안정적일 수 있음)
    sed -i 's/\r$//' "$HER_DIR/HER_FUNCTION.sh"
    sed -i 's/\r$//' "$HER_DIR/HER_kill.sh"
fi

# 8. .bash_profile 또는 .profile에 등록
if [ "${ROOTSHELL}" = "bash" ]; then
    R_PROFILE="${ROOT_HOME}/.bash_profile"
else
    R_PROFILE="${ROOT_HOME}/.profile"
fi

echo "" >> "${R_PROFILE}"
echo "### Human Error Reduce Function ">> "${R_PROFILE}"
echo ". ${HER_DIR}/HER_FUNCTION.sh" >> "${R_PROFILE}"

# 9. 설정 적용 메시지 출력
echo "HER setup complete. Please re-login to see changes applied."