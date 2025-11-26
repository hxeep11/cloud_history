#!/bin/bash

time=$(date '+%Y%m%d%H%M')

# 현재 브랜치 정확히 가져오기 (없으면 main)
branch=$(git branch --show-current)
[ -z "$branch" ] && branch="main"

# 원격 이름 (보통 origin)
remote=$(git remote -v | grep push | gawk 'NR==1{print $1}')

# ✅ 필수: GIT_TOKEN 환경변수 체크
if [ -z "$GIT_TOKEN" ]; then
    echo -e "\E[41;37mERROR: GIT_TOKEN is not set\E[0m"
    echo "👉 먼저 아래 명령 실행:"
    echo "export GIT_TOKEN=ghp_xxxxxxxxxxxxx"
    exit 1
fi

# ✅ origin URL 가져오기 (토큰 없는 깨끗한 URL인지 한 번만 수동으로 정리해두면 좋음)
origin_url=$(git remote get-url "$remote")

# ✅ 토큰 포함 URL 생성 (GitHub: x-access-token:<TOKEN>@ 형식)
auth_url=$(echo "$origin_url" | sed "s#https://#https://x-access-token:$GIT_TOKEN@#")

# ✅ 임시로 인증 URL 세팅
git remote set-url "$remote" "$auth_url"

# ✅ ADD
git add .
if [ $? -eq 0 ]; then
    echo -e "\E[42;37mADD : OK\E[0m"
else
    echo -e "\E[41;37mADD : FAIL\E[0m"
    # 원래 URL로 복구
    git remote set-url "$remote" "$origin_url"
    exit 1
fi

# ✅ COMMIT
git commit -m "$time"
if [ $? -eq 0 ]; then
    echo -e "\E[42;37mCOMMIT : OK\E[0m"
else
    echo -e "\E[41;37mCOMMIT : FAIL (no changes?)\E[0m"
    git remote set-url "$remote" "$origin_url"
    exit 1
fi

# ✅ PUSH
git push "$remote" "$branch" --force
if [ $? -eq 0 ]; then
    echo -e "\E[42;37mPUSH : OK\E[0m"
else
    echo -e "\E[41;37mPUSH : FAIL\E[0m"
    git remote set-url "$remote" "$origin_url"
    exit 1
fi

# ✅ 보안: push 끝나면 원래 URL로 복구
git remote set-url "$remote" "$origin_url"

echo -e "\E[44;37mDONE\E[0m"
