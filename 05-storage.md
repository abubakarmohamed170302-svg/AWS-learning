# Storage

## Learning Objectives

By the end of these notes, I should be able to:

- Explain block, file and object storage.
- Describe how Amazon EBS works with EC2.
- Create, attach, format and mount an EBS volume.
- Compare the main EBS volume types.
- Explain the purpose of EBS snapshots.
- Explain what an Amazon Machine Image is.
- Create a reusable AMI from an EC2 instance.
- Compare an AMI with an EBS snapshot.
- Explain how Amazon EFS provides shared file storage.
- Mount an EFS file system on multiple EC2 instances.
- Compare EBS, EFS, S3 and Instance Store.
- Identify storage-related security and cost risks.

---

# Storage Types in AWS

Before looking at EBS and EFS, it is important to understand the three main types of cloud storage.

| Storage type | How it works | AWS example |
| --- | --- | --- |
| Block storage | Data is stored in fixed-sized blocks and presented like a disk | Amazon EBS |
| File storage | Data is organised into files and folders | Amazon EFS |
| Object storage | Data is stored as objects inside buckets | Amazon S3 |

---

## Block Storage

Block storage behaves like a hard drive attached to a computer.

The operating system can:

- Create a filesystem
- Create folders
- Store application files
- Install software
- Run a database
- Read and write individual blocks

AWS example:

```text
Amazon EBS
```

---

## File Storage

File storage provides a shared filesystem.

Multiple computers can access the same files and folders.

AWS example:

```text
Amazon EFS
```

---

## Object Storage

Object storage stores complete objects rather than presenting a normal operating-system disk.

AWS example:

```text
Amazon S3
```

Common uses include:

- Images
- Videos
- Backups
- Documents
- Log files
- Static website content

---

# 53. What Is an EBS Volume?

**EBS** stands for **Elastic Block Store**.

An **EBS volume** is a virtual block-storage device that can be attached to an EC2 instance.

> Think of EBS as a virtual hard drive for an EC2 server.

An EBS volume can contain:

- An operating system
- Application files
- Website files
- Databases
- Logs
- User data
- Configuration files

---

## EC2 and EBS Relationship

```text
EC2 instance = Virtual computer
EBS volume   = Virtual hard drive
```

An EC2 instance can have:

- One root EBS volume
- One or more additional data volumes

Example:

```text
Ubuntu EC2 instance
├── Root EBS volume: Operating system and NGINX
├── Data EBS volume: Website files
└── Data EBS volume: Application logs
```

---

## Root Volume

The **root volume** contains the operating system used to boot the instance.

For the previous lab:

```text
EC2 instance: nginx-networking-lab
Operating system: Ubuntu
Web server: NGINX
Root storage: EBS volume
```

The root volume normally contains directories such as:

```text
/etc
/home
/var
/usr
```

---

## Additional Data Volume

A separate EBS volume can be attached for application data.

Example:

```text
Root volume:
- Ubuntu
- NGINX
- System files

Data volume:
- Website uploads
- Application data
- Logs
```

Separating application data from the operating system can make storage management and recovery easier.

---

## Important EBS Characteristics

- EBS provides block storage.
- EBS volumes are used with EC2 instances.
- The data normally survives when an instance is stopped.
- A volume has a provisioned capacity.
- Volumes can be encrypted.
- Volumes can be backed up using snapshots.
- A volume can be detached and attached to another compatible instance.
- EBS volumes are created inside one Availability Zone.
- The EC2 instance and volume must be in the same Availability Zone.
- EBS storage can continue generating charges when an instance is stopped.

---

## Availability Zone Requirement

An EBS volume is tied to one Availability Zone.

Example:

```text
EC2 instance: eu-west-2a
EBS volume:   eu-west-2a
Result:       Can be attached
```

Incorrect example:

```text
EC2 instance: eu-west-2a
EBS volume:   eu-west-2b
Result:       Cannot be directly attached
```

To move data to another Availability Zone:

1. Create a snapshot of the volume.
2. Create a new EBS volume from the snapshot.
3. Select the destination Availability Zone.
4. Attach the new volume to an instance in that zone.

---

## EBS Replication

AWS automatically replicates an EBS volume within its Availability Zone.

This protects against the failure of a single underlying hardware component.

However, this does not replace:

- EBS snapshots
- Application backups
- Cross-Region backups
- Disaster-recovery planning

> Replication improves resilience, but a backup is still required.

---

## EBS Volume States

| State | Meaning |
| --- | --- |
| Creating | AWS is creating the volume |
| Available | The volume exists but is not attached |
| In use | The volume is attached to an EC2 instance |
| Deleting | The volume is being deleted |
| Deleted | The volume no longer exists |
| Error | The volume has experienced a problem |

---

## EBS Volume Types

AWS provides several EBS volume types for different workloads.

| Volume type | Storage | Best suited for |
| --- | --- | --- |
| `gp3` | General-purpose SSD | Most applications and learning environments |
| `gp2` | General-purpose SSD | Older general-purpose workloads |
| `io2` | Provisioned IOPS SSD | Critical databases requiring consistent high IOPS |
| `io1` | Provisioned IOPS SSD | Older high-performance transactional workloads |
| `st1` | Throughput-optimised HDD | Large sequential workloads and logs |
| `sc1` | Cold HDD | Infrequently accessed data |
| `standard` | Magnetic | Previous-generation workloads |

