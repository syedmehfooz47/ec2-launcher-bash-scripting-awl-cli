# 🚀 EC2 Instance Launcher — Bash Script

A clean, production-style Bash script that automates the process of launching an AWS EC2 instance using the AWS CLI. Designed as a real-world DevOps automation project demonstrating shell scripting, AWS CLI usage, and cloud infrastructure provisioning.

---

## 📸 What This Script Does

```
$ ./script.sh

Loaded config from .env
Creating EC2 instance...
Launching EC2 instance...
Instance i-0abc1234def567890 created successfully.
Waiting for instance i-0abc1234def567890 to be running...
Instance i-0abc1234def567890 is now running.
---------------------------------------------
  Instance ID : i-0abc1234def567890
  Public IP   : 18.224.45.67
  Name        : aws-vps2
  Region      : us-east-2
---------------------------------------------
Done.
```

---

## ⚡ Quick Start

> No cloning needed. Just download and run.

**Step 1 — Download the script and config template:**

```bash
curl -fsSL https://raw.githubusercontent.com/syedmehfooz47/ec2-launcher-bash-scripting-awl-cli/main/script.sh -o script.sh
curl -fsSL https://raw.githubusercontent.com/syedmehfooz47/ec2-launcher-bash-scripting-awl-cli/main/.env.example -o .env
```

**Step 2 — Fill in your values in `.env`:**

```bash
nano .env   # or open with any editor
```

```env
AMI_ID=ami-xxxxxxxxxxxxxxxxx
INSTANCE_TYPE=t3.micro
KEY_NAME=your-key-pair-name
SUBNET_ID=subnet-xxxxxxxxxxxxxxxxx
SECURITY_GROUP_IDS=sg-xxxxxxxxxxxxxxxxx
INSTANCE_NAME=my-ec2-instance
AWS_REGION=us-east-2
```

**Step 3 — Make it executable and run:**

```bash
chmod +x script.sh
./script.sh
```

---

## ✨ Features

- **Auto-detects AWS CLI** — installs it automatically if missing (Debian/Ubuntu)
- **Validates credentials** — checks AWS auth before making any API calls
- **Validates all parameters** — fails fast with clear error messages if anything is missing
- **Uses `.env` for config** — no hardcoded values in the script
- **Supports positional arguments** — optionally override `.env` values from the command line
- **Waits for running state** — uses native `aws ec2 wait` for reliable status polling
- **Displays instance summary** — prints Instance ID, Public IP, Name, and Region on completion
- **Strict error handling** — uses `set -euo pipefail` throughout

---

## 📁 Project Structure

```
.
├── script.sh        # Main script — launches the EC2 instance
├── .env             # Your config (not committed to Git)
├── .env.example     # Template — safe to commit
├── .gitignore       # Excludes .env, .pem files, and secrets
└── README.md
```

---

## ⚙️ Prerequisites

| Requirement | Details |
|-------------|---------|
| **OS** | Linux or macOS (or Git Bash / WSL on Windows) |
| **AWS CLI v2** | Auto-installed if missing (Debian/Ubuntu) |
| **AWS Account** | With EC2 launch permissions |
| **IAM Permissions** | `ec2:RunInstances`, `ec2:DescribeInstances`, `ec2:CreateTags`, `sts:GetCallerIdentity` |
| **Key Pair** | Must exist in your AWS account |
| **Subnet & Security Group** | Must be pre-created in your VPC |

---

## 🔐 AWS CLI Setup

Before running the script, configure your AWS credentials:

```bash
$ aws configure
```

You will be prompted to enter your credentials:

```
AWS Access Key ID [None]: ******************
AWS Secret Access Key [None]: ********************
Default region name [None]: us-east-2
Default output format [None]: json
```

> **Tip:** You can also deliver temporary credentials using your AWS Console session:
> ```bash
> aws login
> ```
> This is useful when using IAM Identity Center (SSO) or temporary session tokens.

---

## 🛠️ Configuration

Copy the example file and fill in your values:

```bash
cp .env.example .env
```

Then edit `.env`:

```env
AMI_ID=ami-*****************       # Amazon Machine Image ID
INSTANCE_TYPE=t3.micro             # Instance size (t3.micro is free-tier eligible)
KEY_NAME=your-key-pair-name        # EC2 Key Pair name (not the ID)
SUBNET_ID=subnet-*****************  # VPC Subnet ID
SECURITY_GROUP_IDS=sg-*************  # Security Group ID(s)
INSTANCE_NAME=my-ec2-instance      # Tag name shown in the AWS Console
AWS_REGION=us-east-2               # AWS region where resources exist
```

> **Important:** Never commit your `.env` file — it is listed in `.gitignore`.

---

## 🚀 Usage

```bash
# Make the script executable
chmod +x script.sh

# Run using values from .env
./script.sh

# Or pass values directly as arguments (overrides .env)
./script.sh <ami-id> <instance-type> <key-name> <subnet-id> <security-group-id> <instance-name>
```

**Example with arguments:**

```bash
./script.sh ami-0fe18bc3cfa53a248 t3.micro aws-ec2 subnet-0f36cdee6 sg-08c15189b aws-vps2
```

---

## 🔍 How It Works

```
script.sh
│
├── 1. Load .env           → reads your configuration
├── 2. check_awscli()      → checks if AWS CLI is installed
├── 3. install_awscli()    → installs it if missing (Ubuntu/Debian)
├── 4. check_aws_credentials() → verifies your AWS auth
├── 5. validate_params()   → ensures no required value is empty
├── 6. create_ec2_instance() → calls aws ec2 run-instances
├── 7. wait_for_instance() → waits until instance is in running state
└── 8. Prints summary      → Instance ID, Public IP, Name, Region
```

---

## 🔎 Useful AWS CLI Commands

```bash
# Find your AMI (Amazon Linux 2)
aws ec2 describe-images --owners amazon \
  --filters "Name=name,Values=amzn2-ami-hvm-*" \
  --query 'Images[0].ImageId' --output text

# List your key pairs
aws ec2 describe-key-pairs \
  --query 'KeyPairs[*].[KeyPairId,KeyName]' --output table

# List your subnets
aws ec2 describe-subnets \
  --query 'Subnets[*].[SubnetId,VpcId,AvailabilityZone]' --output table

# List your security groups
aws ec2 describe-security-groups \
  --query 'SecurityGroups[*].[GroupId,GroupName]' --output table
```

---

## 🛡️ Security Best Practices

- **Never hardcode AWS credentials** in scripts or commit them to Git
- **Use IAM roles** when running this on another EC2 instance
- **Apply least-privilege** — only grant the permissions the script actually needs
- **`.pem` key files** are excluded from Git via `.gitignore`

---

## 🧠 Skills Demonstrated

- Bash scripting with strict error handling (`set -euo pipefail`)
- AWS CLI v2 — EC2 provisioning and querying
- Modular function-based script design
- Environment-based configuration (`.env` pattern)
- Input validation and early failure
- Cloud infrastructure automation

---

> 💡 **Note:** For managing infrastructure at scale, tools like [Terraform](https://www.terraform.io/) or [AWS CloudFormation](https://aws.amazon.com/cloudformation/) are recommended. This script is ideal for learning AWS CLI, lightweight automation, and demonstrating DevOps fundamentals.
