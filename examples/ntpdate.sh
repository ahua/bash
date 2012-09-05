#!/usr/bin/env bash

cat > /etc/cron.daily/ntpdate <<EOF
#!/usr/bin/env bash
ntpdate ntp.ubuntu.com

EOF

chmod 755 /etc/cron.daily/ntpdate