---

## General-Purpose SSD – `gp3`

`gp3` is a common choice for:

- Boot volumes
- Web servers
- Development environments
- Small and medium databases
- Application servers
- Virtual desktops

With `gp3`, storage capacity, IOPS and throughput can be configured more independently than with `gp2`.

It is normally a sensible starting choice for a learning EC2 instance.

---

## General-Purpose SSD – `gp2`

With `gp2`, performance is more closely linked to the volume’s storage capacity.

It is still supported but `gp3` is commonly preferred for new general-purpose workloads.

---

## Provisioned IOPS SSD

Provisioned IOPS volumes include:

```text
io1
io2
```

They are designed for workloads that require:

- High IOPS
- Low latency
- Consistent performance
- Database reliability

Common examples include:

- Large relational databases
- Critical transactional systems
- I/O-intensive applications

They normally cost more than general-purpose SSD volumes.

---

## Throughput-Optimised HDD – `st1`

`st1` is designed for large, sequential workloads.

Examples include:

- Log processing
- Big-data workloads
- Data warehouses
- Streaming large datasets

It is not designed for small, random read-and-write operations.

---

## Cold HDD – `sc1`

`sc1` is designed for:

- Infrequently accessed data
- Large sequential workloads
- Workloads where low cost is more important than performance

It is not suitable as an EC2 boot volume.

---

## IOPS and Throughput

### IOPS

**IOPS** stands for **input/output operations per second**.

It measures how many storage operations can be performed each second.

High IOPS is important for workloads involving many small, random operations.

Example:

```text
Transactional database
```

### Throughput

Throughput measures how much data can be transferred over time.

It is commonly measured in:

```text
MiB/s
```

High throughput is important for large sequential data transfers.

Example:

```text
Processing very large log files
```

---

## EBS Encryption

EBS volumes can be encrypted using AWS Key Management Service.

Encryption protects:

- Data stored on the volume
- Data moving between the volume and EC2
- Snapshots created from the volume
- Volumes created from encrypted snapshots

All current EBS volume types support encryption.

Keys can include:

- AWS-managed keys
- Customer-managed KMS keys

For most learning environments, the AWS-managed EBS key can be used.

---

## Delete on Termination

The **Delete on termination** setting controls whether a volume is automatically deleted when its EC2 instance is terminated.

The root volume is normally configured to be deleted on termination.

Additional data volumes may be configured to remain.

Always check the setting before terminating an instance.

### Example

```text
Root volume:
Delete on termination = Yes

Data volume:
Delete on termination = No
```

After terminating the instance:

```text
Root volume = Deleted
Data volume = Remains and continues generating charges
```

---

## Stop vs Terminate

### Stop the Instance

When an EBS-backed instance is stopped:

- The instance powers off.
- EBS volumes remain.
- Stored data remains.
- EBS storage charges continue.
- The instance can be started again.

### Terminate the Instance

When an instance is terminated:

- The instance is permanently deleted.
- Root volumes marked for deletion are deleted.
- Volumes not marked for deletion may remain.
- Remaining volumes continue generating charges.

---

## EBS Snapshots

An **EBS snapshot** is a point-in-time backup of an EBS volume.

Snapshots can be used to:

- Restore a deleted volume
- Create another volume
- Copy data to another Availability Zone
- Copy data to another Region
- Create an AMI
- Support disaster recovery

EBS snapshots are managed by AWS and stored using Amazon S3 infrastructure.

They do not appear inside a normal S3 bucket belonging to the user.

---

## Incremental Snapshots

EBS snapshots are incremental.

This means that after the first snapshot, later snapshots only need to save the blocks that changed.

Example:

```text
Snapshot 1:
Copies the volume's existing blocks

Snapshot 2:
Copies blocks changed since Snapshot 1

Snapshot 3:
Copies blocks changed since Snapshot 2
```

Deleting one snapshot does not automatically make later snapshots unusable. AWS manages the data required to restore each retained snapshot.

---

## EBS Attachment Rules

An EBS volume is normally attached to one EC2 instance at a time.

EBS Multi-Attach exists for supported `io1` and `io2` volumes and compatible Nitro-based instances in the same Availability Zone.

Multi-Attach is an advanced feature and requires an application and filesystem designed for shared block storage.

For normal shared storage between many instances, EFS is usually more suitable.

---

# EBS Volume Demo

This demo creates and mounts a new EBS data volume on `nginx-networking-lab`.

---

## Step 1: Check the Instance Availability Zone

1. Open the EC2 console.
2. Select `nginx-networking-lab`.
3. Open the **Details** tab.
4. Record its Availability Zone.

Example:

```text
eu-west-2a
```

The new EBS volume must be created in the same Availability Zone.

---

## Step 2: Create the Volume

1. Open **EC2**.
2. Select **Volumes**.
3. Select **Create volume**.
4. Choose the following example settings:

| Setting | Example |
| --- | --- |
| Volume type | `gp3` |
| Size | 8 GiB |
| Availability Zone | Same as the EC2 instance |
| Encryption | Enabled |
| Name tag | `nginx-data-volume` |

5. Select **Create volume**.

Wait until the volume state becomes:

```text
Available
```

---

## Step 3: Attach the Volume

1. Select `nginx-data-volume`.
2. Select **Actions**.
3. Select **Attach volume**.
4. Select `nginx-networking-lab`.
5. Select **Attach volume**.

The AWS console may display a device name such as:

```text
/dev/sdf
```

On a Nitro-based EC2 instance, Linux may display it as:

```text
/dev/nvme1n1
```

Always confirm the actual device name inside Linux.

---

## Step 4: Connect to the Instance

```bash
ssh -i abu-nginx-key.pem ubuntu@PUBLIC-IP-ADDRESS
```

---

## Step 5: List Storage Devices

```bash
lsblk
```

Example output:

```text
NAME         SIZE TYPE MOUNTPOINTS
nvme0n1        8G disk
└─nvme0n1p1    8G part /
nvme1n1        8G disk
```

In this example:

```text
nvme0n1 = Root volume
nvme1n1 = New data volume
```

> Confirm the correct device carefully. Formatting the wrong device can destroy data.

---

## Step 6: Check for an Existing Filesystem

```bash
sudo file -s /dev/nvme1n1
```

A new empty volume may return output containing:

```text
data
```

If the volume already contains a filesystem or important data, do not format it.

---

## Step 7: Create a Filesystem

For a new empty volume:

```bash
sudo mkfs -t ext4 /dev/nvme1n1
```

This creates an `ext4` filesystem.

Formatting destroys existing data on that volume.

---

## Step 8: Create a Mount Point

```bash
sudo mkdir -p /mnt/nginx-data
```

---

## Step 9: Mount the Volume

```bash
sudo mount /dev/nvme1n1 /mnt/nginx-data
```

Verify:

```bash
df -h
```

---

## Step 10: Create a Test File

```bash
echo "Hello from the EBS data volume" | sudo tee /mnt/nginx-data/ebs-test.txt
```

Read it:

```bash
cat /mnt/nginx-data/ebs-test.txt
```

Expected output:

```text
Hello from the EBS data volume
```

---

## Step 11: Make the Mount Persistent

A normal manual mount may disappear after reboot.

Find the filesystem UUID:

```bash
sudo blkid /dev/nvme1n1
```

Example:

```text
UUID="12345678-abcd-1234-abcd-1234567890ab"
```

Edit:

```bash
sudo nano /etc/fstab
```

Add:

```text
UUID=12345678-abcd-1234-abcd-1234567890ab /mnt/nginx-data ext4 defaults,nofail 0 2
```

Test the configuration:

```bash
sudo umount /mnt/nginx-data
sudo mount -a
df -h
```

The `nofail` option helps prevent a missing data volume from blocking the operating system’s boot process.

---

## Safely Detach an EBS Volume

Before detaching:

1. Stop applications using the volume.
2. Save pending data.
3. Unmount the filesystem.
4. Detach it through AWS.

Unmount:

```bash
sudo umount /mnt/nginx-data
```

Then use:

```text
EC2 → Volumes → Actions → Detach volume
```

Do not detach a volume while applications are actively writing to it.

---

## Useful EBS CLI Commands

List volumes in London:

```bash
aws ec2 describe-volumes \
  --region eu-west-2 \
  --output table
```

Create a `gp3` volume:

```bash
aws ec2 create-volume \
  --availability-zone eu-west-2a \
  --volume-type gp3 \
  --size 8 \
  --encrypted \
  --region eu-west-2
```

Attach a volume:

```bash
aws ec2 attach-volume \
  --volume-id VOLUME-ID \
  --instance-id INSTANCE-ID \
  --device /dev/sdf \
  --region eu-west-2
```

Create a snapshot:

```bash
aws ec2 create-snapshot \
  --volume-id VOLUME-ID \
  --description "Backup of nginx data volume" \
  --region eu-west-2
```

---

# 54. AMI Overview

**AMI** stands for **Amazon Machine Image**.

An AMI is a template used to launch EC2 instances.

Every EC2 instance must be launched from an AMI.

> An AMI is similar to a reusable blueprint for creating EC2 servers.

---

## What Can an AMI Contain?

An AMI can include:

- An operating system
- Installed applications
- System libraries
- Configuration files
- Application code
- Web-server configuration
- Monitoring software
- Security settings
- Block-device mappings

Example custom AMI:

```text
Ubuntu
+ NGINX
+ Company webpage
+ CloudWatch agent
+ Security updates
= Custom web-server AMI
```

New EC2 instances launched from this AMI already contain that configuration.

---

## Main AMI Components

An AMI includes:

| Component | Purpose |
| --- | --- |
| Root volume template | Contains the operating system and installed software |
| Block-device mapping | Defines storage attached during instance launch |
| Launch permissions | Controls which AWS accounts can use the AMI |
| Architecture and boot information | Defines compatible instance configuration |

For an EBS-backed AMI, the volume templates are normally stored as EBS snapshots.

---

## Types of AMIs

### AWS-Provided AMI

Created and maintained by AWS.

