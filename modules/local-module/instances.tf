data "aws_iam_instance_profile" "Terraform" {
  name = "Terraform"
}

resource "tls_private_key" "test-pkey" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "aws_key_pair" "test-keypair" {
  key_name   = "test-keypair"
  public_key = tls_private_key.test-pkey.public_key_openssh

  provisioner "local-exec" {
    command = "echo '${tls_private_key.test-pkey.private_key_pem}' > ./test-keypair"
  }
}

resource "aws_launch_configuration" "test_launch" {
  name                 = "test-launch"
  depends_on           = [aws_security_group.vms_sg]
  image_id             = var.ami_id
  instance_type        = var.instance_type
  iam_instance_profile = data.aws_iam_instance_profile.Terraform.name
  key_name             = aws_key_pair.test-keypair.key_name
  security_groups      = [aws_security_group.vms_sg.id]
  user_data            = file("install-docker.sh")
}

resource "aws_autoscaling_group" "test_asg" {
  name                      = "test-asg"
  depends_on                = [aws_launch_configuration.test_launch]
  vpc_zone_identifier       = [aws_subnet.private.id]
  max_size                  = 2
  min_size                  = 2
  health_check_grace_period = 300
  health_check_type         = "EC2"
  desired_capacity          = 2
  force_delete              = true
  launch_configuration      = aws_launch_configuration.test_launch.id
  target_group_arns         = [aws_lb_target_group.test_target.arn]
}

resource "aws_lb" "test_alb" {
  name               = "test-alb"
  subnets            = [aws_subnet.public-1.id,aws_subnet.public-2.id]
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.internet_sg.id]
}

resource "aws_lb_target_group" "test_target" {
  name        = "test-target"
  port        = 80
  protocol    = "HTTP"
  vpc_id      = data.aws_vpc.default_vpc.id
  target_type = "instance"

  health_check {
    interval            = 30
    path                = "/"
    port                = 80
    healthy_threshold   = 5
    unhealthy_threshold = 2
    timeout             = 5
    protocol            = "HTTP"
    matcher             = "200,202"
  }
}

resource "aws_lb_listener" "test_listener" {
  load_balancer_arn = aws_lb.test_alb.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    target_group_arn = aws_lb_target_group.test_target.arn
    type             = "forward"
  }
}

