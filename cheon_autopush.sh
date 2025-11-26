#!/bin/bash

time=$(date '+%Y%m%d%H%M')

# 현재 브랜치 정확히 가져오기 (없으면 main)
branch=$(git branch --show-current)
[ -z "$branch" ] && branch="main"

# 원격 이름 (보통 origin)
remote=$(git remote -v | grep push | gawk 'NR==1{print $1}')

echo "▶ BRANCH : $branch"
echo "▶ REMOTE : $remote"

# ADD
git add .
if [ $? -eq 0 ]; then
    echo -e "\E[42;37mADD : OK\E[0m"
else
    echo -e "\E[41;37mADD : FAIL\E[0m"
    exit 1
fi

# COMMIT
git commit -m "$time"
if [ $? -eq 0 ]; then
    echo -e "\E[42;37mCOMMIT : OK\E[0m"
else
    echo -e "\E[41;37mCOMMIT : FAIL (no changes?)\E[0m"
    exit 1
fi

# PUSH  (인증은 credential helper/캐시가 처리)
git push "$remote" "$branch"
if [ $? -eq 0 ]; then
    echo -e "\E[42;37mPUSH : OK\E[0m"
else
    echo -e "\E[41;37mPUSH : FAIL\E[0m"
    exit 1
fi

echo -e "\E[44;37mDONE\E[0m"
