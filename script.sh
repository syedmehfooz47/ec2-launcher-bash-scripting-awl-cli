#!/bin/bash
set -euo pipefail

# Load settings from .env file
ENV_FILE="$(dirname "$0")/.env"
if [[ -f "$ENV_FILE" ]]; then
    source "$ENV_FILE"
    echo "Loaded config from .env"
else
    echo "Warning: .env file not found." >&2
fi

# Default values (overridden by .env)
AMI_ID="${AMI_ID:-}"
INSTANCE_TYPE="${INSTANCE_TYPE:-t2.micro}"
KEY_NAME="${KEY_NAME:-}"
SUBNET_ID="${SUBNET_ID:-}"
SECURITY_GROUP_IDS="${SECURITY_GROUP_IDS:-}"
INSTANCE_NAME="${INSTANCE_NAME:-Shell-Script-EC2-Demo}"
AWS_REGION="${AWS_REGION:-us-east-1}"

# Check if AWS CLI is installed
check_awscli() {
    if ! command -v aws &> /dev/null; then
        echo "AWS CLI is not installed. Please install it first." >&2
        return 1
    fi
}

# Install AWS CLI v2 on Linux (Debian/Ubuntu)
install_awscli() {
    echo "Installing AWS CLI v2..."
    curl -s "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
    sudo apt-get install -y unzip &> /dev/null
    unzip -q awscliv2.zip
    sudo ./aws/install
    aws --version
    rm -rf awscliv2.zip ./aws
}

# Check if AWS credentials are set up
check_aws_credentials() {
    if ! aws sts get-caller-identity --region "$AWS_REGION" &> /dev/null; then
        echo "AWS credentials are not set up. Run 'aws configure'." >&2
        exit 1
    fi
}

# Make sure all required variables are set
validate_params() {
    local missing=0

    if [[ -z "$AMI_ID" ]]; then
        echo "Error: AMI_ID is not set." >&2
        missing=1
    fi
    if [[ -z "$KEY_NAME" ]]; then
        echo "Error: KEY_NAME is not set." >&2
        missing=1
    fi
    if [[ -z "$SUBNET_ID" ]]; then
        echo "Error: SUBNET_ID is not set." >&2
        missing=1
    fi
    if [[ -z "$SECURITY_GROUP_IDS" ]]; then
        echo "Error: SECURITY_GROUP_IDS is not set." >&2
        missing=1
    fi

    if [[ "$missing" -eq 1 ]]; then
        echo "Please fill in the required configuration variables in .env" >&2
        exit 1
    fi
}

# Wait until the instance is running
wait_for_instance() {
    local instance_id="$1"
    echo "Waiting for instance $instance_id to be running..."
    aws ec2 wait instance-running \
        --instance-ids "$instance_id" \
        --region "$AWS_REGION"
    echo "Instance $instance_id is now running."
}

# Create the EC2 instance
create_ec2_instance() {
    local ami_id="$1"
    local instance_type="$2"
    local key_name="$3"
    local subnet_id="$4"
    local security_group_ids="$5"
    local instance_name="$6"

    echo "Launching EC2 instance..."

    instance_id=$(aws ec2 run-instances \
        --region "$AWS_REGION" \
        --image-id "$ami_id" \
        --instance-type "$instance_type" \
        --key-name "$key_name" \
        --subnet-id "$subnet_id" \
        --security-group-ids $security_group_ids \
        --tag-specifications "ResourceType=instance,Tags=[{Key=Name,Value=$instance_name}]" \
        --query 'Instances[0].InstanceId' \
        --output text
    )

    if [[ -z "$instance_id" ]]; then
        echo "Failed to create EC2 instance." >&2
        exit 1
    fi

    echo "Instance $instance_id created successfully."
    wait_for_instance "$instance_id"

    # Get and display the public IP
    public_ip=$(aws ec2 describe-instances \
        --instance-ids "$instance_id" \
        --region "$AWS_REGION" \
        --query 'Reservations[0].Instances[0].PublicIpAddress' \
        --output text)

    echo "---------------------------------------------"
    echo "  Instance ID : $instance_id"
    echo "  Public IP   : $public_ip"
    echo "  Name        : $instance_name"
    echo "  Region      : $AWS_REGION"
    echo "---------------------------------------------"
}

main() {
    # You can also pass values directly as arguments (they override .env)
    # Usage: ./script.sh <ami> <type> <key> <subnet> <sg> <name>
    [[ -n "${1:-}" ]] && AMI_ID="$1"
    [[ -n "${2:-}" ]] && INSTANCE_TYPE="$2"
    [[ -n "${3:-}" ]] && KEY_NAME="$3"
    [[ -n "${4:-}" ]] && SUBNET_ID="$4"
    [[ -n "${5:-}" ]] && SECURITY_GROUP_IDS="$5"
    [[ -n "${6:-}" ]] && INSTANCE_NAME="$6"

    if ! check_awscli; then
        install_awscli
    fi

    check_aws_credentials
    validate_params

    echo "Creating EC2 instance..."
    create_ec2_instance "$AMI_ID" "$INSTANCE_TYPE" "$KEY_NAME" "$SUBNET_ID" "$SECURITY_GROUP_IDS" "$INSTANCE_NAME"
    echo "Done."
}

main "$@"