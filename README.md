# My EC2

You can get EC2 which is available ssh

# Usage

Configure AWS access key and secret key

```
$ cat terraform.tfvars.example
aws_access_key = ""
aws_secret_key = ""
aws_region = "ap-northeast-1"
key_name = "id_rsa_ec2"
public_key = "id_rsa_ec2.pub"
```

Rename terraform.tfvars.example

```
$ cp -p terraform.tfvars.example terraform.tfvars
```

Generate key pair

```
$ ssh-keygen -t rsa -f id_rsa_ec2
```

Initialize terraform

```
$ terraform init
Initializing provider plugins...

The following providers do not have any version constraints in configuration,
so the latest version was installed.

To prevent automatic upgrades to new major versions that may contain breaking
changes, it is recommended to add version = "..." constraints to the
corresponding provider blocks in configuration, with the constraint strings
suggested below.

* provider.aws: version = "~> 1.60"
* provider.null: version = "~> 2.1"

Terraform has been successfully initialized!

You may now begin working with Terraform. Try running "terraform plan" to see
any changes that are required for your infrastructure. All Terraform commands
should now work.

If you ever set or change modules or backend configuration for Terraform,
rerun this command to reinitialize your working directory. If you forget, other
commands will detect it and remind you to do so if necessary.
```

Run terraform

```
$ terraform apply
(snip)

Apply complete! Resources: 10 added, 0 changed, 0 destroyed.

Outputs:

EIP for EC2 instance = 192.168.0.3

```

Test

```
$ ssh -i id_rsa_ec2 ec2-user@192.168.0.3 hostname
  ip-192-168-0-3.ap-northeast-1.compute.internal
```

# Note

Debug mode

```
$ export TF_LOG=1
$ export TF_LOG_PATH=./my-ec2.log
$ terraform apply
```
