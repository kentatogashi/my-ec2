variable "aws_access_key" {}
variable "aws_secret_key" {}
variable "aws_region" {}
variable "key_name" {}
variable "public_key" {}

provider "aws" {
    access_key = "${var.aws_access_key}"
    secret_key = "${var.aws_secret_key}"
    region = "${var.aws_region}"
}

resource "aws_vpc" "my-vpc" {
    cidr_block = "10.0.0.0/16"
    enable_dns_hostnames = true
    enable_dns_support = true
    tags {
        Name = "my-vpc"
    }
}
resource "aws_subnet" "my-subnet" {
    # cidrsubnetで計算すると10.0.32.0/19になる。
    cidr_block = "${cidrsubnet(aws_vpc.my-vpc.cidr_block, 3, 1)}"
    vpc_id = "${aws_vpc.my-vpc.id}"
    availability_zone = "ap-northeast-1a"
}
resource "aws_eip" "my-eip" {
    instance = "${aws_instance.my-ec2.id}"
    vpc = true
}
resource "aws_internet_gateway" "my-gw" {
    vpc_id = "${aws_vpc.my-vpc.id}"
    tags {
        Name = "my-gw"
    }
}
resource "aws_route_table" "my-route-table" {
    vpc_id = "${aws_vpc.my-vpc.id}"
    route {
        cidr_block = "0.0.0.0/0"
        gateway_id = "${aws_internet_gateway.my-gw.id}"
    }
    tags {
        Name = "my-route-table"
    }
}
resource "aws_route_table_association" "subnet-association" {
    subnet_id = "${aws_subnet.my-subnet.id}"
    route_table_id = "${aws_route_table.my-route-table.id}"
}
resource "aws_security_group" "my-security-group" {
    name = "allow-ssh"
    vpc_id = "${aws_vpc.my-vpc.id}"
    description = "Allow SSH port"

    # inbound traffic to a instance
    ingress {
        cidr_blocks = ["0.0.0.0/0"]
        from_port = 22
        to_port = 22
        protocol = "tcp"
    }

    # outbound traffic from a instance
    egress {
        from_port = 0
        to_port = 0
        protocol = "-1"
        cidr_blocks = ["0.0.0.0/0"]
    }
}
resource "aws_key_pair" "my-key-pair" {
    key_name = "${var.key_name}"
    public_key = "${file(var.public_key)}"
}
resource "aws_instance" "my-ec2" {
    ami = "ami-0148288598227344a"
    instance_type = "t2.micro"
    monitoring = true
    tags {
        Name = "my-ec2"
    }
    key_name = "${var.key_name}"
    vpc_security_group_ids = ["${aws_security_group.my-security-group.id}"]
    subnet_id = "${aws_subnet.my-subnet.id}"
}
