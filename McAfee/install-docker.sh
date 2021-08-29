#! /bin/sh
sudo yum update -y
sudo amazon-linux-extras install docker
sudo service docker start
sudo usermod -a -G docker ec2-user
sudo chkconfig docker on

sudo aws s3 cp s3://cf-templates-17tbfwprjscbm-us-west-2/nginx.conf /home/ec2-user/nginx.conf
sudo chown ec2-user /home/ec2-user/nginx.conf
