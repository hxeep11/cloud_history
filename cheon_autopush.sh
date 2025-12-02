#!/usr/bin/env bash
set -e  # 에러 발생 시 즉시 종료

# === 0. 항상 git repo 루트에서 동작하도록 ===
REPO_ROOT=$(git rev-parse --show-toplevel 2>/dev/null || true)
if [ -z "$REPO_ROOT" ]; then
    echo -e "\E[41;37mERROR: This is not a git repository.\E[0m"
    exit 1
fi
cd "$REPO_ROOT" || exit 1

time=$(date '+%Y%m%d%H%M')

# 현재 브랜치 (기본 main)
branch=$(git branch --show-current 2>/dev/null || true)
[ -z "$branch" ] && branch="main"

# 변경 사항 있는지 먼저 확인 (레포 전체 기준)
if ! git status --porcelain | grep -q .; then
    echo -e "\E[43;30mNo changes in repo. Skip commit & push.\E[0m"
    exit 0
fi

# 원격 이름 (보통 origin)
remote=$(git remote -v | gawk '/push/ {print $1; exit}')
[ -z "$remote" ] && remote="origin"

# ✅ 필수: GIT_USER, GIT_TOKEN 환경변수 체크
if [ -z "${GIT_USER:-}" ] || [ -z "${GIT_TOKEN:-}" ]; then
    echo -e "\E[41;37mERROR: GIT_USER or GIT_TOKEN is not set\E[0m"
    echo "👉 먼저 아래 명령 실행:"
    echo "   export GIT_USER=your_github_id"
    echo "   export GIT_TOKEN=ghp_xxxxxxxxxxxxx"
    exit 1
fi

# ✅ origin URL 가져오기 (https가 아니라면 경고만)
origin_url=$(git remote get-url "$remote" 2>/dev/null || true)
if [ -z "$origin_url" ]; then
    echo -e "\E[41;37mERROR: Cannot get remote URL for '$remote'\E[0m"
    exit 1
fi

if ! echo "$origin_url" | grep -q '^https://'; then
    echo -e "\E[43;30mWARN: Remote URL is not HTTPS. Current: $origin_url\E[0m"
fi

# ================== ASKPASS 스크립트 생성 ==================
ASKPASS_SCRIPT="$(mktemp)"
cat > "$ASKPASS_SCRIPT" <<'EOF'
#!/usr/bin/env bash
case "$1" in
  *Username*) printf '%s\n' "${GIT_USER:-}" ;;
  *Password*) printf '%s\n' "${GIT_TOKEN:-}" ;;
  *) printf '\n' ;;
esac
EOF
chmod 700 "$ASKPASS_SCRIPT"

cleanup() {
    rm -f "$ASKPASS_SCRIPT"
}
trap cleanup EXIT
# =========================================================

# === ADD ===
if git add .; then
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

# === COMMIT ===
if git commit -m "$time"; then
    echo -e "\E[42;37mCOMMIT : OK\E[0m"
else
    echo -e "\E[41;37mCOMMIT : FAIL\E[0m"
    exit 1
fi

# === PUSH (환경변수 기반 인증) ===
echo "Remote : $remote ($origin_url)"
echo "Branch : $branch"

if GIT_ASKPASS="$ASKPASS_SCRIPT" \
   GIT_TERMINAL_PROMPT=0 \
   git -c credential.helper= push "$remote" "$branch"; then
    echo -e "\E[42;37mPUSH : OK\E[0m"
else
    echo -e "\E[41;37mPUSH : FAIL\E[0m"
    exit 1
fi

echo -e "\E[44;37mDONE\E[0m"
