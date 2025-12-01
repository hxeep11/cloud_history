#!/bin/bash

time=$(date '+%Y%m%d%H%M')

branch=$(git branch --show-current)
[ -z "$branch" ] && branch="main"

remote=$(git remote -v | grep push | gawk 'NR==1{print $1}')

if [ -z "$GIT_TOKEN" ]; then
    echo -e "\E[41;37mERROR: GIT_TOKEN is not set\E[0m"
    echo "👉 먼저 아래 명령 실행:"
    echo "export GIT_TOKEN=ghp_xxxxxxxxxxxxx"
    exit 1
fi

origin_url=$(git remote get-url origin)
auth_url=$(echo "$origin_url" | sed "s#https://#https://$GIT_TOKEN@#")

# ADD
git add .
if [ $? -eq 0 ]; then
    echo -e "\E[42;37mADD : OK\E[0m"
else
    echo -e "\E[41;37mADD : FAIL\E[0m"
    exit 1
fi

# ✅ 변경 사항 있는지 먼저 체크 (staging 기준)
if git diff --cached --quiet; then
    echo -e "\E[43;30mNo changes to commit. Skip commit & push.\E[0m"
    # 혹시 이전에 auth_url 셋팅할 수도 있으니, 안전하게 원복
    git remote set-url origin "$origin_url"
    echo -e "\E[44;37mDONE (no-op)\E[0m"
    exit 0
fi

# 여기부터는 진짜 커밋할 게 있는 경우만 실행

# origin을 auth_url로 설정
git remote set-url origin "$auth_url"

# COMMIT
git commit -m "$time"
if [ $? -eq 0 ]; then
    echo -e "\E[42;37mCOMMIT : OK\E[0m"
else
    echo -e "\E[41;37mCOMMIT : FAIL\E[0m"
    git remote set-url origin "$origin_url"
    exit 1
fi

# PUSH
git push origin "$branch" --force
if [ $? -eq 0 ]; then
    echo -e "\E[42;37mPUSH : OK\E[0m"
else
    echo -e "\E[41;37mPUSH : FAIL\E[0m"
    git remote set-url origin "$origin_url"
    exit 1
fi

git remote set-url origin "$origin_url"
echo -e "\E[44;37mDONE\E[0m"
