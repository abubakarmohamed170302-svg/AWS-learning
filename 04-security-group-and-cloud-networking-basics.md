# Security Groups and Cloud Networking Basics

## Learning Objectives

By the end of these notes, I should be able to:

- Explain what a security group is.
- Configure inbound and outbound security-group rules.
- Explain why security groups are described as stateful.
- Compare security groups with Network ACLs.
- Reference one security group from another.
- Recognise important networking ports.
- Explain the difference between IPv4 and IPv6.
- Explain public and private IPv4 addresses.
- Describe how EC2 public IPv4 addressing works.
- Allocate, associate, disassociate and release an Elastic IP.
- Decide when an Elastic IP should or should not be used.

---

# 39. Introduction to Security Groups

A **security group** is a stateful virtual firewall used to control allowed network traffic for AWS resources.

Security groups are commonly associated with:

- EC2 instances
- Elastic network interfaces
- Load balancers
- RDS databases
- Other supported AWS resources

For an EC2 instance, the security group is applied to its network interface.

> A security group does not protect the entire AWS account. It controls traffic for the resources associated with it.

---

## Why Are Security Groups Needed?

An EC2 instance could run several network services.

For example:

| Service | Port |
| --- | ---: |
| SSH | 22 |
| HTTP | 80 |
| HTTPS | 443 |
| MySQL | 3306 |

A security group determines which of these services can be reached and where the traffic can come from.

For example:

```text
Allow SSH on port 22 from my IP address
Allow HTTP on port 80 from the internet
Allow HTTPS on port 443 from the internet
Block all other unsolicited inbound traffic
```

---

## Inbound and Outbound Traffic

Security groups control two directions of traffic.

| Direction | Meaning | Example |
| --- | --- | --- |
| Inbound | Traffic entering the resource | A browser sends an HTTP request |
| Outbound | Traffic leaving the resource | EC2 downloads an Ubuntu package |

### Inbound Example

A user visits an NGINX website:

```text
User → EC2 instance
```

The security group needs an inbound rule allowing the website’s port.

For HTTP:

```text
Protocol: TCP
Port: 80
Source: 0.0.0.0/0
```

### Outbound Example

An Ubuntu server downloads an NGINX package:

```text
EC2 instance → Ubuntu package repository
```

The security group needs to permit the required outbound traffic.

---

## Security Group Rule Components

A security-group rule normally contains:

| Component | Meaning |
| --- | --- |
| Type | Common service such as SSH or HTTP |
| Protocol | Network protocol such as TCP, UDP or ICMP |
| Port range | Port or ports covered by the rule |
| Source | Where inbound traffic can come from |
| Destination | Where outbound traffic can go |
| Description | Explanation of why the rule exists |

---

## Example Inbound Rules

| Type | Protocol | Port | Source | Purpose |
| --- | --- | ---: | --- | --- |
| SSH | TCP | 22 | My IP | Administrative access |
| HTTP | TCP | 80 | `0.0.0.0/0` | Public IPv4 website access |
| HTTPS | TCP | 443 | `0.0.0.0/0` | Secure public IPv4 access |
| HTTPS | TCP | 443 | `::/0` | Secure public IPv6 access |

---

## What Does `0.0.0.0/0` Mean?

```text
0.0.0.0/0
```

means every IPv4 address.

Using it as the source means traffic can come from anywhere on the IPv4 internet.

This may be appropriate for:

- HTTP port 80 on a public website
- HTTPS port 443 on a public website

It is normally unsafe for:

- SSH port 22
- RDP port 3389
- Database ports
- Administrative interfaces

For SSH, select:

```text
My IP
```

where possible.

---

## What Does `::/0` Mean?

```text
::/0
```

means every IPv6 address.

An IPv4 rule using:

```text
0.0.0.0/0
```

does not automatically allow IPv6.

A separate IPv6 rule is required.

---

## Default Behaviour

A newly created security group normally:

- Has no inbound rules
- Allows outbound IPv4 traffic by default
- May also allow outbound IPv6 traffic when IPv6 is configured

With no inbound rules, unsolicited inbound traffic is not allowed.

The **default security group** created with a VPC has special default rules, including inbound communication from resources using that same default security group.

It is better to create purpose-specific security groups than rely on the default security group.

Examples:

```text
public-web-sg
application-sg
database-sg
management-sg
```

---

# 40. Security Groups Deeper Dive

## Security Groups Are Stateful

Security groups are **stateful**.

This means they remember allowed connections.

If an inbound request is allowed, its response is automatically allowed to leave.

### Example

A browser sends an HTTP request:

```text
Browser → EC2 port 80
```

If the inbound HTTP request is permitted:

```text
EC2 → Browser response
```

is automatically permitted.

A separate outbound rule is not required specifically for that response.

The same behaviour works in the opposite direction.

If an instance starts an allowed outbound connection, the response is automatically allowed back in.

---

## Security Groups Only Contain Allow Rules

Security groups support:

```text
Allow
```

