# EC2 and Compute

## 33. Amazon Compute

In cloud computing, **compute** means the processing power used to run operating systems, applications, containers, scripts and other workloads.

Traditionally, a company would need to:

- Purchase physical servers
- Install them in a data centre
- Provide electricity and cooling
- Replace faulty hardware
- Estimate future capacity
- Maintain the operating systems

AWS allows businesses to rent compute resources when they need them.

> Think of compute as the engine that runs an application.

---

## AWS Compute Services

AWS provides different compute services for different types of workloads.

| AWS service | What it provides | Example use |
| --- | --- | --- |
| Amazon EC2 | Virtual servers | Hosting a website or application |
| AWS Lambda | Runs code without managing servers | Processing an uploaded file |
| Amazon ECS | AWS container management | Running Docker containers |
| Amazon EKS | Managed Kubernetes | Running Kubernetes workloads |
| AWS Fargate | Serverless compute for containers | Running containers without managing EC2 |
| Elastic Beanstalk | Managed application deployment | Deploying an application quickly |
| Amazon Lightsail | Simplified virtual servers | Small websites and projects |
| AWS Batch | Managed batch processing | Processing large numbers of jobs |

---

## Choosing a Compute Service

Ask the following questions:

1. Do I need control of the operating system?
2. Am I running a full server, container or individual function?
3. Does the workload run continuously or only when triggered?
4. Does it need to scale automatically?
5. Can the workload tolerate interruption?
6. How much management work do I want AWS to perform?
7. What are the performance and cost requirements?

### Example

| Requirement | Suitable service |
| --- | --- |
| Full control over an Ubuntu server | EC2 |
| Run code when an image is uploaded | Lambda |
| Run Docker containers | ECS or Fargate |
| Run Kubernetes | EKS |
| Quickly deploy a simple application | Elastic Beanstalk |

EC2 offers a high level of control, but the customer also has more responsibility.

With EC2, the customer normally manages:

- The guest operating system
- Operating-system updates
- Installed software
- Application configuration
- User permissions
- Security settings
- Data and backups

AWS manages:

- Physical servers
- Data-centre buildings
- Electricity
- Cooling
- Physical networking
- Hardware replacement

---

# 34. Amazon EC2

**Amazon EC2** stands for **Amazon Elastic Compute Cloud**.

EC2 is an AWS service that provides scalable virtual servers.

One virtual server created using EC2 is called an **EC2 instance**.

> **EC2 = the AWS service**

> **EC2 instance = one virtual server running inside EC2**

For example, an Ubuntu server created in AWS and used to run NGINX is an EC2 instance.

---

## Why Is It Called Elastic Compute Cloud?

### Elastic

Resources can be increased or decreased depending on demand.

For example:

- Increase the size of an instance
- Reduce the size of an instance
- Add more instances
- Remove unnecessary instances

### Compute

The processing power used to run applications.

### Cloud

The server is hosted in AWS data centres and accessed through a network.

---

## Benefits of EC2

EC2 allows organisations to:

- Launch servers in minutes
- Select different operating systems
- Choose the required CPU and memory
- Increase or decrease capacity
- Pay based on usage
- Automate server creation
- Deploy servers in different Regions
- Connect EC2 to other AWS services
- Replace failed servers more quickly
- Avoid purchasing physical hardware

---

## What Makes Up an EC2 Instance?

| Component | Purpose |
| --- | --- |
| AMI | Image used to create the server |
| Instance type | Determines CPU, memory and other hardware capacity |
| EBS volume | Persistent storage attached to the instance |
| VPC | AWS network containing the instance |
| Subnet | Smaller network inside the VPC |
| Security group | Virtual firewall controlling allowed traffic |
| Key pair | Used to authenticate when connecting through SSH |
| IAM role | Gives applications permission to access AWS services |
| User Data | Automates initial server configuration |
| Tags | Labels used to identify and organise the instance |

---

## EC2 Instance Lifecycle

An EC2 instance can move through several states.

| State or action | Meaning |
| --- | --- |
| Pending | AWS is preparing the instance |
| Running | The server is switched on |
| Reboot | Restarts the operating system |
| Stop | Switches the server off but normally retains EBS storage |
| Start | Switches a stopped instance back on |
| Hibernate | Saves the contents of memory when supported |
| Terminate | Permanently deletes the instance |

### Start

Starting an instance powers on a stopped virtual server.

### Stop

Stopping an EBS-backed instance:

- Turns off the virtual server
- Stops most compute charges
- Keeps its EBS volumes
- Allows the instance to be started again

However, storage and other related resources can continue generating charges.

### Reboot

Rebooting restarts the operating system.

It is similar to restarting a physical computer.

