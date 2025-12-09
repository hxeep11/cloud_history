#!/bin/bash
# APT 통신을 위한 포트 80/443 아웃바운드 허용 및 iptables 저장

echo "--- Configuring IPTables for APT Communication (80/443 Outbound) ---"

# 1. 아웃바운드 포트 80 (HTTP) 허용
/sbin/iptables -A OUTPUT -p tcp --dport 80 -m state --state NEW,ESTABLISHED -j ACCEPT
echo "IPTables: Allowed outbound TCP 80."

# 2. 아웃바운드 포트 443 (HTTPS) 허용
/sbin/iptables -A OUTPUT -p tcp --dport 443 -m state --state NEW,ESTABLISHED -j ACCEPT
echo "IPTables: Allowed outbound TCP 443."

# 3. 이미 수립된 연결 및 관련 연결 허용 (필수)
/sbin/iptables -A OUTPUT -m state --state ESTABLISHED,RELATED -j ACCEPT

# 4. 규칙 영구 저장을 위한 시도 (운영체제에 따라 다름)

# Debian/Ubuntu 계열 (iptables-persistent 또는 netfilter-persistent 사용 시)
if command -v netfilter-persistent &> /dev/null; then
    echo "Saving rules using netfilter-persistent..."
    netfilter-persistent save
elif command -v apt-get &> /dev/null && [ -f "/etc/init.d/netfilter-persistent" ]; then
    echo "Saving rules using service netfilter-persistent..."
    /usr/sbin/service netfilter-persistent save
# CentOS/RHEL 계열 (iptables 서비스 사용 시)
elif command -v yum &> /dev/null && [ -f "/etc/init.d/iptables" ]; then
    echo "Saving rules using service iptables..."
    /usr/sbin/service iptables save
fi

echo "IPTables configuration complete."

# 5. APT 업데이트 시도 (설정 적용 확인)
/usr/bin/apt update