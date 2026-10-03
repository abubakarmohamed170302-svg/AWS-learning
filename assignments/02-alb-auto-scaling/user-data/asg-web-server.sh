#!/bin/bash
dnf update -y
dnf install -y httpd
systemctl enable httpd
systemctl start httpd
HOST=$(hostname)
cat <<EOF > /var/www/html/index.html
<h1>CoderCo Auto Scaling Web Server</h1>
<p>Hostname: ${HOST}</p>
EOF