They do not support explicit deny rules.

If no rule allows the traffic, the traffic is blocked.

```text
Matching allow rule = permitted
No matching allow rule = blocked
```

If an explicit network deny is required, other controls may be used, such as:

- Network ACLs
- AWS Network Firewall
- Host-based firewalls
- Application access controls

---

## All Rules Are Evaluated Together

Security-group rules do not have a numbered priority order.

AWS evaluates all applicable security groups and rules together.

If one applicable rule allows the traffic, the security-group layer permits it.

### Example

An EC2 network interface has two security groups.

```text
Security group 1: Allow SSH from My IP
Security group 2: Allow HTTP from the internet
```

The instance receives both allowed permissions:

```text
SSH from My IP
HTTP from the internet
```

Attaching an extra security group cannot be used to remove access already allowed by another security group.

---

## Security Groups and Connection Tracking

Because security groups are stateful, they track information about network connections.

This is why return traffic can pass without a separate rule.

For example:

1. EC2 starts an outbound HTTPS connection on port 443.
2. The remote server responds.
3. The response is allowed back to EC2.
4. A separate inbound rule for the temporary return port is not required.

Network ACLs are stateless, so their return traffic may need separate rules.

---

## Security Groups vs Network ACLs

| Security group | Network ACL |
| --- | --- |
| Applied to a network interface or supported resource | Applied to an entire subnet |
| Stateful | Stateless |
| Supports allow rules | Supports allow and deny rules |
| Evaluates all rules together | Processes rules in numerical order |
| Return traffic is automatically allowed | Return traffic must be permitted |
| Commonly used as the main resource firewall | Often used as an additional subnet control |

Security groups should normally be the main method of controlling access to EC2 resources.

---

## Security Group Scope

Security groups belong to:

- One AWS Region
- One VPC

A security group created in `eu-west-2` cannot be directly attached to an instance in another Region.

A security group from one VPC cannot normally be attached to a resource in another VPC.

---

## Security Group Changes

Security-group rules can be changed while the instance is running.

Changes normally apply without:

- Stopping the instance
- Restarting the instance
- Rebooting the operating system

However, changing a rule can immediately affect active and new connections.

---

# 41. Security Groups

Security groups should be designed around the purpose of the resource.

---

## Public Web-Server Security Group

Example:

```text
Name: nginx-web-sg
Description: Allows public web access and restricted SSH
VPC: Default VPC
Region: eu-west-2
```

### Inbound Rules

| Type | Protocol | Port | Source | Reason |
| --- | --- | ---: | --- | --- |
| SSH | TCP | 22 | My IP | Connect to the Ubuntu server |
| HTTP | TCP | 80 | `0.0.0.0/0` | Public IPv4 website |
| HTTPS | TCP | 443 | `0.0.0.0/0` | Public secure IPv4 website |

If IPv6 is configured, separate IPv6 rules can be added:

| Type | Protocol | Port | Source |
| --- | --- | ---: | --- |
| HTTP | TCP | 80 | `::/0` |
| HTTPS | TCP | 443 | `::/0` |

---

## Database Security Group

A database should not normally allow connections from the entire internet.

Unsafe example:

```text
PostgreSQL
TCP 5432
Source: 0.0.0.0/0
```

Safer example:

```text
PostgreSQL
TCP 5432
Source: application-sg
```

This allows database connections from resources associated with the application security group.

---

## Least Privilege

The principle of least privilege means allowing only the traffic required for the application.

Ask:

1. Which protocol is required?
2. Which port is required?
3. Which source needs access?
4. Does the rule need to be permanent?
5. Can access be limited to another security group?
6. Is public access actually required?

### Poor Rule

```text
All traffic
All protocols
All ports
Source: 0.0.0.0/0
```

### Better Rules

```text
SSH
TCP 22
Source: My IP
```

```text
HTTP
TCP 80
Source: 0.0.0.0/0
```

---

## Useful Rule Descriptions

Security-group descriptions should explain why a rule exists.

Good examples:

```text
Allow SSH from Abubakar's home IP
Allow HTTP traffic to the public NGINX lab
Allow PostgreSQL connections from application servers
Temporary access for testing – remove after lab
```

Avoid unclear descriptions such as:

```text
test
rule1
needed
allow
```

---

## Host Firewall vs Security Group

An EC2 instance may also have a firewall inside its operating system.

Examples include:

- `ufw`
- `iptables`
- `nftables`
- Windows Defender Firewall

For traffic to reach an application, every layer must allow it.

```text
Network route
      ↓
Network ACL
      ↓
Security group
      ↓
Operating-system firewall
      ↓
Listening application
```

A correct security-group rule does not help if NGINX is stopped or the operating-system firewall blocks port 80.

---

# 42. Security Groups – Good to Know

## Security Groups Are Attached to Network Interfaces

Security groups are associated with elastic network interfaces rather than directly with the EC2 operating system.

An EC2 instance’s primary network interface is commonly called:

```text
eth0
```

