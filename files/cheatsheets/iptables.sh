# List all rules
iptables -L -v -n    # -v for verbose, -n to avoid DNS lookups

# ipv4-mapped ipv6 addresses
ip6tables -A INPUT -s ::ffff:192.168.2.4/128 -j ACCEPT # 128 is exact

# Netmasking examples:

- `/8`: Targets the entire `192.x.x.x` network (16 million+ addresses).
- `/16`: Targets the `192.168.x.x` network (65,536 addresses).
- `/24`: Targets the `192.168.0.x` subnet (256 addresses).
- `/30`: Targets only `192.168.0.0` through `192.168.0.3` (4 addresses).


# 192.168.0.0/16 - Allow all hosts
iptables -A INPUT -s 192.168.0.0/16 -j ACCEPT

# 192.168.0.0/24 - Allow 256 hosts
# 192.168.0.0/25 - Allow 128 hosts
# 192.168.0.0/26 - Allow 64 hosts
# 192.168.0.0/27 - Allow 32 hosts
# 192.168.0.0/28 - Allow 16 hosts
# 192.168.0.0/29 - Allow 8 hosts
# 192.168.0.0/30 - Allow 4 hosts


# Flush all rules
iptables -F

# Default policies (DROP all incoming, ALLOW outgoing)
iptables -P INPUT DROP
iptables -P OUTPUT ACCEPT
iptables -P FORWARD DROP

# Allow incoming SSH (port 22)
iptables -A INPUT -p tcp --dport 22 -j ACCEPT

# Allow incoming HTTP and HTTPS
iptables -A INPUT -p tcp -m multiport --dports 80,443 -j ACCEPT

# Allow loopback traffic
iptables -A INPUT -i lo -j ACCEPT

# Drop invalid packets
iptables -A INPUT -m conntrack --ctstate INVALID -j DROP

# Allow established/related connections
iptables -A INPUT -m conntrack --ctstate ESTABLISHED,RELATED -j ACCEPT

# Log and drop everything else (replace LOG_DROP with your custom chain name if needed)
iptables -N LOG_DROP
iptables -A LOG_DROP -m limit --limit 5/min -j LOG --log-prefix "IPTables-Dropped: " --log-level 4
iptables -A LOG_DROP -j DROP
iptables -A INPUT -j LOG_DROP

