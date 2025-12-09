- 스크립트 생성 시 아래 내용은 자동 수정됨
    
    ```bash
    vi /root/.bash_profile
    ```
    
    ```bash
    # 각 서버의 /ISC/sorc001/HER/ 밑 경로에 PROD 또는 TEST 또는 DR 디렉터리 생성
    # DCA로 배포의 경우
    # /root/.bash_profile에 내용이 추가됨
    ```
    
    ```bash
    ### Human Reduce Function
    . /ISC/sorc001/HER/HER_FUNCTION.sh
    ```
    

### 구성 디렉터리

```bash
/ISC/sorc001/HER/.
.
├── HER_CONFIG.sh
├── HER_FUNCTION.sh
├── HER_kill.sh
└── TEST or DR or PROD
```

### 생성 순서

1. 디렉토리 생성

```jsx
mkdir -p /ISC/sorc001/HER/. && cd /ISC/sorc001/HER
```

- 1. [HER_CONFIG.sh]
    
    ```bash
    cat << 'EOF' > /ISC/sorc001/HER/HER_config1.sh
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
    EOF
    
    ```
    
    ```jsx
    ./HER_FUNCTION.sh
    ```
    
- 2. [HER_kill.sh]
    
    ```bash
    cat << 'EOF' > /ISC/sorc001/HER/HER_kill.sh
    is_ubuntu=$(cat /etc/os-release | grep "^NAME"  | awk -F"\"" '{print $2}') | awk '{print $1}'
    
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
    EOF
    
    ```
    
- 3. [HER_FUNCTION.sh]
    
    ```bash
    cat << 'EOF' > /ISC/sorc001/HER/HER_FUNCTION.sh
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
    EOF
    
    ```
    

### 선택하여 mkdir 생성

```bash
touch -p /ISC/sorc001/HER/TEST
```

```bash
touch -p /ISC/sorc001/HER/PROD
```

```bash
touch -p /ISC/sorc001/HER/DR
```

### root로 로그인 시 적용화면

![Untitled](https://prod-files-secure.s3.us-west-2.amazonaws.com/7af3dbca-2e12-4938-b52a-6f8575c919cd/c5cfefb5-cd1c-4228-88e8-6d885e51f533/Untitled.png)

[5. history 형식 변경]