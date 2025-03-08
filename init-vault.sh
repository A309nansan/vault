#!/bin/bash

# 이 파일은 Jenkins에서 Execute Shell에 작성한 script 내용입니다.

# 명령어 실패 시 스크립트 종료
set -euo pipefail

# 로그 출력 함수
log() {
  echo "[$(date +'%Y-%m-%d %H:%M:%S')] $*"
}

# 에러 발생 시 로그와 함께 종료하는 함수
error() {
  log "Error on line $1"
  exit 1
}

trap 'error $LINENO' ERR

log "스크립트 실행 시작."

# docker network 생성
if docker network ls --format '{{.Name}}' | grep -q '^nansan-network$'; then
  log "Docker network named 'nansan-network' is already existed."
else
  log "Docker network named 'nansan-network' is creating..."
  docker network create --driver bridge nansan-network
fi

# 기존 vault 이미지를 삭제하고 새로 빌드
log "vault image remove and build."
docker rmi vault:latest || true
docker build -t vault:latest .

# Docker Compose로 서비스 실행
log "Execute vault..."
docker run -d \
  --name vault \
  --restart unless-stopped \
  -e VAULT_ADDR=http://vault:8200 \
  --cap-add IPC_LOCK \
  -p 8200:8200 \
  -v /var/vault/file:/vault/file \
  -v /var/vault/logs:/vault/logs \
  --network nansan-network \
  vault:latest

echo "작업이 완료되었습니다."
