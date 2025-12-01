#!/usr/bin/env bash

# === 0. 항상 git repo 루트에서 동작하도록 ===
REPO_ROOT=$(git rev-parse --show-toplevel 2>/dev/null)
if [ -z "$REPO_ROOT" ]; then
    echo -e "\E[41;37mERROR: This is not a git repository.\E[0m"
    exit 1
fi
cd "$REPO_ROOT" || exit 1

time=$(date '+%Y%m%d%H%M')

# 현재 브랜치 (기본 main)
branch=$(git branch --show-current)
[ -z "$branch" ] && branch="main"

# 변경 사항 있는지 먼저 확인 (레포 전체 기준)
# --porcelain: 스크립트용 포맷 / 아무 것도 없으면 빈 출력
if ! git status --porcelain | grep -q .; then
    echo -e "\E[43;30mNo changes in repo. Skip commit & push.\E[0m"
    exit 0
fi

# 원격 이름 (보통 origin)
remote=$(git remote -v | grep push | gawk 'NR==1{print $1}')
[ -z "$remote" ] && remote="origin"

# ✅ 필수: GIT_TOKEN 환경변수 체크
if [ -z "$GIT_TOKEN" ]; then
    echo -e "\E[41;37mERROR: GIT_TOKEN is not set\E[0m"
    echo "👉 먼저 아래 명령 실행:"
    echo "export GIT_TOKEN=ghp_xxxxxxxxxxxxx"
    exit 1
fi

# (옵션) 토큰 형식 대충 검사 - 공백/한글 들어가면 막기


# ✅ origin URL 가져오기
origin_url=$(git remote get-url "$remote" 2>/dev/null)
if [ -z "$origin_url" ]; then
    echo -e "\E[41;37mERROR: Cannot get remote URL for '$remote'\E[0m"
    exit 1
fi

# ✅ 토큰 포함 URL 생성 (https 전용)
# 예: https://github.com/user/repo.git
# → https://TOKEN@github.com/user/repo.git
auth_url=$(echo "$origin_url" | sed "s#https://#https://$GIT_TOKEN@#")

# === ADD ===
git add .
if [ $? -eq 0 ]; then
    echo -e "\E[42;37mADD : OK\E[0m"
else
    echo -e "\E[41;37mADD : FAIL\E[0m"
    exit 1
fi

# ADD 후에도 실제 staged 변경이 없는지 한 번 더 체크
if git diff --cached --quiet; then
    echo -e "\E[43;30mNo staged changes after git add. Skip commit & push.\E[0m"
    exit 0
fi

# ✅ 임시로 인증 URL 세팅
git remote set-url "$remote" "$auth_url"

# === COMMIT ===
git commit -m "$time"
if [ $? -eq 0 ]; then
    echo -e "\E[42;37mCOMMIT : OK\E[0m"
else
    echo -e "\E[41;37mCOMMIT : FAIL\E[0m"
    # 보안: URL 원복
    git remote set-url "$remote" "$origin_url"
    exit 1
fi

# === PUSH ===
git push "$remote" "$branch" --force
if [ $? -eq 0 ]; then
    echo -e "\E[42;37mPUSH : OK\E[0m"
else
    echo -e "\E[41;37mPUSH : FAIL\E[0m"
    git remote set-url "$remote" "$origin_url"
    exit 1
fi

# ✅ push 끝나면 원래 URL로 복구 (토큰 잔존 방지)
git remote set-url "$remote" "$origin_url"

echo -e "\E[44;37mDONE\E[0m"