Examples:

- Amazon Linux
- Supported Windows Server images

### Vendor AMI

Created by an operating-system or software vendor.

Example:

```text
Canonical Ubuntu AMI
```

### AWS Marketplace AMI

Provided through AWS Marketplace.

It may contain:

- Commercial software
- Security tools
- Preconfigured applications
- Additional licence charges

### Community AMI

Shared publicly by another AWS user or organisation.

Community AMIs should be treated carefully because their contents and security may not be trusted.

### Custom AMI

Created from an EC2 instance belonging to the organisation.

Example:

```text
nginx-golden-ami-v1
```

---

## AMI Selection Criteria

Before selecting an AMI, check:

- Operating system
- Publisher
- AMI ID
- AWS Region
- Processor architecture
- Root-device type
- Virtualisation type
- Creation date
- Installed software
- Licence cost
- Security and maintenance status

---

## Processor Architecture

Common AMI architectures include:

```text
x86_64
arm64
```

The AMI architecture must match the selected instance type.

Example:

```text
ARM64 AMI + Graviton instance = Compatible
ARM64 AMI + x86-only instance = Not compatible
```

---

## AMIs Are Regional

An AMI belongs to one AWS Region.

An AMI created in:

```text
Europe (London) – eu-west-2
```

is not automatically available in:

```text
Europe (Ireland) – eu-west-1
```

To use it in another Region, copy the AMI to that Region.

The copied AMI receives a different AMI ID.

---

## AMI IDs

Each AMI has an identifier beginning with:

```text
ami-
```

Example:

```text
ami-0123456789abcdef0
```

AMI IDs can differ between:

- AWS Regions
- Operating-system versions
- Processor architectures
- AMI releases

Do not assume an AMI ID from one Region will work in another.

---

## Public, Private and Shared AMIs

| AMI visibility | Meaning |
| --- | --- |
| Public | Available to AWS customers |
| Private | Available only to the owning AWS account |
| Shared | Made available to selected AWS accounts |

A custom AMI is private by default.

Avoid making an AMI public unless its contents have been reviewed carefully.

An AMI can accidentally contain:

- Passwords
- SSH private keys
- API tokens
- Application secrets
- Customer information
- Command history
- Sensitive log files

---

## AMI vs EBS Snapshot

| AMI | EBS snapshot |
| --- | --- |
| Used to launch an EC2 instance | Used to back up an EBS volume |
| Contains boot and launch information | Contains volume block data |
| Can reference one or more snapshots | Represents one volume backup |
| Includes launch permissions | Does not define a complete EC2 launch |
| Acts as a server template | Acts as a storage backup |

> An AMI is a complete launch template. A snapshot is a point-in-time volume backup.

---

## AMI vs User Data

| AMI | User Data |
| --- | --- |
| Software is already included in the image | Software is installed during first boot |
| Can launch more quickly | Setup takes place after launch |
| Must be updated and rebuilt | Script can be updated before launch |
| Useful for consistent server templates | Useful for flexible bootstrapping |
| Can become outdated | Downloads current packages at launch |

These methods can also be combined.

Example:

```text
AMI:
Ubuntu + NGINX + monitoring agent

User Data:
Downloads the latest application version and environment configuration
```

---

## Golden AMI

A **golden AMI** is an approved, reusable image containing a standard server configuration.

It may contain:

- Approved operating-system version
- Required security patches
- Monitoring agents
- Logging software
- Standard users and permissions
- Required application dependencies

Golden AMIs help create consistent servers.

However, they must be:

- Updated
- Patched
- Tested
- Versioned
- Replaced when outdated

---

# AMI Demo

This demo creates a reusable AMI from `nginx-networking-lab`.

---

## Step 1: Prepare the Instance

Connect to the server:

```bash
ssh -i abu-nginx-key.pem ubuntu@PUBLIC-IP-ADDRESS
```

Check NGINX:

```bash
sudo systemctl status nginx
```

Check the website:

```bash
curl http://localhost
```

Remove unnecessary sensitive information before creating the AMI.

---

## Step 2: Create the Image

1. Open the EC2 console.
2. Select `nginx-networking-lab`.
3. Select **Actions**.
4. Select **Image and templates**.
5. Select **Create image**.

Enter:

```text
Image name: nginx-golden-ami-v1
Description: Ubuntu and NGINX learning server image
```

Review the block-device mappings.

AWS normally reboots the instance during image creation to improve filesystem consistency.

The console may provide a no-reboot option, but creating an image without rebooting can increase the risk of an inconsistent filesystem.

---

## Step 3: Monitor the AMI

Open:

```text
EC2 → Images → AMIs
```

The AMI moves through states such as:

```text
Pending → Available
```

Do not attempt to launch it until its state is:

```text
Available
```

---

## Step 4: Launch a New Instance

1. Select `nginx-golden-ami-v1`.
2. Select **Launch instance from AMI**.
3. Name the instance:

```text
nginx-from-custom-ami
```

4. Select a compatible instance type.
5. Select the correct key pair.
6. Configure the VPC and subnet.
7. Attach the web-server security group.
8. Launch the instance.

---

## Step 5: Verify the New Server

After the instance passes both status checks, open:

