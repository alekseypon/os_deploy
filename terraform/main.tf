provider "aws" {
  access_key = "${var.access_key}"
  secret_key = "${var.secret_key}"
  region     = "${var.region}"
}

data aws_vpc "default_vpc" {
  default = true
}

data "aws_ami" "centos" {
  most_recent = true

  filter {
    name   = "product-code"
    values = ["aw0evgkw8e5c1q413zgy5pjce"]
  }
  owners = ["679593333241"]
}

resource aws_security_group "sg_ec2_master" {
  name = "ec2-master"
  vpc_id      = "${data.aws_vpc.default_vpc.id}"

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "TCP"
    cidr_blocks = ["0.0.0.0/0"]
#    cidr_blocks = ["${data.aws_vpc.default_vpc.cidr_block}"] # Source..
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"          # Nescessary
    cidr_blocks = ["0.0.0.0/0"] # Destination..
  }

  tags {
    Name = "ec2-master"
  }
}

resource aws_security_group "sg_ec2_node" {
  name = "ec2-node"
  vpc_id      = "${data.aws_vpc.default_vpc.id}"

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "TCP"
    cidr_blocks = ["0.0.0.0/0"]
#    cidr_blocks = ["${data.aws_vpc.default_vpc.cidr_block}"] # Source..
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"          # Nescessary
    cidr_blocks = ["0.0.0.0/0"] # Destination..
  }

  tags {
    Name = "ec2-node"
  }
}

resource aws_spot_instance_request "master" {
  count                  = "${var.master_number}"
  ami                    = "${data.aws_ami.centos.id}"
  instance_type          = "${var.master_ec2_type}"
  vpc_security_group_ids = ["${aws_security_group.sg_ec2_master.id}"]
  key_name               = "${var.key_name}"
  spot_price             = "${var.master_spot_price}"
  availability_zone      = "${var.availability_zone}"
  wait_for_fulfillment   = true

  tags {
    Name = "master-${count.index}",
    Role = "master"
  }

  connection {
    user = "centos"
    private_key = "${file(var.private_key_path)}"
    host = "${self.public_ip}"
  }

  provisioner "file" {
    source = "set_tags.sh"
    destination = "/home/centos/set_tags.sh"
  }

  provisioner "remote-exec" {
    inline = [
      "bash /home/centos/set_tags.sh ${var.access_key} ${var.secret_key} ${var.region} ${self.id} ${self.spot_instance_id}"
    ]
  }
}

resource aws_spot_instance_request "node" {
  count                  = "${var.node_number}"
  ami                    = "${data.aws_ami.centos.id}"
  instance_type          = "${var.node_ec2_type}"
  vpc_security_group_ids = ["${aws_security_group.sg_ec2_node.id}"]
  key_name               = "${var.key_name}"
  spot_price             = "${var.node_spot_price}"
  availability_zone      = "${var.availability_zone}"
  wait_for_fulfillment   = true

  tags {
    Name = "node-${count.index}"
    Role = "node"
  }

  connection {
    user = "centos"
    private_key = "${file(var.private_key_path)}"
    host = "${self.public_ip}"
  }

  provisioner "file" {
    source = "set_tags.sh"
    destination = "/home/centos/set_tags.sh"
  }

  provisioner "remote-exec" {
    inline = [
      "bash /home/centos/set_tags.sh ${var.access_key} ${var.secret_key} ${var.region} ${self.id} ${self.spot_instance_id}"
    ]
  }
}