or represented in AWS as an **Elastic Network Interface**, also called an **ENI**.

---

## Multiple Security Groups

A network interface can have multiple security groups.

The allowed rules are combined.

Example:

| Security group | Allowed traffic |
| --- | --- |
| `management-sg` | SSH from administrator IP |
| `web-sg` | HTTP and HTTPS from users |
| `monitoring-sg` | Monitoring traffic from monitoring servers |

The resource receives the combined allowed access.

---

## Security Groups Do Not Filter Every Type of Traffic

Security groups are designed for traffic reaching and leaving supported network interfaces.

They are not a replacement for:

- Identity and Access Management
- Application authentication
- Data encryption
- Web application firewalls
- Operating-system security
- Network monitoring

A security group allowing HTTPS does not decide which user can sign in to the application.

---

## Ping Uses ICMP

The `ping` command does not use a TCP or UDP port.

It normally uses:

```text
ICMP
```

To allow IPv4 ping requests, a rule such as the following may be required:

```text
Type: Echo Request – IPv4
Protocol: ICMP
Source: Trusted IP range
```

Opening port 80 does not allow ping.

A failed ping also does not automatically mean that the server is unavailable because ICMP may simply be blocked.

---

## Security Groups Do Not Open Applications

A security-group rule only permits traffic to reach a resource.

The application must also be running and listening on the correct port.

For a website to work:

```text
Security group allows TCP 80
                +
NGINX is running on TCP 80
                =
HTTP website can respond
```

Check listening ports with:

```bash
sudo ss -tulpn
```

Check NGINX:

```bash
sudo systemctl status nginx
```

---

## SSH Source IP Can Change

A home or mobile internet connection may receive a different public IP address later.

If SSH worked previously but stops working:

1. Check the current public IP.
2. Open the EC2 security group.
3. Update the SSH source.
4. Continue restricting it to a single trusted IP.

Do not solve the problem by permanently opening SSH to:

```text
0.0.0.0/0
```

---

## Rule Changes Can Affect Access Immediately

Deleting an SSH rule while connected may prevent new SSH connections.

Before changing administrative rules:

- Confirm another secure access method exists.
- Check the correct source IP.
- Avoid removing the only management path accidentally.
- Consider Systems Manager Session Manager.

---

# 43. Referencing Other Security Groups

A security-group rule can use another security group as its source or destination.

This is often safer and easier to manage than entering individual IP addresses.

---

## Three-Tier Application Example

Consider an application with:

1. A load balancer
2. EC2 application servers
3. A database

Create three security groups:

```text
load-balancer-sg
application-sg
database-sg
```

### Load Balancer Security Group

```text
Inbound:
HTTPS TCP 443 from 0.0.0.0/0
```

### Application Security Group

```text
Inbound:
Application port TCP 8080 from load-balancer-sg
```

### Database Security Group

```text
Inbound:
PostgreSQL TCP 5432 from application-sg
```

The traffic path becomes:

```text
Internet
   ↓ HTTPS 443
Load balancer
   ↓ TCP 8080
Application servers
   ↓ PostgreSQL 5432
Database
```

---

## What a Security-Group Reference Means

Suppose this rule is added to `database-sg`:

```text
Type: PostgreSQL
Port: 5432
Source: application-sg
```

This permits PostgreSQL traffic from network interfaces associated with `application-sg`.

The rule does not copy all the rules from `application-sg`.

It only uses membership of `application-sg` to identify the permitted source resources.

---

## What Referencing Does Not Do

Referencing another security group does not:

- Copy its rules
- Automatically allow every port
- Automatically allow traffic in both directions
- Automatically create a network route
- Allow traffic when no application is listening
- Replace subnet and routing requirements

The protocol and port must still be specified.

---

## Why References Are Better Than Fixed Private IPs

Instances may be:

- Replaced
- Scaled
- Assigned new IP addresses
- Added to an Auto Scaling group

If the rule references `application-sg`, new application instances using that group can access the database without adding every private IP manually.

---

## Security-Group Reference Example

```text
Frontend instance:
Security group = frontend-sg

Backend instance:
Security group = backend-sg
```

Add this inbound rule to `backend-sg`:

```text
Type: Custom TCP
Port: 8080
Source: frontend-sg
```

Result:

- Resources using `frontend-sg` can connect to backend port 8080.
- The general internet cannot connect unless another rule permits it.
- Other EC2 instances cannot connect unless they match an allowed source.

---

# 44. Classic Ports to Know

A **port** identifies a network service running on a computer.

The range is:

```text
0–65535
```

Ports from `0–1023` are commonly known as well-known ports.

---

## Most Important Ports to Memorise

