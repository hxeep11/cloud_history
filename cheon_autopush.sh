#!/bin/bash

time=$(date '+%Y%m%d%H%M')

# 현재 브랜치 정확히 가져오기 (main 고정)
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

# ✅ origin URL 가져오기
origin_url=$(git remote get-url origin)

# ✅ 토큰 포함 URL 생성 (https 전용)
# 예: https://github.com/user/repo.git
# → https://TOKEN@github.com/user/repo.git
auth_url=$(echo "$origin_url" | sed "s#https://#https://$GIT_TOKEN@#")

# ✅ 임시로 인증 URL 세팅
git remote set-url origin "$auth_url"

# ✅ ADD
git add .
if [ $? -eq 0 ]; then
    echo -e "\E[42;37mADD : OK\E[0m"
else
    echo -e "\E[41;37mADD : FAIL\E[0m"
    exit 1
fi

# ✅ COMMIT
git commit -m "$time"
if [ $? -eq 0 ]; then
    echo -e "\E[42;37mCOMMIT : OK\E[0m"
else
    echo -e "\E[41;37mCOMMIT : FAIL\E[0m"
    # 커밋이 없을 때도 push는 의미 없으니 종료
    exit 1
fi

# ✅ PUSH
git push origin "$branch" --force
if [ $? -eq 0 ]; then
    echo -e "\E[42;37mPUSH : OK\E[0m"
else
    echo -e "\E[41;37mPUSH : FAIL\E[0m"
    exit 1
fi

# ✅ 보안: push 끝나면 원래 URL로 복구 (토큰 잔존 방지)
git remote set-url origin "$origin_url"

echo -e "\E[44;37mDONE\E[0m"