### Terminate

Terminating an instance permanently deletes it.

> Stopping is temporary. Terminating is normally permanent.

---

## Important EC2 Cost and Data Behaviour

- Compute is not normally charged while an instance is stopped.
- Attached EBS volumes can continue generating storage charges.
- Public IPv4 addresses may generate charges.
- A normal public IPv4 address can change after stopping and starting an instance.
- Termination is permanent.
- EBS volumes marked **Delete on termination** are deleted when the instance is terminated.
- Instance-store data is temporary.
- Snapshots and Elastic IP addresses can continue generating charges.

---

# 35. EC2 Sizing and Configuration Options

When launching an EC2 instance, several options must be configured.

The configuration should match the requirements of the workload.

---

## 1. Name and Tags

Give the instance a meaningful name.

Example:

```text
nginx-networking-lab
```

Tags are key-value labels used to organise AWS resources.

| Tag key | Example value |
| --- | --- |
| `Name` | `nginx-networking-lab` |
| `Environment` | `learning` |
| `Project` | `aws-learning` |
| `Owner` | `Abubakar` |

Tags can be used for:

- Searching
- Organisation
- Automation
- Access control
- Cost tracking

---

## 2. Amazon Machine Image

An **Amazon Machine Image**, or **AMI**, is the template used to create an EC2 instance.

An AMI can include:

- An operating system
- Installed software
- Configuration settings
- Storage mappings
- Permissions controlling who can use it

Examples include:

- Amazon Linux
- Ubuntu
- Red Hat Enterprise Linux
- Windows Server

> An AMI is similar to a preconfigured template used to build a new server.

The selected AMI must be compatible with the processor architecture of the instance type.

Common architectures include:

- `x86_64`
- `arm64`

---

## 3. Instance Type

The instance type determines the virtual hardware available to the server.

It can control:

- Number of virtual CPUs
- Amount of memory
- Network performance
- EBS bandwidth
- Processor architecture
- Local instance storage
- GPUs and other accelerators

A larger instance normally provides more capacity but costs more.

Example:

```text
t3.micro
```

---

## 4. Key Pair

A key pair can be used to securely connect to a Linux EC2 instance through SSH.

The key pair contains:

- A public key stored by AWS
- A private key downloaded by the user

Common private-key file extensions include:

```text
.pem
.ppk
```

The private key must be protected.

Never:

- Upload the private key to GitHub
- Email the private key
- Share it with unauthorised people
- Store it in a public repository
- Add it to application source code

Other connection methods include:

- EC2 Instance Connect
- AWS Systems Manager Session Manager
- SSH certificates

---

## 5. Networking

Important networking choices include:

- VPC
- Subnet
- Availability Zone
- Private IP address
- Public IP address
- Security group
- Network interface

An instance normally receives a private IP address.

It may also receive a public IP address if it needs direct internet communication.

---

## 6. Storage

Most EC2 instances use **Amazon Elastic Block Store**, also known as **Amazon EBS**.

An EBS volume acts like a virtual hard drive.

Storage options include:

- Volume type
- Capacity in GiB
- IOPS
- Throughput
- Encryption
- Delete-on-termination setting

EBS storage can remain after an instance is stopped.

Depending on its configuration, an EBS volume may also remain after the instance is terminated.

---

## 7. IAM Role

An IAM role can give applications running on EC2 permission to access other AWS services.

For example, an EC2 application may need permission to:

- Read from S3
- Write logs to CloudWatch
- Retrieve a secret
- Access a database

The secure method is to attach an IAM role to the EC2 instance.

Do not save permanent access keys on the server.

---

## 8. User Data

User Data can automatically install and configure software when the instance launches.

For example, User Data could:

- Update Ubuntu
- Install NGINX
- Create a webpage
- Start the NGINX service

---

## 9. Additional Settings

Advanced EC2 settings can include:

- Detailed CloudWatch monitoring
- Termination protection
- Shutdown behaviour
- Tenancy
- Placement groups
- CPU configuration
- Instance metadata settings
- Capacity reservations
- EBS optimisation

---

## EC2 Right-Sizing

**Right-sizing** means selecting an instance with enough resources for the workload without paying for unnecessary capacity.

### Right-Sizing Process

1. Identify the workload.
2. Estimate the required CPU and memory.
3. Consider storage and network requirements.
4. Select an appropriate instance family.
5. Start with a sensible size.
6. Monitor the instance using CloudWatch.
7. Increase or decrease its size when necessary.

> The largest server is not automatically the best server.

An oversized instance wastes money.

An undersized instance may have:

- Poor performance
- High CPU usage
- Slow response times
- Application failures
- Insufficient memory