| Service | Port | Protocol | Purpose |
| --- | ---: | --- | --- |
| FTP data | 20 | TCP | Traditional FTP data transfer |
| FTP control | 21 | TCP | Traditional FTP commands |
| SSH | 22 | TCP | Secure remote Linux access |
| SFTP | 22 | TCP | File transfer through SSH |
| Telnet | 23 | TCP | Insecure remote access |
| SMTP | 25 | TCP | Email transfer |
| DNS | 53 | TCP/UDP | Domain-name resolution |
| HTTP | 80 | TCP | Unencrypted web traffic |
| POP3 | 110 | TCP | Retrieve email |
| NTP | 123 | UDP | Time synchronisation |
| IMAP | 143 | TCP | Access email |
| LDAP | 389 | TCP/UDP | Directory services |
| HTTPS | 443 | TCP | Encrypted web traffic |
| SMB | 445 | TCP | Windows file sharing |
| SMTPS | 465 | TCP | Encrypted SMTP |
| SMTP submission | 587 | TCP | Submit outgoing email |
| LDAPS | 636 | TCP | Encrypted LDAP |
| IMAPS | 993 | TCP | Encrypted IMAP |
| POP3S | 995 | TCP | Encrypted POP3 |

---

## Database and Application Ports

| Service | Port | Purpose |
| --- | ---: | --- |
| Microsoft SQL Server | 1433 | Microsoft database |
| Oracle Database | 1521 | Oracle database |
| NFS | 2049 | Network File System |
| MySQL or MariaDB | 3306 | MySQL-compatible database |
| RDP | 3389 | Remote Windows access |
| PostgreSQL | 5432 | PostgreSQL database |
| Redis | 6379 | In-memory database and cache |
| HTTP alternative | 8080 | Applications and development servers |
| Elasticsearch | 9200 | Elasticsearch HTTP API |

---

## Secure and Insecure Protocols

| Less secure | More secure alternative |
| --- | --- |
| HTTP port 80 | HTTPS port 443 |
| Telnet port 23 | SSH port 22 |
| FTP ports 20–21 | SFTP port 22 |
| LDAP port 389 | LDAPS port 636 |
| POP3 port 110 | POP3S port 995 |
| IMAP port 143 | IMAPS port 993 |

In production, encrypted protocols should be used whenever possible.

---

# Security Groups Demo 1

This demo uses the Ubuntu NGINX instance from the previous EC2 lab.

---

## Demo Goal

Create a security group that:

- Allows SSH only from my public IP
- Allows HTTP from internet users
- Blocks other unsolicited inbound traffic

---

## Step 1: Create the Security Group

1. Open the AWS Management Console.
2. Select **Europe (London) – `eu-west-2`**.
3. Open **EC2**.
4. Select **Security Groups**.
5. Select **Create security group**.

Enter:

```text
Security group name: nginx-web-sg
Description: Security group for the NGINX EC2 lab
VPC: Same VPC as the EC2 instance
```

---

## Step 2: Configure Inbound Rules

Add:

| Type | Protocol | Port | Source |
| --- | --- | ---: | --- |
| SSH | TCP | 22 | My IP |
| HTTP | TCP | 80 | `0.0.0.0/0` |

If the VPC and instance use IPv6, also add:

| Type | Protocol | Port | Source |
| --- | --- | ---: | --- |
| HTTP | TCP | 80 | `::/0` |

---

## Step 3: Attach the Security Group

1. Open **EC2 Instances**.
2. Select `nginx-networking-lab`.
3. Select **Actions**.
4. Select **Security**.
5. Select **Change security groups**.
6. Attach `nginx-web-sg`.
7. Save the changes.

Before removing an existing security group, confirm that the replacement contains all required access.

---

## Step 4: Test HTTP

Copy the instance’s public IP and open:

```text
http://PUBLIC-IP-ADDRESS
```

The page should display:

```text
Hello from Amazon EC2!
```

---

## Step 5: Test the HTTP Rule

Temporarily remove the inbound HTTP rule.

Refresh the webpage.

The connection should fail or time out because the security group no longer allows inbound port 80.

Add the HTTP rule again and refresh the browser.

The website should become reachable again.

---

## Step 6: Test SSH

Connect using:

```bash
ssh -i abu-nginx-key.pem ubuntu@PUBLIC-IP-ADDRESS
```

SSH should work from the IP listed in the security-group rule.

It should not be available from unrelated public IP addresses.

---

# Security Groups Demo 2

This demo shows how one security group can reference another.

---

## Demo Architecture

```text
Frontend EC2 instance
Security group: frontend-sg
          ↓ TCP 8080
Backend EC2 instance
Security group: backend-sg
```

---

## Step 1: Create `frontend-sg`

Example inbound rules:

| Type | Port | Source |
| --- | ---: | --- |
| SSH | 22 | My IP |
| HTTP | 80 | `0.0.0.0/0` |

---

## Step 2: Create `backend-sg`

Add:

| Type | Port | Source |
| --- | ---: | --- |
| Custom TCP | 8080 | `frontend-sg` |

Do not add:

```text
TCP 8080 from 0.0.0.0/0
```

The backend service should only be reachable from resources using `frontend-sg`.

---

## Step 3: Run a Test Service on the Backend

On the backend server:

```bash
mkdir -p ~/backend-demo
cd ~/backend-demo
echo "Hello from the private backend server" > index.html
python3 -m http.server 8080 --bind 0.0.0.0
```

The Python service listens on TCP port 8080.

---

## Step 4: Find the Backend Private IP

In the EC2 console, select the backend instance and copy its private IPv4 address.

Example:

```text
10.0.1.25
```

---

## Step 5: Test from the Frontend

Connect to the frontend instance and run:

```bash
curl http://BACKEND-PRIVATE-IP:8080
```

Expected response:

```text
Hello from the private backend server
```

This works because:

- The frontend uses `frontend-sg`.
- The backend allows TCP 8080 from `frontend-sg`.
- Both instances have a valid network route.
- The backend application listens on port 8080.

---

## Step 6: Test from an Unauthorised Source

A resource that is not associated with `frontend-sg` should not be able to connect to backend port 8080 unless another rule permits it.

This demonstrates group-based access instead of public access or fixed IP rules.

---

# 47. IPv4 vs IPv6

An **IP address** identifies a network interface so that data can be sent to and from it.

The two major versions are:

- IPv4
- IPv6

---

## IPv4

IPv4 uses a 32-bit address.

Example:

```text
192.0.2.10
```

It contains four decimal sections separated by dots.

Each section ranges from:

```text
0–255
```

The total IPv4 address space contains approximately:

```text
4.3 billion addresses
```

Because the number of devices has grown, public IPv4 addresses are limited.

Technologies such as NAT are used to allow many devices to share fewer public IPv4 addresses.

---

## IPv6

IPv6 uses a 128-bit address.

Example:

```text
2001:db8:1234:5678:abcd:ef01:2345:6789
```

IPv6 uses hexadecimal characters:

```text
0–9
a–f
```

IPv6 addresses can be shortened by removing unnecessary zeros.

Example:

```text
2001:0db8:0000:0000:0000:0000:0000:0010
```

can become:

```text
2001:db8::10
```

---

## IPv4 and IPv6 Comparison

| IPv4 | IPv6 |
| --- | --- |
| 32-bit address | 128-bit address |
| Around 4.3 billion addresses | Extremely large address space |
| Decimal notation | Hexadecimal notation |
| Example: `192.0.2.10` | Example: `2001:db8::10` |
| NAT is common | NAT is less commonly required |
| Public IPv4 addresses are limited | Designed to solve address exhaustion |
| Uses `0.0.0.0/0` for every IPv4 address | Uses `::/0` for every IPv6 address |

---

## Dual-Stack Networking

A dual-stack network supports both:

- IPv4
- IPv6

An EC2 instance in a dual-stack subnet may have:

- A private IPv4 address
- A public IPv4 address
- One or more IPv6 addresses

Applications should be tested over both protocols.

---

## IPv6 Security

A globally routable IPv6 address does not mean the instance is automatically open to the internet.

The following must still permit the traffic:

- Route table
- Internet gateway
- Security group
- Network ACL
- Operating-system firewall
- Application

IPv4 security-group rules do not automatically apply to IPv6.

Example:

```text
HTTP from 0.0.0.0/0
```

allows every IPv4 source but not IPv6.

To permit IPv6 HTTP:

```text
HTTP from ::/0
```

must also be added.

---

## Egress-Only Internet Gateway

For IPv6, an **egress-only internet gateway** can allow instances to start outbound internet connections without accepting unsolicited inbound connections.

It provides an outbound-only internet path for IPv6 resources.

It is conceptually similar to the outbound protection a NAT gateway provides for private IPv4 resources, although it does not perform address translation.

---

# 48. Private vs Public IP – IPv4 Example

An EC2 instance normally receives a private IPv4 address from its subnet.

It may also receive a public IPv4 address.

Example:

```text
Private IPv4: 10.0.1.25
Public IPv4: 18.130.50.20
```

The addresses serve different purposes.

---

## Private IPv4 Address

A private IP is used for communication inside private networks such as a VPC.

Common private IPv4 ranges are:

| Range | CIDR |
| --- | --- |
| `10.0.0.0–10.255.255.255` | `10.0.0.0/8` |
| `172.16.0.0–172.31.255.255` | `172.16.0.0/12` |
| `192.168.0.0–192.168.255.255` | `192.168.0.0/16` |

Private IPv4 addresses are not directly routable across the public internet.

---

## Public IPv4 Address

A public IPv4 address can be reached through internet routing when:

- The instance is in a public subnet.
- The route table has a route to an internet gateway.
- The security group permits the traffic.
- The network ACL permits the traffic.
- The instance has a public IPv4 address.
- The application is running.

---

## EC2 Public IPv4 Mapping

For an EC2 instance, the public IPv4 address is mapped to the instance’s primary private IPv4 address.

The operating system normally sees its private IP address.

The internet gateway performs the required address translation.

### Incoming Traffic

```text
Internet user
      ↓
Public IPv4 address
      ↓
Internet gateway mapping
      ↓
Private IPv4 address
      ↓
EC2 instance
```

