#!/bin/bash
dnf update -y
dnf install -y httpd
systemctl enable httpd
systemctl start httpd

cat <<'EOF' > /var/www/html/index.html
<!DOCTYPE html>
<html>
<head><title>CoderCo AWS Project</title></head>
<body>
  <h1>CoderCo AWS Assignment 1</h1>
  <h2>Public EC2 Instance</h2>
  <p>This web server is running inside my custom AWS VPC.</p>
</body>
</html>
EOF
