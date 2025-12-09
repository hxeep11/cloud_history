#!/bin/bash
# HER (Human Error Reduce) 기능 해제 및 디렉토리 삭제 스크립트

HER_DIR="/ISC/sorc001/HER"
ROOT_HOME=$(cat /etc/passwd|grep ^root |awk -F: '{print $6}')
ROOTSHELL=$(cat /etc/passwd|grep ^root |awk -F/ '{print $NF}')

# 1. 대상 Profile 파일 경로 확인
case ${ROOTSHELL} in
 bash) R_PROFILE=${ROOT_HOME}/.bash_profile ;;
 *)    R_PROFILE=${ROOT_HOME}/.profile ;;
esac

echo "--- HER Cleanup Script Starting ---"
echo "Target Profile: ${R_PROFILE}"
echo "Target Directory: ${HER_DIR}"

# 2. Profile 파일에서 HER 설정 내용 제거
if [ -f "${R_PROFILE}" ]; then
    echo "Attempting to remove HER configuration from ${R_PROFILE}..."

    # HER 시작 마커와 끝 마커 사이의 줄을 찾아서 삭제합니다.
    # 안전을 위해 HER_FUNCTION.sh을 sourcing하는 줄만 삭제합니다.

    # "### Human Error Reduce Function " 줄과 ". /ISC/sorc001/HER/HER_FUNCTION.sh" 줄을 제거
    sed -i '/### Human Error Reduce Function /d' "${R_PROFILE}"
    sed -i '\/ISC\/sorc001\/HER\/HER_FUNCTION.sh/d' "${R_PROFILE}"

    # 혹시 모를 공백 라인을 정리 (선택 사항)
    # sed -i '/^$/N;/^\n$/D' "${R_PROFILE}"

    echo "HER configuration removed from ${R_PROFILE}."
else
    echo "Profile file ${R_PROFILE} not found. Skipping profile cleanup."
fi

# 3. HER 디렉토리 삭제
if [ -d "${HER_DIR}" ]; then
    echo "Deleting HER directory ${HER_DIR}..."
    rm -rf "${HER_DIR}"
    echo "Directory deleted successfully."
else
    echo "HER directory ${HER_DIR} not found. Skipping directory cleanup."
fi

# 4. 현재 쉘에 적용된 기능 해제 (선택적)
echo "Removing shell functions and aliases (current session)..."
# alias는 재정의할 수 없으므로 새 쉘을 시작해야 완전 해제됩니다.
# rm, umount, mv, shutdown, init, reboot, halt 함수만 제거
unset -f rm umount mv shutdown init reboot halt

echo ""
echo "--- HER Cleanup Complete ---"
echo "**Please start a new shell session (re-login or execute 'bash') to ensure all functions and aliases are fully reset.**"