```text
http://NEW-PUBLIC-IP
```

Because NGINX was included in the AMI, the server should already contain the installed web-server files.

Connect through SSH and verify:

```bash
sudo systemctl status nginx
```

---

## AMI Lifecycle

A custom AMI can move through the following lifecycle:

```text
Create
  ↓
Use
  ↓
Copy or share
  ↓
Deprecate or disable
  ↓
Deregister
  ↓
Delete associated snapshots
```

---

## Deregistering an AMI

Deregistering an AMI prevents new instances from being launched from it.

It does not terminate EC2 instances already launched from that AMI.

Associated snapshots can continue generating charges.

When the AMI is no longer needed:

1. Deregister the AMI.
2. Identify its associated snapshots.
3. Delete snapshots that are no longer required.
4. Check AWS Billing.

AWS can optionally delete associated snapshots while deregistering, but snapshots referenced by other AMIs are retained.

---

## Useful AMI CLI Commands

List owned AMIs:

```bash
aws ec2 describe-images \
  --owners self \
  --region eu-west-2 \
  --output table
```

Create an AMI:

```bash
aws ec2 create-image \
  --instance-id INSTANCE-ID \
  --name "nginx-golden-ami-v1" \
  --description "Ubuntu and NGINX learning server image" \
  --region eu-west-2
```

Copy an AMI to another Region:

```bash
aws ec2 copy-image \
  --source-region eu-west-2 \
  --source-image-id SOURCE-AMI-ID \
  --name "nginx-golden-ami-v1-copy" \
  --region eu-west-1
```

Deregister an AMI:

```bash
aws ec2 deregister-image \
  --image-id AMI-ID \
  --region eu-west-2
```

---

# 55. Amazon EFS – Elastic File System

**EFS** stands for **Elastic File System**.

Amazon EFS provides serverless, fully elastic file storage that can be shared by multiple compute resources.

> Think of EFS as a shared network drive that several Linux servers can use at the same time.

---

## EFS Example

Imagine three EC2 web servers:

```text
Web server 1
Web server 2
Web server 3
```

Each server needs access to the same uploaded images.

If every server uses only its own EBS volume, the files are separate.

With EFS:

```text
Web server 1 ─┐
Web server 2 ─┼── Amazon EFS ── Shared images
Web server 3 ─┘
```

Every server can access the same files.

---

## EFS Characteristics

- EFS provides file storage.
- It uses the Network File System protocol.
- It can be mounted by multiple clients.
- It automatically grows as files are added.
- It automatically shrinks as files are removed.
- There is no need to provision a fixed filesystem size.
- It is designed mainly for Linux workloads.
- Regional EFS can provide access across multiple Availability Zones.
- EFS can be used with EC2, ECS, EKS and supported Lambda workloads.
- Storage charges are based mainly on the data stored and selected storage class.

---

## NFS

EFS uses **NFS**, which stands for **Network File System**.

NFS allows a remote filesystem to be mounted as though it were a local directory.

Example mount point:

```text
/mnt/efs
```

Applications can access files through paths such as:

```text
/mnt/efs/uploads/image.jpg
```

---

## EFS Mount Targets

A **mount target** provides an NFS endpoint inside a VPC.

A mount target contains:

- A network interface
- A private IP address
- A subnet
- A security group

For a Regional EFS file system, a mount target can be created in each required Availability Zone.

Example:

```text
eu-west-2a → EFS mount target
eu-west-2b → EFS mount target
eu-west-2c → EFS mount target
```

An EC2 instance should normally use the mount target in the same Availability Zone.

---

## Regional EFS

Regional EFS stores data redundantly across multiple Availability Zones.

It is suitable when:

- High availability is important
- Instances run in several Availability Zones
- The filesystem must tolerate an Availability Zone failure

---

## EFS One Zone

EFS One Zone stores data within one Availability Zone.

It normally costs less but does not provide the same multi-AZ resilience as Regional EFS.

One Zone supports one mount target in the filesystem’s Availability Zone.

It may be suitable for:

- Development environments
- Reproducible data
- Workloads with separate backups
- Workloads that do not require multi-AZ resilience

---

## EFS Storage Classes

EFS storage classes can include:

| Storage class | Use |
| --- | --- |
| EFS Standard | Frequently accessed files |
| EFS Infrequent Access | Files accessed less frequently |
| EFS Archive | Long-lived data accessed rarely |
| EFS One Zone | Frequently accessed data stored in one AZ |
| EFS One Zone-IA | Infrequently accessed data stored in one AZ |

Availability and pricing should be checked for the selected AWS Region.

---

## EFS Lifecycle Management

Lifecycle management can automatically move files between storage classes based on access patterns.

Example:

```text
Frequently used file
        ↓
Not accessed for selected period
        ↓
EFS Infrequent Access
        ↓
Rarely accessed for longer period
        ↓
EFS Archive
```

This can reduce storage cost.

Accessing files in lower-cost storage classes may create additional access charges.

---

## EFS Performance and Throughput

EFS provides different performance and throughput options.

Throughput options can include:

- Elastic throughput
- Bursting throughput
- Provisioned throughput

### Elastic Throughput