### Outgoing Traffic

```text
EC2 private IPv4
      ↓
Internet gateway mapping
      ↓
Public IPv4
      ↓
Internet
```

---

## Practical Example

The NGINX instance has:

```text
Private IP: 10.0.1.25
Public IP: 18.130.50.20
```

Another EC2 instance in the same VPC can access NGINX using:

```text
http://10.0.1.25
```

An internet user accesses it using:

```text
http://18.130.50.20
```

Both addresses reach the same EC2 instance through different network paths.

---

# 49. Private vs Public IPv4 Differences

| Private IPv4 | Public IPv4 |
| --- | --- |
| Used inside the VPC | Used for internet communication |
| Not directly internet-routable | Internet-routable |
| Assigned from the subnet CIDR | Assigned from a public IPv4 pool |
| Normally remains after stop and start | Auto-assigned address can change after stop and start |
| Released when the network interface is deleted | Released when disassociated or replaced |
| Does not need to be globally unique | Must be globally unique |
| No separate public IPv4 charge | AWS charges for public IPv4 usage |

---

## What Happens When EC2 Stops and Starts?

For an ordinary EBS-backed instance:

### Private IPv4

The primary private IPv4 address normally remains the same after:

```text
Stop → Start
```

### Auto-Assigned Public IPv4

The normal public IPv4 address is released when the instance stops.

A different public IPv4 address is normally assigned when the instance starts again.

Example:

```text
Before stop: 18.130.50.20
After start:  35.178.90.14
```

This can break systems that depend on the previous public IP.

---

## What Happens During a Reboot?

A reboot normally keeps:

- Private IPv4 address
- Public IPv4 address
- Elastic IP address

A reboot is different from stopping and starting the instance.

---

## Public IP Does Not Automatically Mean Publicly Reachable

An instance can have a public IP and still be unreachable.

It also needs:

- A route to an internet gateway
- An allowed security-group rule
- An allowed Network ACL
- A running application
- A correctly configured operating-system firewall

> Public IP addressing provides a possible internet path. Security rules determine whether the traffic is allowed.

---

# 50. Elastic IPs

An **Elastic IP address**, also called an **EIP**, is a static public IPv4 address allocated to an AWS account.

Unlike an automatically assigned public IPv4 address, an Elastic IP does not normally change when the associated EC2 instance is stopped and started.

---

## Elastic IP Characteristics

- It is a static public IPv4 address.
- It is allocated to an AWS account.
- It belongs to one AWS Region.
- It remains allocated until it is released.
- It can be associated with an EC2 instance.
- It can be associated with a network interface.
- It can be moved to another compatible resource.
- AWS does not provide Elastic IP addresses for IPv6.
- It generates public IPv4 charges while allocated.

---

## Elastic IP Lifecycle

```text
Allocate Elastic IP
        ↓
Associate with EC2 instance or ENI
        ↓
Use the static public address
        ↓
Disassociate when no longer needed
        ↓
Release from the AWS account
```

---

## Allocate vs Associate

### Allocate

Allocating an Elastic IP reserves the address for the AWS account.

It does not automatically attach it to an EC2 instance.

### Associate

Associating the Elastic IP connects it to:

- An EC2 instance
- A network interface
- A private IPv4 address on a network interface

---

## Disassociate vs Release

### Disassociate

Disassociating removes the Elastic IP from the resource, but the address remains allocated to the AWS account.

Charges can continue.

### Release

Releasing returns the Elastic IP to AWS.

After release:

- The account no longer controls it.
- It may later be allocated to another AWS customer.
- The old address should not be treated as recoverable.

---

## Important Elastic IP Rules

- An Elastic IP is Region-specific.
- It cannot be moved directly from London to another Region.
- It cannot be converted from an existing auto-assigned public IP.
- Associating an EIP replaces an instance’s existing auto-assigned public IPv4.
- The previous auto-assigned public IPv4 is returned to AWS.
- A disassociated EIP remains allocated until it is released.
- Releasing an EIP is different from disassociating it.
- DNS records may need updating if the address changes.

---

## Elastic IP Cost Warning

AWS charges for public IPv4 addresses, including Elastic IP addresses.

At AWS’s currently listed rate:

```text
$0.005 per public IPv4 address per hour
```

Approximate 30-day example:

```text
$0.005 × 24 hours × 30 days = $3.60
```

Pricing can change, so always check the current AWS VPC pricing page.

Release unused Elastic IPs immediately after a lab.

---

# 51. Elastic IP Demo

This demo attaches a static public IPv4 address to the NGINX EC2 instance.

---

## Before Starting

Confirm:

- Correct AWS account
- Region is `eu-west-2`
- The EC2 instance is running
- The instance hosts NGINX
- The security group permits HTTP
- The cost of public IPv4 usage is understood
- The Elastic IP will be released after the lab

---

## Step 1: Record the Current Public IP

Open the EC2 instance details and record:

