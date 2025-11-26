#!/bin/bash

# 자동 Git Push 스크립트
# Son WSL 환경 기준 최적화 버전

# 현재 경로 출력
echo "📂 Current directory: $(pwd)"

# 변경 상태 확인
echo "🔍 Checking git status..."
git status

# 모든 변경 add
echo "➕ Adding changes..."
git add .

# 커밋 메시지: 날짜/시간 자동 추가
COMMIT_MSG="Auto commit ($(date '+%Y-%m-%d %H:%M:%S'))"
echo "📝 Commit message: $COMMIT_MSG"

git commit -m "$COMMIT_MSG"

# 현재 브랜치 자동 감지
BRANCH=$(git branch --show-current)

# 브랜치가 없으면 main으로 만들기
if [ -z "$BRANCH" ]; then
    echo "⚠️ No branch detected. Switching to main..."
    git branch -M main
    BRANCH="main"
fi

# push 실행
echo "🚀 Pushing to origin/$BRANCH ..."
git push -u origin "$BRANCH"

echo "✅ Done."