---

# 36. EC2 User Data

**EC2 User Data** is a script or configuration passed to an EC2 instance when it launches.

It is normally used to automate the initial setup of the server.

This process is called **bootstrapping**.

---

## Common Uses of User Data

User Data can:

- Update the operating system
- Install packages
- Install a web server
- Download application files
- Create users and directories
- Generate configuration files
- Start and enable services
- Register the instance with another service

---

## User Data Example

```bash
#!/bin/bash

apt-get update -y
apt-get install -y nginx
systemctl enable nginx
systemctl start nginx
```

This script:

1. Uses Bash to run the commands.
2. Updates the Ubuntu package list.
3. Installs NGINX.
4. Enables NGINX during future boots.
5. Starts the NGINX service.

---

## Important User Data Behaviour

- Linux User Data commonly uses shell scripts or cloud-init.
- The first line should normally contain a shebang such as `#!/bin/bash`.
- User Data scripts normally run as the root user.
- `sudo` is therefore usually unnecessary inside the script.
- User Data normally runs during the first boot.
- Rebooting the instance does not normally run it again.
- Commands should not require interactive input.
- User Data should not contain passwords or secret keys.
- User Data is not a replacement for a full configuration-management system.

---

## User Data Process

```text
Launch EC2 instance
        ↓
Operating system starts
        ↓
cloud-init reads User Data
        ↓
Script installs and configures software
        ↓
Application service starts
```

---

## User Data Security Warning

Do not place the following inside User Data:

- AWS access keys
- Secret access keys
- Passwords
- API tokens
- Private keys
- Database credentials

User Data should not be treated as a secure location for secrets.

Use services such as:

- IAM roles
- AWS Secrets Manager
- AWS Systems Manager Parameter Store

---

## Troubleshooting User Data

On many Linux AMIs, the output can be checked with:

```bash
sudo less /var/log/cloud-init-output.log
```

Check the status of cloud-init:

```bash
cloud-init status
```

Check the NGINX service:

```bash
sudo systemctl status nginx
```

Check whether the local web server responds:

```bash
curl http://localhost
```

User Data may fail because:

- The script contains a syntax error.
- The instance has no internet access.
- DNS resolution is not working.
- The AMI uses a different package manager.
- A command asks for user input.
- The package manager is locked.
- A required file or directory does not exist.
- The script uses Windows line endings on Linux.

---

# 37. EC2 User Data – Demo

This User Data script installs NGINX on Ubuntu and creates a simple webpage.

```bash
#!/bin/bash
set -e

apt-get update -y
apt-get install -y nginx

cat > /var/www/html/index.html <<'EOF'
<!doctype html>
<html lang="en">
<head>
  <meta charset="utf-8">
  <meta name="viewport" content="width=device-width, initial-scale=1">
  <title>Abubakar's AWS EC2 Server</title>
</head>
<body>
  <h1>Hello from Amazon EC2!</h1>
  <p>This NGINX web server was configured automatically using EC2 User Data.</p>
</body>
</html>
EOF

systemctl enable nginx
systemctl restart nginx
```

---

## What the Script Does

| Command | Purpose |
| --- | --- |
| `#!/bin/bash` | Runs the script using Bash |
| `set -e` | Stops the script if a command fails |
| `apt-get update -y` | Refreshes Ubuntu's package list |
| `apt-get install -y nginx` | Installs NGINX |
| `cat > index.html` | Creates the custom webpage |
| `systemctl enable nginx` | Enables NGINX during future boots |
| `systemctl restart nginx` | Starts or restarts NGINX |

---

## Verify the User Data Demo

After the instance has launched:

1. Wait for it to enter the **Running** state.
2. Wait for both status checks to pass.
3. Copy the public IPv4 address.
4. Enter the address into a browser.

```text
http://PUBLIC-IP-ADDRESS
```

The custom webpage should appear.

---

## If the Website Does Not Load

Check:

- The EC2 instance is running.
- Both status checks have passed.
- The instance has a public IP address.
- The security group allows inbound TCP port 80.
- The subnet has a route to an internet gateway.
- NGINX is running.
- User Data completed successfully.

Connect to the instance and run:

```bash
sudo systemctl status nginx
```

Check the User Data output:

```bash
sudo less /var/log/cloud-init-output.log
```

Test NGINX locally:

```bash
curl http://localhost
```

---

# 38. EC2 Instance Types – Overview

An **EC2 instance type** defines the virtual hardware available to an instance.

The name usually contains:

- Instance family
- Generation
- Additional capabilities
- Instance size

---

## Example: `t3.micro`

```text
t3.micro
││   └── Size
│└────── Generation
└─────── Instance family
```

