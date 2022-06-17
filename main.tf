resource "aws_instance" "instance-manager" {
  # spec
  ami = data.aws_ami.ubuntu-focal-x86_64.id
  instance_type = "t3.large"

  # script runs at first boot
  user_data = templatefile("${path.module}/templates/init_instance-manager.tftpl", { a = "a" })

  # my public ssh key
  key_name = "${var.ssh_key}"

  vpc_security_group_ids = [
    aws_security_group.egress-all-all.id,
    aws_security_group.ingress-all-all.id,
  ]

  root_block_device {
    volume_size = 40
  }

  tags = {
    Name = "instance-manager"
  }
}

resource "aws_instance" "instance-worker" {
  # run this block ${count} times
  count = 1

  # spec
  ami = data.aws_ami.ubuntu-focal-x86_64.id
  instance_type = "t3.medium"

  # script runs at first boot
  user_data = templatefile("${path.module}/templates/init_instance-worker.tftpl", { a = "a" })
  # user_data = templatefile("${path.module}/templates/init_instance-worker.tftpl", { manager_ip = aws_instance.instance-manager.private_ip })

  # my public ssh key
  key_name = "${var.ssh_key}"

  vpc_security_group_ids = [
    aws_security_group.egress-all-all.id,
    aws_security_group.ingress-all-all.id,
  ]

  tags = {
    Name = "instance-worker-${count.index}"
  }

  root_block_device {
    volume_size = 10
  }
}