Automatically adjusts throughput based on workload activity.

### Bursting Throughput

Performance scales partly with the amount of data stored, with the ability to burst.

### Provisioned Throughput

Allows a specific throughput level to be configured independently of storage size.

The suitable option depends on the workload and current AWS service configuration.

---

## EFS Security

EFS security can include:

- VPC security groups
- NFS permissions
- POSIX users and groups
- Encryption at rest
- Encryption in transit
- IAM authorisation
- EFS access points
- Backup policies

---

## EFS Security-Group Rule

The EFS mount target’s security group should allow:

```text
Type: NFS
Protocol: TCP
Port: 2049
Source: EC2 client security group
```

Example:

```text
EC2 instances:
Security group = efs-client-sg

EFS mount targets:
Security group = efs-mount-target-sg
```

Inbound rule on `efs-mount-target-sg`:

```text
NFS
TCP 2049
Source: efs-client-sg
```

Do not normally open NFS port 2049 to:

```text
0.0.0.0/0
```

---

## EFS Access Points

An EFS access point provides an application-specific entry point into an EFS filesystem.

It can enforce:

- A root directory
- A POSIX user
- A POSIX group
- Directory permissions

Example:

```text
Application A access point:
Root directory = /application-a

Application B access point:
Root directory = /application-b
```

This helps separate applications using the same filesystem.

---

# EFS Demo

This demo creates an EFS filesystem and mounts it on EC2.

---

## Demo Architecture

```text
EC2 instance in eu-west-2a
          ↓ NFS TCP 2049
EFS mount target in eu-west-2a
          ↓
Regional EFS filesystem
          ↑
EFS mount target in eu-west-2b
          ↑ NFS TCP 2049
EC2 instance in eu-west-2b
```

---

## Step 1: Create the Client Security Group

Create:

```text
Name: efs-client-sg
Description: Security group for EC2 clients using EFS
```

Attach it to the EC2 instances that need EFS access.

---

## Step 2: Create the EFS Security Group

Create:

```text
Name: efs-mount-target-sg
Description: Allows NFS from approved EC2 instances
```

Add this inbound rule:

| Type | Protocol | Port | Source |
| --- | --- | ---: | --- |
| NFS | TCP | 2049 | `efs-client-sg` |

---

## Step 3: Create the File System

1. Open the AWS console.
2. Search for **EFS**.
3. Select **Create file system**.
4. Enter:

```text
Name: aws-learning-efs
Region: Europe (London)
VPC: Same VPC as the EC2 instances
```

5. Select Regional storage for the multi-AZ example.
6. Enable encryption.
7. Configure mount targets in the required Availability Zones.
8. Attach `efs-mount-target-sg` to the mount targets.
9. Create the filesystem.

Wait until its lifecycle state becomes:

```text
Available
```

---

## Step 4: Connect to the EC2 Instance

```bash
ssh -i abu-nginx-key.pem ubuntu@PUBLIC-IP-ADDRESS
```

---

## Step 5: Create a Mount Directory

```bash
sudo mkdir -p /mnt/efs
```

---

## Step 6: Install the Required Client

The AWS EFS mount helper is the recommended option because it supports features such as encryption in transit.

Install `amazon-efs-utils` by following the current AWS instructions for the selected Ubuntu version.

Alternatively, an NFS client can be installed for a basic lab:

```bash
sudo apt-get update -y
sudo apt-get install -y nfs-common
```

---

## Step 7: Mount Using the EFS Mount Helper

When `amazon-efs-utils` is installed:

```bash
sudo mount -t efs -o tls FILE-SYSTEM-ID:/ /mnt/efs
```

Example structure:

```bash
sudo mount -t efs -o tls fs-0123456789abcdef0:/ /mnt/efs
```

The `tls` option enables encryption in transit.

---

## Alternative NFS Mount

For a basic NFS lab:

```bash
sudo mount -t nfs4 \
  -o nfsvers=4.1,rsize=1048576,wsize=1048576,hard,timeo=600,retrans=2,noresvport \
  FILE-SYSTEM-ID.efs.eu-west-2.amazonaws.com:/ \
  /mnt/efs
```

The EFS console’s **Attach** option provides commands for the selected filesystem and Region.

---

## Step 8: Confirm the Mount

```bash
df -h
```

```bash
mount | grep efs
```

---

## Step 9: Create a Shared File

```bash
echo "Hello from Abubakar's EFS filesystem" | sudo tee /mnt/efs/shared-file.txt
```

Read it:

```bash
cat /mnt/efs/shared-file.txt
```

---

## Step 10: Test from Another EC2 Instance

Mount the same EFS filesystem on a second EC2 instance.

Then run:

```bash
cat /mnt/efs/shared-file.txt
```

Expected output:

```text
Hello from Abubakar's EFS filesystem
```

This proves that both EC2 instances can access the same shared file.

---

## Step 11: Mount EFS After Reboot

When using the EFS mount helper, add the following to `/etc/fstab`:

```text
FILE-SYSTEM-ID:/ /mnt/efs efs _netdev,tls 0 0
```

The `_netdev` option tells Linux that this is a network filesystem.

Test it carefully:

```bash
sudo umount /mnt/efs
sudo mount -a
df -h
```