| Part | Meaning |
| --- | --- |
| `t` | Burstable general-purpose family |
| `3` | Third generation of that family |
| `micro` | Size within the family |

---

## Example: `m7g.large`

| Part | Meaning |
| --- | --- |
| `m` | General-purpose M family |
| `7` | Generation |
| `g` | AWS Graviton processor |
| `large` | Instance size |

Additional letters may describe:

- Processor type
- Local storage
- High networking
- Additional memory
- Accelerators

---

## Main Instance Categories

| Category | Common families | Best suited for |
| --- | --- | --- |
| General purpose | T and M | Web servers, development and business applications |
| Compute optimised | C | CPU-intensive applications |
| Memory optimised | R and X | In-memory databases and caching |
| Storage optimised | I, D and H | Large datasets and high disk throughput |
| Accelerated computing | P, G, Inf and Trn | Graphics and machine learning |
| High-performance computing | HPC | Scientific simulations and HPC workloads |

---

## General-Purpose Instances

General-purpose instances provide a balance of:

- CPU
- Memory
- Networking

Common uses include:

- Web servers
- Development environments
- Business applications
- Small and medium databases
- Code repositories

Common families include:

```text
T
M
```

---

## Burstable T Instances

T-family instances provide a baseline level of CPU performance.

They can temporarily burst above the baseline by using **CPU credits**.

They are suitable for workloads that do not use high CPU continuously.

Examples include:

- Small web servers
- Development environments
- Low-traffic applications
- Small databases
- Code repositories

They may not be suitable for applications requiring continuous high CPU performance.

---

## Compute-Optimised Instances

Compute-optimised instances provide a higher ratio of CPU to memory.

Common family:

```text
C
```

Common uses include:

- Batch processing
- Gaming servers
- Video encoding
- Scientific modelling
- High-performance web servers
- CPU-intensive applications

---

## Memory-Optimised Instances

Memory-optimised instances provide large amounts of RAM.

Common families include:

```text
R
X
```

Common uses include:

- In-memory databases
- Large caches
- Real-time analytics
- SAP workloads
- Memory-intensive applications

---

## Storage-Optimised Instances

Storage-optimised instances are designed for workloads requiring high storage throughput or large local storage capacity.

Common families include:

```text
I
D
H
```

Common uses include:

- Data warehouses
- Distributed file systems
- NoSQL databases
- Large datasets
- Log processing

---

## Accelerated-Computing Instances

Accelerated instances may use GPUs or specialist AWS processors.

Common families include:

```text
P
G
Inf
Trn
```

Common uses include:

- Machine-learning training
- Machine-learning inference
- Graphics rendering
- Video processing
- Scientific calculations

---

## Instance Sizes

Common size names include:

```text
nano
micro
small
medium
large
xlarge
2xlarge
4xlarge
```

Larger sizes normally provide more:

- Virtual CPUs
- Memory
- Network performance
- EBS bandwidth

The exact specifications vary between instance families.

Always check:

- vCPUs
- Memory
- Architecture
- Network performance
- EBS bandwidth
- Storage
- Regional availability
- Price

---

## Vertical and Horizontal Scaling

### Vertical Scaling

Vertical scaling means changing the size of one server.

Example:

```text
t3.micro → t3.large
```

This gives the server more CPU and memory.

An EBS-backed instance normally needs to be stopped before changing its instance type.

### Horizontal Scaling

Horizontal scaling means adding or removing instances.

Example:

```text
One web server → Three web servers
```

The servers could be placed behind a load balancer.

| Vertical scaling | Horizontal scaling |
| --- | --- |
| Makes one server larger | Adds more servers |
| Simple for small workloads | Improves scalability |
| Has a maximum server size | Can scale across many instances |
| May require downtime | Can improve availability |

---

# Running a Web Server on an EC2 Instance – Demo

This demo creates an Ubuntu EC2 instance in the London Region and automatically installs NGINX.

---

## Architecture

```text
Internet user
      ↓
Public IP address
      ↓
Internet gateway
      ↓
Public subnet
      ↓
Security group allows TCP 80
      ↓
Ubuntu EC2 instance
      ↓
NGINX web server
```

---

## Step 1: Select the Region

Select:

```text
Europe (London) – eu-west-2
```

AWS resources are Region-specific, so always confirm the selected Region.

---

## Step 2: Launch the Instance

1. Open the AWS Management Console.
2. Search for **EC2**.
3. Select **Instances**.
4. Select **Launch instances**.

---

## Step 3: Configure the Instance

