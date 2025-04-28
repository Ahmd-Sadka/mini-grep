# README

## Q1: Custom Command (`mygrep.sh`)

### Description
Mini version of `grep` supporting case-insensitive search, line numbers, and invert-match.

### Usage
```bash
./mygrep.sh [OPTIONS] <search_string> <file>
```

### Options
- `-n`  Show line numbers for matches
- `-v`  Invert match (show non-matching lines)
- `--help`  Display usage information (bonus)

### Requirements
1. Script must be executable: `chmod +x mygrep.sh`.
2. Handle invalid input (missing search string or file) with an error message.
3. Output style must mimic GNU `grep`.

### Hands‑On Validation
Test with `testfile.txt` containing:
```
Hello world
This is a test
another test line
HELLO AGAIN
Don't match this line
Testing one two three
```
Include screenshots for:
```bash
./mygrep.sh hello testfile.txt
./mygrep.sh -n hello testfile.txt
./mygrep.sh -vn hello testfile.txt
./mygrep.sh -v testfile.txt   # should warn about missing search string
```

### 🧠 Reflective Section
1. **Argument handling breakdown**: parse options via `getopts` in a loop, setting flags `opt_n` and `opt_v`. After options, positional `$1` is search string, `$2` is filename; we validate both.
2. **Future regex or -i/-c/-l support**: extend `getopts` to capture those flags, then pass the corresponding flags (`-E`, `-i`, `-c`, `-l`) into our matching function or switch to `grep` for complex patterns. The script structure would modularize match logic into functions.
then pass the corresponding flags (`-E`, `-i`, `-c`, `-l`) into our matching function or switch to `grep` for complex patterns.

3. **Hardest part**: Implementing invert-match (`-v`) while preserving line numbering also colorful output like `grep`. careful branching in the line-reading loop to avoid off-by-one errors.

---

## Q2: DNS/Network Troubleshooting (`internal.example.com`)

### Tasks
1. **Verify DNS Resolution**: Compare lookups from `/etc/resolv.conf` vs. `8.8.8.8`.
2. **Diagnose Service Reachability**: Confirm port 80/443 on resolved IP via `ss`, `curl`, or `telnet`.
3. **Trace the Issue – List All Possible Causes**
   - Local stub resolver misconfigured
   - DNS cache stale on client or resolver
   - Missing/incorrect A record in DNS zone
   - Firewall blocking HTTP(S) ports
   - Service bound only to localhost
   - Network route/gateway misconfiguration
   - Conflicting `/etc/hosts` entry
   - SELinux/AppArmor blocking connections
4. **Propose & Apply Fixes**

| Cause | Confirmation | Fix Command(s) |
|-------|--------------|----------------|
| Stub resolver wrong upstream | `resolvectl status` shows wrong DNS | `sudo resolvectl dns eth0 10.0.0.2`; `sudo resolvectl flush-caches` |
| Stale cache | `resolvectl statistics` high cache hits | `sudo resolvectl flush-caches` |
| Bad A record | `dig @dns-server internal.example.com` → NXDOMAIN | Update DNS zone file; `rndc reload` |
| Firewall drop | `sudo iptables -L -n | grep 80` shows DROP | `sudo iptables -I INPUT -p tcp --dport 80 -j ACCEPT`; `iptables-save` |
| Binding to localhost | `ss -tunlp | grep 127.0.0.1:80` | Edit web server config to `listen 0.0.0.0:80`; `systemctl restart nginx` |
| Missing route | `traceroute IP` fails early | `sudo ip route add 10.10.20.0/24 via 10.10.1.1 dev eth0` |
| Hosts conflict | `grep internal.example.com /etc/hosts` | Remove conflicting line |
| SELinux denial | `ausearch -m avc -ts recent` | `sudo setsebool -P httpd_can_network_connect on` |

### Bonus
- **/etc/hosts override**: `echo "10.10.20.30 internal.example.com" | sudo tee -a /etc/hosts`
- **Persist DNS via systemd-resolved**: create `/etc/systemd/resolved.conf.d/custom.conf` with `[Resolve]\nDNS=10.0.0.2 10.0.0.3\nDomains=internal.example.com`, then `systemctl restart systemd-resolved`.
- **Persist via NetworkManager**: `nmcli con mod \"Wired\" ipv4.dns \"10.0.0.2 10.0.0.3\" ipv4.ignore-auto-dns yes && nmcli con up \"Wired\"`