---

## Clean Up EFS

When the lab is complete:

1. Unmount EFS from each EC2 instance.
2. Remove unnecessary `/etc/fstab` entries.
3. Delete the EFS mount targets.
4. Delete the EFS filesystem if it is no longer needed.
5. Delete unused security groups.
6. Review AWS Billing.

Unmount:

```bash
sudo umount /mnt/efs
```

Deleting an EFS filesystem permanently deletes the data it contains.

---

# EBS vs EFS vs S3 vs Instance Store

| Feature | EBS | EFS | S3 | Instance Store |
| --- | --- | --- | --- | --- |
| Storage model | Block | File | Object | Block |
| Main connection | Attached to EC2 | Mounted over NFS | Accessed using API/HTTP | Physically attached to host |
| Shared access | One instance normally | Many clients | Many clients | One instance |
| Availability scope | One Availability Zone | Regional or One Zone | Regional service | Physical EC2 host |
| Capacity | Provisioned | Automatically scales | Automatically scales | Fixed by instance type |
| Persistence | Independent of running state | Persistent | Persistent | Temporary |
| Common use | OS, applications, databases | Shared Linux files | Backups, media and objects | Cache and temporary data |
| Filesystem required | Yes | Already a filesystem | No traditional mounted filesystem | Yes |
| Backup option | EBS snapshots | AWS Backup and replication | Versioning and replication | Copy data elsewhere |

---

## When to Choose EBS

Use EBS when:

- One EC2 instance needs a disk.
- The operating system needs block storage.
- A database needs low-latency block access.
- A boot volume is required.
- The application expects a normal local filesystem.
- Storage performance must be provisioned.

---

## When to Choose EFS

Use EFS when:

- Multiple Linux instances need the same files.
- An Auto Scaling group needs shared content.
- A container workload needs persistent shared files.
- Storage should grow and shrink automatically.
- Applications require NFS.
- Shared web uploads must be available across servers.

---

## When to Choose S3

Use S3 when:

- Applications store objects.
- Files need to be accessed through APIs.
- Large-scale backup storage is needed.
- Static content must be stored.
- Data lakes or archives are required.
- A traditional mounted block disk is unnecessary.

---

## When to Choose Instance Store

Use Instance Store when:

- Extremely fast temporary storage is required.
- The data can be recreated.
- The data is a cache or temporary working file.
- Data loss during stop, termination or host failure is acceptable.

Never use Instance Store as the only location for important data.

---

# Storage Troubleshooting

## EBS Volume Will Not Attach

Check:

- The volume and instance are in the same Availability Zone.
- The volume is in the `Available` state.
- The correct volume was selected.
- The instance supports the required attachment.
- The account has not reached a service quota.

---

## EBS Volume Does Not Appear in Linux

Run:

```bash
lsblk
```

```bash
sudo nvme list
```

Check:

- The volume is attached in AWS.
- The correct device name is being used.
- The operating system has detected the device.

Nitro instances may display a different Linux device name from the one selected in the AWS console.

---

## EBS Volume Does Not Mount

Check:

- A filesystem exists.
- The correct device is selected.
- The mount directory exists.
- The `/etc/fstab` entry is correct.
- The UUID is correct.
- The volume is not already mounted elsewhere.

Commands:

```bash
sudo file -s DEVICE-NAME
```

```bash
sudo blkid
```

```bash
sudo mount -a
```

---

## AMI Is Missing

Check:

- The correct AWS Region is selected.
- The AMI is in the `Available` state.
- The console is showing **Owned by me**.
- The AMI has not been deregistered.
- The current identity has permission to view it.

---

## Instance Will Not Launch from AMI

Check:

- The AMI architecture matches the instance type.
- The AMI exists in the selected Region.
- Associated snapshots are available.
- The current account has launch permission.
- Required KMS permissions exist for encrypted snapshots.
- The selected instance type supports the AMI configuration.

---

## EFS Will Not Mount

Check:

- The filesystem is available.
- A mount target exists in the VPC.
- The EC2 instance can reach the mount target.
- The EFS security group allows TCP port 2049.
- The rule references the correct EC2 security group.
- VPC DNS resolution is enabled.
- The correct filesystem ID is used.
- The NFS or EFS client is installed.
- The mount directory exists.
- Network ACLs permit the traffic.

Test DNS:

```bash
nslookup FILE-SYSTEM-ID.efs.eu-west-2.amazonaws.com
```

Test port 2049:

```bash
nc -zv FILE-SYSTEM-ID.efs.eu-west-2.amazonaws.com 2049
```

---

# Storage Cost and Security Checklist

- [ ] Select the correct EBS volume type.
- [ ] Avoid provisioning unnecessary storage.
- [ ] Enable EBS encryption.
- [ ] Review the Delete-on-termination setting.
- [ ] Snapshot important EBS volumes.
- [ ] Delete unused EBS volumes.
- [ ] Delete unnecessary EBS snapshots.
- [ ] Remember that stopped instances still have EBS charges.
- [ ] Remove secrets before creating an AMI.
- [ ] Keep custom AMIs private unless sharing is required.
- [ ] Deregister unused AMIs.
- [ ] Delete unneeded AMI snapshots.
- [ ] Enable EFS encryption at rest.
- [ ] Use TLS for EFS traffic.
- [ ] Restrict NFS port 2049 to approved security groups.
- [ ] Use EFS lifecycle policies where appropriate.
- [ ] Delete unused EFS filesystems and mount targets.
- [ ] Check storage resources in every Region.
- [ ] Review AWS Budgets and Billing.