| Setting | Example |
| --- | --- |
| Name | `nginx-networking-lab` |
| AMI | Current Ubuntu Server LTS |
| Architecture | Compatible 64-bit architecture |
| Instance type | Small learning instance such as `t3.micro` |
| Key pair | Existing protected key or new key |
| VPC | Default VPC for this introductory lab |
| Subnet | Public subnet in `eu-west-2` |
| Public IPv4 | Enabled |
| Storage | Small encrypted EBS root volume |

Free Tier eligibility depends on the account, Region, instance type and current AWS offer.

Always check the price shown in the AWS console before launching.

---

## Step 4: Configure the Security Group

Create or select a security group with the required rules.

| Type | Protocol | Port | Source | Purpose |
| --- | --- | --- | --- | --- |
| SSH | TCP | 22 | My IP | Allow administrative access |
| HTTP | TCP | 80 | `0.0.0.0/0` | Allow IPv4 visitors |
| HTTP | TCP | 80 | `::/0` | Allow IPv6 visitors when configured |

Do not expose SSH port 22 to the entire internet unless a controlled lab specifically requires it.

Use:

```text
My IP
```

for the SSH source.

---

## Step 5: Add User Data

Open **Advanced details** and find the **User data** section.

Paste:

```bash
#!/bin/bash
set -e

apt-get update -y
apt-get install -y nginx

cat > /var/www/html/index.html <<'EOF'
<!doctype html>
<html lang="en">
<head>
  <meta charset="utf-8">
  <title>My EC2 Web Server</title>
</head>
<body>
  <h1>Hello from Amazon EC2!</h1>
  <p>NGINX was installed automatically using User Data.</p>
</body>
</html>
EOF

systemctl enable nginx
systemctl restart nginx
```

---

## Step 6: Review the Configuration

Before launching, check:

- Correct AWS account
- Correct Region
- Correct AMI
- Correct processor architecture
- Suitable instance type
- Correct key pair
- SSH restricted to My IP
- HTTP port 80 open
- Public IPv4 enabled
- Encrypted EBS storage
- User Data added
- Expected cost understood

Select **Launch instance**.

---

## Step 7: Verify the Website

Wait for:

```text
Instance state: Running
Status checks: 2/2 checks passed
```

Copy the public IPv4 address and open:

```text
http://PUBLIC-IP-ADDRESS
```

The custom NGINX page should appear.

---

## Step 8: Connect Through SSH

Protect the private key:

```bash
chmod 400 abu-nginx-key.pem
```

Connect to the Ubuntu instance:

```bash
ssh -i abu-nginx-key.pem ubuntu@PUBLIC-IP-ADDRESS
```

The default username depends on the selected AMI.

For an Ubuntu AMI, it is commonly:

```text
ubuntu
```

---

## Step 9: Check NGINX

Check its status:

```bash
systemctl status nginx
```

Test the server locally:

```bash
curl http://localhost
```

View the custom page:

```bash
cat /var/www/html/index.html
```

Check which process is listening on port 80:

```bash
sudo ss -tulpn | grep :80
```

---

## Step 10: Clean Up

When the lab is complete:

1. Terminate the EC2 instance if it is no longer required.
2. Confirm whether the EBS volume was deleted.
3. Release unused Elastic IP addresses.
4. Delete unnecessary snapshots.
5. Remove unused security groups.
6. Check AWS Billing.
7. Check the AWS Budgets page.

---

# 45. EC2 Instance Purchasing Options

AWS offers different EC2 purchasing options.

The selected option affects:

- Price
- Commitment
- Flexibility
- Capacity
- Interruption risk
- Hardware isolation

---

## On-Demand Instances

On-Demand Instances allow customers to use EC2 without a long-term commitment.

### Advantages

- No upfront commitment
- Flexible
- Easy to start and stop
- Suitable for unpredictable workloads
- No interruption caused by AWS reclaiming Spot capacity

### Best For

- Short-term workloads
- Testing
- Development
- New applications
- Irregular workloads
- Applications that cannot be interrupted

### Disadvantage

On-Demand normally has a higher rate than commitment-based purchasing options.

> On-Demand is similar to paying the normal price whenever the server is used.

---

## Spot Instances

Spot Instances use unused AWS EC2 capacity at a discounted price.

AWS can interrupt a Spot Instance when it needs the capacity back.

### Advantages

- Can provide a large discount
- Useful for flexible workloads
- Suitable for workloads that can restart or move

### Best For

- Batch processing
- Data analysis
- Rendering
- Flexible CI/CD workers
- Distributed processing
- Fault-tolerant containers
- Testing at scale

### Disadvantages

- AWS can interrupt the instance.
- Capacity is not always available.
- Applications must be designed to tolerate interruption.

Avoid using Spot as the only capacity for an important workload that cannot be interrupted.