```text
Current public IPv4: PUBLIC-IP-ADDRESS
Private IPv4: PRIVATE-IP-ADDRESS
```

Open the existing public IP in a browser and confirm the NGINX page works.

---

## Step 2: Allocate an Elastic IP

1. Open the **EC2 console**.
2. Select **Elastic IPs**.
3. Select **Allocate Elastic IP address**.
4. Select the Amazon IPv4 address pool.
5. Select **Allocate**.

AWS displays:

- Elastic IP address
- Allocation ID
- Region
- Association status

The address is now allocated but not necessarily associated.

---

## Step 3: Associate the Elastic IP

1. Select the new Elastic IP.
2. Select **Actions**.
3. Select **Associate Elastic IP address**.
4. Select **Instance**.
5. Select `nginx-networking-lab`.
6. Select the private IP address.
7. Select **Associate**.

---

## Step 4: Verify the Address

Open:

```text
http://ELASTIC-IP-ADDRESS
```

The NGINX page should appear.

The EC2 details should now show the Elastic IP as its public IPv4 address.

---

## Step 5: Test Stop and Start

1. Stop the EC2 instance.
2. Wait for it to stop.
3. Start it again.
4. Wait for both status checks.
5. Check the public IP.

The Elastic IP should remain the same.

This is different from a normal auto-assigned public IPv4 address.

Remember that stopping the instance does not remove the EIP charge.

---

## Step 6: Disassociate the Elastic IP

1. Open **Elastic IPs**.
2. Select the address.
3. Select **Actions**.
4. Select **Disassociate Elastic IP address**.
5. Confirm the action.

The address remains allocated to the account and can continue generating charges.

---

## Step 7: Release the Elastic IP

1. Select the disassociated Elastic IP.
2. Select **Actions**.
3. Select **Release Elastic IP addresses**.
4. Confirm the release.

Only release the address after confirming it is no longer needed.

---

## Elastic IP AWS CLI Commands

Allocate an Elastic IP:

```bash
aws ec2 allocate-address \
  --domain vpc \
  --region eu-west-2
```

List allocated Elastic IPs:

```bash
aws ec2 describe-addresses \
  --region eu-west-2 \
  --output table
```

Associate the address:

```bash
aws ec2 associate-address \
  --instance-id INSTANCE-ID \
  --allocation-id ALLOCATION-ID \
  --region eu-west-2
```

Disassociate the address:

```bash
aws ec2 disassociate-address \
  --association-id ASSOCIATION-ID \
  --region eu-west-2
```

Release the address:

```bash
aws ec2 release-address \
  --allocation-id ALLOCATION-ID \
  --region eu-west-2
```

Always verify the identifiers before releasing an address.

---

# 52. When to Use Elastic IPs

Elastic IPs can be useful when a resource requires a stable public IPv4 address.

---

## Suitable Use Cases

### IP Allowlisting

A third-party system may only permit requests from approved IP addresses.

An Elastic IP provides a stable source or destination address.

Example:

```text
Partner firewall allows only 18.130.50.20
```

### Legacy Applications

An older application may require a fixed public IPv4 address rather than a DNS name.

### Fast Remapping

An Elastic IP can be moved from one failed EC2 instance to another replacement instance.

### Fixed Outbound Address

A NAT gateway uses Elastic IP addressing to provide a predictable public IPv4 address for outbound connections.

This is useful when external services allowlist the organisation’s outgoing IP.

### Small Learning or Testing Environment

An Elastic IP can make testing easier when an instance must keep the same address across stop and start operations.

It should still be released when the lab is complete.

---

## When Not to Use an Elastic IP

An Elastic IP is not always the best solution.

Avoid relying on one EIP when:

- An application uses Auto Scaling.
- Several servers need load balancing.
- DNS can provide the required stable name.
- High availability is required.
- A managed service can handle addressing.
- The address is only required temporarily.
- IPv6 can meet the requirement.

---

## Alternatives to Elastic IPs

| Requirement | Possible solution |
| --- | --- |
| Stable website name | Route 53 DNS |
| Distribute traffic across EC2 instances | Application Load Balancer |
| Scale across several instances | Auto Scaling group |
| Global static entry-point addresses | AWS Global Accelerator |
| Deliver cached web content globally | CloudFront |
| Fixed outbound IPv4 | NAT gateway with Elastic IP |
| Private administrative access | Systems Manager Session Manager |

---

## Elastic IP Does Not Provide High Availability by Itself

Attaching an Elastic IP to one EC2 instance does not make the application highly available.

The instance can still fail.

High availability normally requires:

- Multiple instances
- Multiple Availability Zones
- Health checks
- Load balancing
- Auto Scaling
- Automated failover

An Elastic IP can be remapped, but the failover process must still be designed and managed.

---

# Security Group Troubleshooting

## Website Does Not Load

Check:

- Is the instance running?
- Has it passed both status checks?
- Does it have a public IPv4 or IPv6 address?
- Does the subnet route to an internet gateway?
- Does the security group allow TCP port 80 or 443?
- Does the Network ACL allow the traffic?
- Is NGINX running?
- Is the operating-system firewall blocking the port?
- Is the browser using the correct protocol?

