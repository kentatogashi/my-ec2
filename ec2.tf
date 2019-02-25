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

# Create custom VPC
resource "aws_vpc" "test-env" {
    cidr_block = "10.0.0.0/16"
    enable_dns_hostnames = true
    enable_dns_support = true
    tags {
        Name = "test-env"
    }
}

# Single elastic ip associated with an instance 
resource "aws_eip" "ip-test-env" {
    instance = "${aws_instance.test-ec2-instance.id}"
    vpc = true
}

resource "aws_subnet" "subnet-uno" {
    cidr_block = "${cidrsubnet(aws_vpc.test-env.cidr_block, 3, 1)}"
    vpc_id = "${aws_vpc.test-env.id}"
    availability_zone = "ap-northeast-1a"
}

resource "aws_internet_gateway" "test-env-gw" {
    vpc_id = "${aws_vpc.test-env.id}"
    tags {
        Name = "test-env-gw"
    }
}

resource "aws_route_table" "route-table-test-env" {
    vpc_id = "${aws_vpc.test-env.id}"
    route {
        cidr_block = "0.0.0.0/0"
        gateway_id = "${aws_internet_gateway.test-env-gw.id}"
    }
    tags {
        Name = "test-env-route-table"
    }
}

# Create an association between a subnet and routing table
resource "aws_route_table_association" "subnet-association" {
    subnet_id = "${aws_subnet.subnet-uno.id}"
    route_table_id = "${aws_route_table.route-table-test-env.id}"
}

resource "aws_security_group" "default" {
    name = "allow-all-sg"
    vpc_id = "${aws_vpc.test-env.id}"
    description = "Enable port for test01"

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

resource "aws_key_pair" "test01_deployer" {
    key_name = "${var.key_name}"
    public_key = "${file(var.public_key)}"
}

resource "aws_instance" "test-ec2-instance" {
    ami = "ami-0148288598227344a"
    instance_type = "t2.micro"
    monitoring = true
    tags {
        Name = "test-env"
    }
    key_name = "${var.key_name}"
    # security_groups = ["${aws_security_group.default.id}"]
    vpc_security_group_ids = ["${aws_security_group.default.id}"]
    subnet_id = "${aws_subnet.subnet-uno.id}"
}