> Spot is cheaper because the customer accepts interruption risk.

---

## Savings Plans

Savings Plans provide lower prices in exchange for committing to a consistent amount of compute usage.

The commitment is measured in:

```text
Currency per hour
```

The commitment normally lasts:

- One year
- Three years

Savings Plans are useful for predictable, long-term compute usage.

### Advantages

- Lower price than standard On-Demand usage
- Can offer more flexibility than narrowly matched reservations
- Suitable for organisations with consistent compute usage

### Disadvantage

The customer makes a long-term financial commitment.

---

# 46. EC2 Instance Purchasing Options – Part 2

## Reserved Instances

Reserved Instances provide a billing discount when running EC2 usage matches the reservation requirements.

A Reserved Instance is not normally a separate physical server.

> Reserved Instances are mainly a pricing benefit, not a physical server waiting for the customer.

Reserved Instances normally use:

- A one-year term
- A three-year term

Types include:

- Standard Reserved Instances
- Convertible Reserved Instances

### Standard Reserved Instances

Provide a larger potential discount but less flexibility.

### Convertible Reserved Instances

Provide more flexibility to exchange the reservation for another eligible configuration but may offer a smaller discount.

### Best For

- Predictable long-term workloads
- Applications running continuously
- Workloads with stable instance requirements

AWS often recommends evaluating Savings Plans because they can provide a simpler and more flexible commitment model.

---

## On-Demand Capacity Reservations

An On-Demand Capacity Reservation reserves EC2 capacity inside a specific Availability Zone.

This is useful when an organisation must guarantee that capacity will be available.

### Important Difference

A Capacity Reservation focuses on:

```text
Capacity availability
```

A Reserved Instance or Savings Plan focuses mainly on:

```text
Pricing discounts
```

Unused Capacity Reservations may still generate charges.

---

## Dedicated Instances

Dedicated Instances run on hardware dedicated to a single AWS customer account.

However, the customer does not normally control the exact physical host.

They may be used when an organisation needs:

- Additional hardware isolation
- Particular compliance controls
- Single-tenant hardware

---

## Dedicated Hosts

A Dedicated Host is an entire physical EC2 server dedicated to one customer.

It provides visibility into areas such as:

- Physical sockets
- Physical cores
- Host placement

It may be useful for:

- Certain compliance requirements
- Server-bound software licences
- Bring-your-own-licence arrangements
- Applications requiring physical-host visibility

Dedicated Hosts are normally more expensive and are unnecessary for ordinary learning workloads.

---

## Capacity Blocks

Capacity Blocks allow customers to reserve supported accelerator capacity for a future period.

They are designed for eligible workloads such as:

- Machine-learning training
- High-performance computing
- GPU-intensive processing

---

## Purchasing Options Comparison

| Option | Main benefit | Main consideration |
| --- | --- | --- |
| On-Demand | Maximum flexibility | Normally higher price |
| Spot | Large potential discount | Can be interrupted |
| Savings Plans | Discount on predictable compute usage | One-year or three-year commitment |
| Reserved Instances | Discount for matching EC2 usage | One-year or three-year term |
| Capacity Reservation | Guaranteed capacity in an AZ | Unused capacity may still be charged |
| Dedicated Instance | Single-customer hardware | Higher cost |
| Dedicated Host | Dedicated physical server | Expensive and more specialised |
| Capacity Block | Reserved accelerator capacity | Limited to supported workloads |

---

## Example Purchasing Decisions

### Temporary Development Server

```text
On-Demand
```

Reason: The server may only be required for a short period.

### Fault-Tolerant Batch Processing

```text
Spot
```

Reason: The workload can restart if AWS interrupts the instance.

### Application Running Continuously for Several Years

```text
Savings Plan or Reserved Instance
```

Reason: Predictable usage may justify a long-term commitment.

### Application That Must Launch in a Particular Availability Zone

```text
Capacity Reservation
```

Reason: The priority is guaranteed capacity.

### Specialist Software Licensed Per Physical Server

```text
Dedicated Host
```

Reason: The customer may need visibility into the physical host.

---

# Security Groups and Cloud Networking Basics

A public EC2 web server depends on both security-group rules and correct VPC networking.

---

## Security Groups

A **security group** is a stateful virtual firewall that controls allowed traffic for associated AWS resources.

For EC2, the security group normally applies to the instance's network interface.

A security-group rule contains:

- Protocol
- Port or port range
- Source for inbound traffic
- Destination for outbound traffic
- Optional description

---

## Inbound and Outbound Traffic

| Direction | Meaning | Example |
| --- | --- | --- |
| Inbound | Traffic entering the instance | A browser sends a request to port 80 |
| Outbound | Traffic leaving the instance | Ubuntu downloads an NGINX package |

