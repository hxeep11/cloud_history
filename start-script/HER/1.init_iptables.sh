#!/bin/bash
# APT/K8s 설정, 필수 패키지 설치, Alias 및 HER 기능 설치 스크립트

echo "--- System Initialization and Security Configuration Start ---"

# 필수 변수 설정 (HER 기능 포함 모든 섹션에서 사용)
ROOT_HOME=$(cat /etc/passwd|grep ^root |awk -F: '{print $6}')
ROOTSHELL=$(cat /etc/passwd|grep ^root |awk -F/ '{print $NF}')
HER_DIR="/ISC/sorc001/HER"

# ----------------------------------------------------
## 1. APT 통신 및 기본 보안 설정 (기존 기능)
echo "--- Configuring IPTables for APT (80/443 Outbound) ---"

# 1. 아웃바운드 포트 80 (HTTP) 허용
/sbin/iptables -A OUTPUT -p tcp --dport 80 -m state --state NEW,ESTABLISHED -j ACCEPT
echo "IPTables: Allowed outbound TCP 80."

# 2. 아웃바운드 포트 443 (HTTPS) 허용
/sbin/iptables -A OUTPUT -p tcp --dport 443 -m state --state NEW,ESTABLISHED -j ACCEPT
echo "IPTables: Allowed outbound TCP 443."

# 3. 이미 수립된 연결 및 관련 연결 허용 (필수)
/sbin/iptables -A OUTPUT -m state --state ESTABLISHED,RELATED -j ACCEPT

# ----------------------------------------------------
## 2. Kubernetes 통신 포트 아웃바운드 허용 (기존 기능)
echo "--- Configuring IPTables for Kubernetes Traffic (Outbound) ---"

# Kubernetes API Server (Control Plane) 포트 허용 (보통 6443)
/sbin/iptables -A OUTPUT -p tcp --dport 6443 -m state --state NEW,ESTABLISHED -j ACCEPT
echo "IPTables: Allowed outbound TCP 6443 (K8s API Server)."

# Kubelet API 포트 허용 (보통 10250)
/sbin/iptables -A OUTPUT -p tcp --dport 10250 -m state --state NEW,ESTABLISHED -j ACCEPT
echo "IPTables: Allowed outbound TCP 10250 (Kubelet)."

# Kube-scheduler (10251) 및 Kube-controller-manager (10252) 포트 허용 (Control Plane 통신)
/sbin/iptables -A OUTPUT -p tcp --match multiport --dports 10251,10252 -m state --state NEW,ESTABLISHED -j ACCEPT
echo "IPTables: Allowed outbound TCP 10251, 10252 (K8s Control Plane)."

# ----------------------------------------------------
## 3. IPTables 규칙 영구 저장
echo "--- Saving IPTables Rules ---"

# Debian/Ubuntu 계열 (iptables-persistent 또는 netfilter-persistent 사용 시)
if command -v netfilter-persistent &> /dev/null; then
    netfilter-persistent save
elif command -v apt-get &> /dev/null && [ -f "/etc/init.d/netfilter-persistent" ]; then
    /usr/sbin/service netfilter-persistent save
# CentOS/RHEL 계열 (iptables 서비스 사용 시)
elif command -v yum &> /dev/null && [ -f "/etc/init.d/iptables" ]; then
    /usr/sbin/service iptables save
fi

echo "IPTables configuration complete."

# ----------------------------------------------------
## 4. 필수 패키지 설치 (vim)
echo "--- Installing essential packages (vim) ---"

if command -v apt-get &> /dev/null; then
    # Ubuntu/Debian
    apt-get update
    apt-get install -y vim
elif command -v yum &> /dev/null; then
    # CentOS/RHEL
    yum install -y vim
fi

echo "vim installation complete."