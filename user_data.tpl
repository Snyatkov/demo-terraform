#!/bin/bash
yum -y update
yum -y install httpd ruby wget
myip=`curl http://169.254.169.254/latest/meta-data/local-ipv4`

cat <<EOF > /var/www/html/index.html
<html>
<h2>WebServer EC2 with local IP: $myip</h2><br>
Build by Terraform<br>
Made by: ${Owner}<br>
For project: ${Project}<br>
Version: 1.0
</html>
EOF
sudo service httpd start
chkconfig httpd on

cd /home/ec2-user

wget https://aws-codedeploy-eu-north-1.s3.eu-north-1.amazonaws.com/latest/install

chmod +x ./install

sudo ./install auto
