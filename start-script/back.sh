#!/usr/bin/env bash
#
# fs_maintenance.sh
# Ubuntu 파일 시스템 정리 + 백업 + 리포트 스크립트
# root 권한 필요

set -euo pipefail

########################################
# 설정 영역 (필요하면 여기만 수정)
########################################

# 백업이 저장될 루트 디렉토리
BACKUP_ROOT="/var/backups/fs_maintenance"

# 백업 대상 디렉토리 목록 (공백으로 구분)
BACKUP_TARGETS=(
  "/etc"
  "/home"
)

# 보존할 백업 개수 (디렉토리별)
MAX_BACKUPS=7

# 디스크 리포트 파일 위치
REPORT_FILE="/var/log/fs_maintenance_report.log"

########################################
# 공통 함수
########################################

log() {
  local msg="$1"
  echo "$(date '+%Y-%m-%d %H:%M:%S') [fs_maintenance] $msg"
}

require_root() {
  if [[ "$(id -u)" -ne 0 ]]; then
    echo "이 스크립트는 root 권한으로 실행해야 합니다." >&2
    exit 1
  fi
}

########################################
# APT 캐시 및 패키지 정리
########################################

cleanup_apt() {
  log "APT 캐시 및 불필요 패키지 정리 시작"
  apt-get update -y >/dev/null 2>&1 || true
  apt-get autoremove -y >/dev/null 2>&1 || true
  apt-get autoclean -y >/dev/null 2>&1 || true
  log "APT 정리 완료"
}

########################################
# 저널/로그 정리
########################################

cleanup_logs() {
  log "journal 로그 정리 시작"
  # 최근 7일치만 유지 (필요시 조정)
  journalctl --vacuum-time=7d >/dev/null 2>&1 || true
  log "journal 로그 정리 완료"

  log "일반 로그 파일 용량 정리 (/var/log)"
  find /var/log -type f -name "*.log" -size +50M -print0 | while IFS= read -r -d '' file; do
    log "로그 파일 축소: $file"
    > "$file" || true
  done
  log "일반 로그 정리 완료"
}

########################################
# 디스크 사용량 리포트
########################################

report_disk_usage() {
  log "디스크 사용량 리포트 생성"

  {
    echo "===== $(date '+%Y-%m-%d %H:%M:%S') 디스크 사용량 리포트 ====="
    df -h
    echo
    echo "----- 상위 10개 용량 점유 디렉토리 (/home) -----"
    du -xh /home 2>/dev/null | sort -rh | head -n 10
    echo
    echo "----- 상위 10개 용량 점유 디렉토리 (/var) -----"
    du -xh /var 2>/dev/null | sort -rh | head -n 10
    echo "===================================================="
    echo
  } >> "$REPORT_FILE"

  log "디스크 리포트 갱신: $REPORT_FILE"
}

########################################
# 백업(압축) 및 오래된 백업 정리
########################################

rotate_backups() {
  local target="$1"
  local target_name
  target_name="$(echo "$target" | tr '/' '_' | sed 's/^_//')"

  local target_backup_dir="${BACKUP_ROOT}/${target_name}"
  mkdir -p "$target_backup_dir"

  # 백업 파일 리스트
  mapfile -t backups < <(ls -1t "$target_backup_dir" 2>/dev/null || true)

  if (( ${#backups[@]} > MAX_BACKUPS )); then
    local to_delete_count=$(( ${#backups[@]} - MAX_BACKUPS ))

    for (( i=${#backups[@]}-1; i>=0 && to_delete_count>0; i-- )); do
      local old_backup="${target_backup_dir}/${backups[$i]}"
      log "오래된 백업 삭제: $old_backup"
      rm -f -- "$old_backup" || true
      ((to_delete_count--))
    done
  fi
}

backup_directories() {
  log "백업 시작"
  mkdir -p "$BACKUP_ROOT"

  local timestamp
  timestamp="$(date '+%Y%m%d_%H%M%S')"

  for target in "${BACKUP_TARGETS[@]}"; do
    if [[ ! -d "$target" ]]; then
      log "백업 대상 디렉토리 없음 (건너뜀): $target"
      continue
    fi

    local target_name
    target_name="$(echo "$target" | tr '/' '_' | sed 's/^_//')"
    local target_backup_dir="${BACKUP_ROOT}/${target_name}"
    mkdir -p "$target_backup_dir"

    local backup_file="${target_backup_dir}/${target_name}_${timestamp}.tar.gz"

    log "백업 중: $target → $backup_file"
    tar -czpf "$backup_file" "$target" >/dev/null 2>&1

    log "백업 완료: $backup_file"

    # 오래된 백업 정리
    rotate_backups "$target"
  done

  log "백업 작업 전체 완료"
}

########################################
# 메인
########################################

main() {
  require_root

  log "=== 파일 시스템 유지보수 시작 ==="

  # 1) 패키지/캐시 정리
  cleanup_apt

  # 2) 로그 정리
  cleanup_logs

  # 3) 디스크 리포트
  report_disk_usage

  # 4) 주요 디렉토리 백업
  backup_directories

  log "=== 파일 시스템 유지보수 완료 ==="
}

main "$@"