---

## Security Group Characteristics

- Security groups are stateful.
- Security groups contain allow rules.
- Security groups do not contain explicit deny rules.
- A resource can use more than one security group.
- Changes apply without rebooting the EC2 instance.
- Rules can reference IP ranges or other security groups.

### What Does Stateful Mean?

If an inbound request is allowed, the response traffic is automatically allowed.

For example:

1. A browser sends an allowed HTTP request to port 80.
2. The EC2 instance responds.
3. The security group automatically permits the response.

A separate outbound rule is not required specifically for that response.

---

## Common Ports

| Service | Protocol | Port | Recommended source |
| --- | --- | --- | --- |
| SSH | TCP | 22 | My IP or trusted management network |
| HTTP | TCP | 80 | Internet for a public website |
| HTTPS | TCP | 443 | Internet for a public secure website |
| RDP | TCP | 3389 | Trusted administrative IP only |
| MySQL | TCP | 3306 | Application security group |
| PostgreSQL | TCP | 5432 | Application security group |

Administrative and database ports should not normally be open to the entire internet.

---

## CIDR Examples

| CIDR | Meaning |
| --- | --- |
| `0.0.0.0/0` | Every IPv4 address |
| `::/0` | Every IPv6 address |
| `203.0.113.10/32` | One IPv4 address |
| `10.0.0.0/16` | A large private IPv4 network |

Opening SSH to:

```text
0.0.0.0/0
```

allows connection attempts from every IPv4 address.

For SSH, use:

```text
My IP
```

whenever possible.

---

## VPC Networking Components

| Component | Purpose |
| --- | --- |
| VPC | Logically isolated AWS network |
| Subnet | Range of addresses inside one Availability Zone |
| Route table | Determines where network traffic is sent |
| Internet gateway | Connects eligible VPC resources to the internet |
| NAT gateway | Allows private resources to start outbound IPv4 connections |
| Network interface | Virtual network card |
| Private IP | Address used inside the VPC |
| Public IP | Internet-routable address |
| Elastic IP | Static public IPv4 address |
| Security group | Stateful firewall |
| Network ACL | Stateless subnet-level traffic filter |

---

## Public and Private Subnets

### Public Subnet

A public subnet has a route to an internet gateway.

It can contain resources such as:

- Public web servers
- Internet-facing load balancers
- Bastion hosts

A resource still needs:

- A public address
- A route to the internet gateway
- Security rules allowing the traffic

### Private Subnet

A private subnet does not have a direct route to an internet gateway.

It commonly contains:

- Application servers
- Databases
- Internal services

A NAT gateway can allow resources in a private subnet to start outbound IPv4 connections without accepting direct inbound internet connections.

> A subnet is public because of its routing, not simply because an instance has a public IP address.

---

## How a Browser Reaches an EC2 Web Server

```text
User enters the EC2 public IP
            ↓
Request travels across the internet
            ↓
Internet gateway receives the traffic
            ↓
Route table directs it to the subnet
            ↓
Security group checks TCP port 80
            ↓
EC2 instance receives the request
            ↓
NGINX returns the webpage
```

For this to work:

1. The instance must be running.
2. NGINX must listen on port 80.
3. The security group must allow inbound TCP port 80.
4. The subnet must have a route to an internet gateway.
5. The instance must have a public address.
6. The network ACL must not block the traffic.

---

## Security Group vs Network ACL

| Security group | Network ACL |
| --- | --- |
| Applied to a resource or network interface | Applied to a subnet |
| Stateful | Stateless |
| Supports allow rules | Supports allow and deny rules |
| Return traffic is automatically allowed | Return traffic must be allowed |
| All rules are evaluated together | Rules are processed in numerical order |

---

# Useful AWS CLI Commands

Confirm the current AWS identity:

```bash
aws sts get-caller-identity
```

List EC2 instances in London:

```bash
aws ec2 describe-instances --region eu-west-2
```

Display a shorter summary:

```bash
aws ec2 describe-instances \
  --region eu-west-2 \
  --query 'Reservations[].Instances[].[InstanceId,InstanceType,State.Name,PublicIpAddress,Tags[?Key==`Name`].Value|[0]]' \
  --output table
```

List security groups:

```bash
aws ec2 describe-security-groups \
  --region eu-west-2 \
  --output table
```

Never use root-user access keys.

Never upload AWS credentials or private key files to GitHub.

---

# EC2 Troubleshooting

## Cannot Connect Through SSH

Check:

- The instance is running.
- Both status checks passed.
- The instance has a public IP address.
- Port 22 is allowed from the correct current IP.
- The correct username is being used.
- The correct private key is being used.
- The key has restricted filesystem permissions.
- The subnet has a route to an internet gateway.
- The network ACL permits the traffic.

For Ubuntu, the username is commonly:

```text
ubuntu
```

---

## Website Does Not Load

Check:

- The security group allows inbound TCP port 80.
- The browser is using `http://`.
- NGINX is running.
- User Data completed successfully.
- The instance has a public IP.
- The subnet is public.
- The route table uses an internet gateway.

Useful commands:

```bash
systemctl status nginx
```

```bash
curl http://localhost
```

```bash
sudo less /var/log/cloud-init-output.log
```

---

## Instance Appears to Be Missing

Check:

- The correct AWS account is selected.
- The correct Region is selected.
- Console filters have been removed.
- The instance has not been terminated.
- Search using the instance ID or Name tag.

---

# EC2 Cost and Security Checklist

- [ ] Confirm the correct AWS account.
- [ ] Confirm the correct AWS Region.
- [ ] Review the estimated instance cost.
- [ ] Check current Free Tier or credit eligibility.
- [ ] Use encrypted EBS volumes.
- [ ] Restrict SSH or RDP to a trusted source.
- [ ] Never put credentials inside User Data.
- [ ] Use an IAM role instead of stored access keys.
- [ ] Monitor the instance using CloudWatch.
- [ ] Stop or terminate unused instances.
- [ ] Remember that stopped instances can still create charges.
- [ ] Delete unused EBS volumes.
- [ ] Delete unnecessary snapshots.
- [ ] Release unused Elastic IP addresses.
- [ ] Review AWS Budgets.
- [ ] Review the Bills page.
- [ ] Never upload `.pem`, `.ppk`, `.env` or credential files to GitHub.

---

# EC2 Quick Revision Questions

1. What does EC2 stand for?
2. What is the difference between EC2 and an EC2 instance?
3. What is compute?
4. What is an AMI?
5. What does an instance type control?
6. What is an EBS volume?
7. What is right-sizing?
8. What is EC2 User Data?
9. What does bootstrapping mean?
10. When does User Data normally run?
11. Why should secrets not be placed in User Data?
12. Where can cloud-init output be checked?
13. What does `t3.micro` mean?
14. What are general-purpose instances used for?
15. What are compute-optimised instances used for?
16. What are memory-optimised instances used for?
17. What is vertical scaling?
18. What is horizontal scaling?
19. Which purchasing option has no long-term commitment?
20. Which option uses spare AWS capacity?
21. Why can Spot Instances be interrupted?
22. What is a Savings Plan?
23. Is a Reserved Instance a physical server?
24. What is a Capacity Reservation?
25. What is the difference between a pricing discount and a capacity guarantee?
26. What is a Dedicated Host?
27. What is a security group?
28. What does stateful mean?
29. Why should SSH not be open to `0.0.0.0/0`?
30. What makes a subnet public?
31. What components allow an internet user to reach an EC2 web server?
32. What resources can still generate charges when an instance is stopped?

---

# EC2 Key Takeaways

- Compute provides the processing power required to run applications.
- AWS offers virtual machines, containers, functions and other compute models.
- Amazon EC2 provides scalable virtual servers called instances.
- An EC2 launch combines an AMI, instance type, storage, networking and security.
- Right-sizing matches the server's capacity to the workload.
- User Data automates initial server configuration.
- User Data normally runs during the first boot.
- Instance families are designed for different workload types.
- Vertical scaling changes the size of one instance.
- Horizontal scaling adds or removes instances.
- On-Demand provides flexibility without a long-term commitment.
- Spot provides discounts but can be interrupted.
- Savings Plans and Reserved Instances reward long-term commitments.
- Capacity Reservations focus on capacity availability.
- Security groups are stateful virtual firewalls.
- A public web server needs correct routing, addressing and security rules.
- Stopped EC2 instances can still have storage and networking charges.
- AWS credentials and private keys must never be uploaded to GitHub.

---

# Official AWS References

- [Amazon EC2 documentation](https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/concepts.html)
- [EC2 launch parameters](https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/ec2-instance-launch-parameters.html)
- [EC2 instance types](https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/instance-types.html)
- [EC2 User Data](https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/user-data.html)
- [EC2 instance lifecycle](https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/ec2-instance-lifecycle.html)
- [EC2 purchasing options](https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/instance-purchasing-options.html)
- [VPC security groups](https://docs.aws.amazon.com/vpc/latest/userguide/vpc-security-groups.html)
- [Amazon VPC documentation](https://docs.aws.amazon.com/vpc/latest/userguide/what-is-amazon-vpc.html)
