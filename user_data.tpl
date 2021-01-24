#!/bin/bash
yum -y update
yum -y install httpd
myip=`curl http://169.254.169.254/latest/meta-data/local-ipv4`
cat <<EOF > /var/www/html/index.html
<html>
<h2>WebServer EC2 with local IP: $myip</h2><br>
Build by Terraform<br>
Made by: ${Owner}<br>
For project: ${Project}
</html>
EOF
sudo service httpd start
chkconfig httpd on
