# EC2 Terraform script

You can get EC2 which is available ssh.

# Usage

Configure AWS access key and secret key.

```
$ cat terraform.tfvars.example
aws_access_key = ""
aws_secret_key = ""
aws_region = "ap-northeast-1"
key_name = "id_rsa_ec2"
public_key = "id_rsa_ec2.pub"
```

Rename terraform.tfvars.example.

```
$ cp -p terraform.tfvars.example terraform.tfvars
```

Generate key pair.

```
$ ssh-keygen -t rsa -f id_rsa_ec2
```

Run terraform

```
$ terraform apply
```

Test

```
$ terraform show | grep -E 'public_ip = (.+)'
  public_ip = 192.168.0.3
$ ssh -i id_rsa_ec2 ec2-user@192.168.0.3 'hostname'
  ip-192-168-0-3.ap-northeast-1.compute.internal
```
