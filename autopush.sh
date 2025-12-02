#!/bin/bash

set -e  # 에러 나면 바로 종료

echo "================ Git Autopush (env token) ================"

# 0. 환경변수 체크
if [ -z "$GIT_USER" ] || [ -z "$GIT_TOKEN" ]; then
  echo "❌ GIT_USER 또는 GIT_TOKEN 환경변수가 설정되지 않았습니다."
  echo "   예) export GIT_USER=\"github_id\""
  echo "       export GIT_TOKEN=\"ghp_xxx...\""
  exit 1
fi

# 1. askpass용 임시 스크립트 생성 (token은 여기서만 사용)
ASKPASS_SCRIPT="$(mktemp)"
cat > "$ASKPASS_SCRIPT" <<'EOF'
#!/bin/sh
case "$1" in
  *Username*) echo "$GIT_USER" ;;
  *Password*) echo "$GIT_TOKEN" ;;
  *) echo "" ;;
esac
EOF
chmod 700 "$ASKPASS_SCRIPT"

# 스크립트 끝날 때 자동 삭제
cleanup() {
  rm -f "$ASKPASS_SCRIPT"
}
trap cleanup EXIT

# 2. 현재 경로/상태 확인
echo "📂 Current directory: $(pwd)"

echo "🔍 Checking git status..."
git status

# 3. 변경 add
echo "➕ Adding changes..."
git add .

# 4. 커밋 메시지 자동 생성
COMMIT_MSG="Auto commit ($(date '+%Y-%m-%d %H:%M:%S'))"
echo "📝 Commit message: $COMMIT_MSG"

# 스테이지된 변경이 없으면 커밋/푸시 스킵
if git diff --cached --quiet; then
  echo "⚠️ Staged changes 없음. 커밋과 푸시는 생략합니다."
else
  git commit -m "$COMMIT_MSG"
fi

# 5. 현재 브랜치 자동 감지
BRANCH=$(git branch --show-current)

# 브랜치가 없으면 main으로 만들기
if [ -z "$BRANCH" ]; then
    echo "⚠️ No branch detected. Switching to main..."
    git branch -M main
    BRANCH="main"
fi

# 6. remote 확인
REMOTE_URL=$(git remote get-url origin 2>/dev/null || echo "(no origin)")
echo "🌐 Remote origin: $REMOTE_URL"

# 7. push 실행 (여기서만 env 기반 인증 사용)
echo "🚀 Pushing to origin/$BRANCH ..."

GIT_ASKPASS="$ASKPASS_SCRIPT" \
GIT_TERMINAL_PROMPT=0 \
git -c credential.helper= push -u origin "$BRANCH"

echo "✅ Done."
echo "=========================================================="