---

# Storage Quick Revision Questions

1. What does EBS stand for?
2. What type of storage does EBS provide?
3. How is an EBS volume similar to a physical hard drive?
4. What is the difference between a root and data volume?
5. Must an EBS volume and EC2 instance be in the same Availability Zone?
6. Does EBS data survive when an instance is stopped?
7. What does Delete on termination control?
8. What is the difference between IOPS and throughput?
9. What is `gp3` commonly used for?
10. What workloads are `io2` volumes designed for?
11. What is an EBS snapshot?
12. Are EBS snapshots incremental?
13. How can EBS data be moved to another Availability Zone?
14. Can a normal EBS volume be attached to several instances?
15. What does AMI stand for?
16. What information can an AMI contain?
17. Why must an AMI architecture match the instance type?
18. Are AMIs Regional or global?
19. What is a golden AMI?
20. What is the difference between an AMI and an EBS snapshot?
21. What is the difference between an AMI and User Data?
22. Does deregistering an AMI terminate existing instances?
23. Why can AMI snapshots continue generating charges?
24. What does EFS stand for?
25. What type of storage does EFS provide?
26. Which protocol does EFS use?
27. Can several EC2 instances mount one EFS filesystem?
28. What is an EFS mount target?
29. Which port does NFS use?
30. What is the difference between Regional and One Zone EFS?
31. Does EFS require a fixed storage capacity?
32. What is EFS lifecycle management?
33. What is an EFS access point?
34. When should EBS be selected instead of EFS?
35. When should EFS be selected instead of EBS?
36. What happens to Instance Store data when an instance stops?
37. Why should NFS port 2049 not be open to the entire internet?

---

# Storage Key Takeaways

- EBS provides persistent block storage for EC2.
- An EBS volume behaves like a virtual hard drive.
- EBS volumes belong to one Availability Zone.
- An EC2 instance and its EBS volume must be in the same Availability Zone.
- EBS volumes can survive when an instance is stopped.
- EBS storage continues generating charges while an instance is stopped.
- `gp3` is a common general-purpose SSD option.
- EBS volumes should be encrypted.
- EBS snapshots provide point-in-time volume backups.
- AMIs are reusable templates used to launch EC2 instances.
- An AMI can include an operating system, software and configuration.
- AMIs are Regional resources.
- A golden AMI provides a standard approved server image.
- Deregistering an AMI does not terminate existing EC2 instances.
- AMI snapshots may remain and continue generating charges.
- EFS provides elastic shared file storage.
- EFS uses the NFS protocol.
- Several compute resources can mount the same EFS filesystem.
- EFS automatically grows and shrinks with its stored files.
- Regional EFS supports multi-AZ architectures.
- EFS One Zone stores data in one Availability Zone.
- NFS uses TCP port 2049.
- Security groups should restrict EFS access to approved clients.
- EBS is normally used as a disk for one instance.
- EFS is used when several instances need shared files.
- S3 stores objects rather than providing a normal block device.
- Instance Store is temporary and should not hold the only copy of important data.

---

# Official AWS References

- [What is Amazon EBS?](https://docs.aws.amazon.com/ebs/latest/userguide/what-is-ebs.html)
- [EBS volume features](https://docs.aws.amazon.com/ebs/latest/userguide/EBSFeatures.html)
- [EBS volume types](https://docs.aws.amazon.com/ebs/latest/userguide/ebs-volume-types.html)
- [Create an EBS volume](https://docs.aws.amazon.com/ebs/latest/userguide/ebs-creating-volume.html)
- [Attach an EBS volume](https://docs.aws.amazon.com/ebs/latest/userguide/ebs-attaching-volume.html)
- [EBS encryption](https://docs.aws.amazon.com/ebs/latest/userguide/ebs-encryption.html)
- [EBS snapshots](https://docs.aws.amazon.com/ebs/latest/userguide/ebs-snapshots.html)
- [Amazon EBS pricing](https://aws.amazon.com/ebs/pricing/)
- [Amazon EC2 AMI lifecycle](https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/ami-lifecycle.html)
- [Create an EBS-backed AMI](https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/creating-an-ami-ebs.html)
- [Copy an AMI](https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/CopyingAMIs.html)
- [Deregister an AMI](https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/deregister-ami.html)
- [What is Amazon EFS?](https://docs.aws.amazon.com/efs/latest/ug/whatisefs.html)
- [How Amazon EFS works](https://docs.aws.amazon.com/efs/latest/ug/how-it-works.html)
- [EFS mount targets](https://docs.aws.amazon.com/efs/latest/ug/accessing-fs.html)
- [EFS security groups](https://docs.aws.amazon.com/efs/latest/ug/network-access.html)
- [Amazon EFS pricing](https://aws.amazon.com/efs/pricing/)