Commands:

```bash
sudo systemctl status nginx
```

```bash
curl http://localhost
```

```bash
sudo ss -tulpn
```

---

## SSH Does Not Work

Check:

- TCP port 22 is allowed.
- The rule uses the current public IP.
- The correct private key is used.
- The correct username is used.
- The instance has a working network path.
- The key permissions are restricted.
- The instance is running.

Ubuntu example:

```bash
chmod 400 abu-nginx-key.pem
ssh -i abu-nginx-key.pem ubuntu@PUBLIC-IP-ADDRESS
```

---

## Security-Group Reference Does Not Work

Check:

- The source resource is associated with the referenced group.
- The destination uses the correct security group.
- The correct protocol and port are configured.
- The application is listening on that port.
- The resources have a valid network route.
- Network ACLs are not blocking the traffic.
- The correct VPC and Region are being used.
- The connection uses the expected private address.

---

## Elastic IP Does Not Work

Check:

- The address is associated with the correct instance.
- The instance is running.
- The EIP belongs to the correct Region.
- The security group permits the traffic.
- The subnet routes to an internet gateway.
- The application is running.
- DNS points to the correct address.

---

# Security and Cost Checklist

- [ ] Give every security group a meaningful name.
- [ ] Add descriptions to rules.
- [ ] Allow only required protocols and ports.
- [ ] Restrict SSH and RDP to trusted sources.
- [ ] Do not expose databases to `0.0.0.0/0`.
- [ ] Use security-group references between application layers.
- [ ] Remove temporary rules after testing.
- [ ] Remember that multiple security groups combine their allow rules.
- [ ] Check both IPv4 and IPv6 rules.
- [ ] Confirm the instance is listening on the expected port.
- [ ] Use HTTPS instead of HTTP in production.
- [ ] Monitor traffic using VPC Flow Logs where appropriate.
- [ ] Check every Region for unused Elastic IPs.
- [ ] Disassociate and release unused Elastic IPs.
- [ ] Remember that public IPv4 addresses generate charges.
- [ ] Review AWS Budgets and Billing.

---

# Quick Revision Questions

1. What is a security group?
2. What is the difference between inbound and outbound traffic?
3. What does `0.0.0.0/0` mean?
4. What does `::/0` mean?
5. Why are security groups described as stateful?
6. Do security groups support explicit deny rules?
7. What happens when several security groups are attached?
8. Can a security group from London be attached in another Region?
9. Do security-group changes require an EC2 reboot?
10. What is the difference between a security group and a Network ACL?
11. Why should SSH not normally be open to the internet?
12. Which protocol does ping commonly use?
13. Does opening a security-group port start the application?
14. What does referencing another security group mean?
15. Why can group references be better than fixed private IPs?
16. Which port is used by SSH?
17. Which ports are used by HTTP and HTTPS?
18. Which port is used by RDP?
19. Which ports are used by MySQL and PostgreSQL?
20. What is the difference between IPv4 and IPv6?
21. Does an IPv4 rule automatically allow IPv6?
22. What is dual-stack networking?
23. What is an egress-only internet gateway?
24. What are the three private IPv4 ranges?
25. What is the difference between a private and public IPv4 address?
26. What happens to an auto-assigned public IP after stop and start?
27. What happens to the primary private IP after stop and start?
28. What is an Elastic IP address?
29. What is the difference between allocating and associating an EIP?
30. What is the difference between disassociating and releasing an EIP?
31. Does AWS provide Elastic IPs for IPv6?
32. When should an Elastic IP be used?
33. Why does an Elastic IP not provide high availability by itself?
34. What alternatives can be used instead of an Elastic IP?
35. Why should unused public IPv4 addresses be released?

---

# Key Takeaways

- Security groups are stateful virtual firewalls.
- They control allowed inbound and outbound traffic.
- Security groups support allow rules but not explicit deny rules.
- Return traffic for an allowed connection is automatically permitted.
- Multiple attached security groups combine their allowed rules.
- Security groups can reference other security groups.
- Group references are useful for multi-tier applications.
- SSH uses port 22.
- HTTP uses port 80.
- HTTPS uses port 443.
- RDP uses port 3389.
- IPv4 uses 32-bit addresses.
- IPv6 uses 128-bit addresses.
- IPv4 and IPv6 require separate security-group rules.
- Private IPv4 addresses are used inside private networks.
- Public IPv4 addresses provide internet-routable addressing.
- Auto-assigned public IPv4 addresses can change after stop and start.
- Elastic IPs are static public IPv4 addresses.
- Elastic IPs are Region-specific.
- Elastic IPs do not exist for IPv6.
- Disassociating an EIP does not release it.
- Public IPv4 addresses generate hourly charges.
- Unused Elastic IPs should be released immediately.
- DNS, load balancers and Auto Scaling are often better than relying on one Elastic IP.
