#!/bin/bash
dnf update -y
dnf install -y httpd
systemctl enable httpd
systemctl start httpd
cat <<'EOF' > /var/www/html/index.html
<h1>Web Server 1</h1>
<p>Served from eu-west-2a</p>
EOF
