# Load Balancing and Scalability

# Learning Objectives

By the end of these notes, I should be able to:

- Explain scalability, elasticity and high availability.
- Compare vertical and horizontal scaling.
- Design a highly available EC2 architecture.
- Explain what a load balancer does.
- Compare Application and Network Load Balancers.
- Explain listeners, listener rules and target groups.
- Configure load-balancer health checks.
- Design secure load-balancer security groups.
- Explain sticky sessions and their disadvantages.
- Explain SSL, TLS, certificates and SNI.
- Describe TLS termination and pass-through.
- Explain connection draining and deregistration delay.
- Create an EC2 Auto Scaling group.
- Configure minimum, desired and maximum capacity.
- Connect an Auto Scaling group to a load balancer.
- Explain CloudWatch alarms and scaling policies.
- Compare target tracking, step, simple, scheduled and predictive scaling.

---

# 56. Scalability and High Availability

## What Is Scalability?

**Scalability** is the ability of a system to handle changes in demand by increasing or decreasing its resources.

Example:

```text
Normal traffic: 2 EC2 instances
Busy traffic:   6 EC2 instances
Quiet traffic:  2 EC2 instances
```

A scalable application can continue performing when:

- More users visit the website
- More API requests are received
- More data must be processed
- CPU usage increases
- Memory demand increases
- Network traffic increases

---

## What Is Elasticity?

**Elasticity** is the ability to automatically add and remove resources as demand changes.

```text
Demand increases
       ↓
AWS adds capacity
       ↓
Demand decreases
       ↓
AWS removes unnecessary capacity
```

Scalability is the ability to change capacity.

Elasticity focuses on making those changes dynamically, often automatically.

---

## What Is High Availability?

**High availability** means designing a system to remain accessible when part of the infrastructure fails.

A highly available application avoids depending on one:

- EC2 instance
- Availability Zone
- Storage device
- Network path
- Application process

---

## Scalability vs High Availability

| Scalability | High availability |
| --- | --- |
| Handles changing demand | Handles component failure |
| Focuses on performance and capacity | Focuses on uptime and resilience |
| Adds or removes resources | Uses redundant resources |
| Can use one or several AZs | Normally requires several AZs |
| Example: adding more EC2 instances | Example: instances across two AZs |

A system can be scalable without being highly available.

Example:

```text
Four EC2 instances in one Availability Zone
```

This provides additional capacity, but an Availability Zone failure could affect every instance.

---

## Scalable and Highly Available Design

```text
                         Application Load Balancer
                                  │
                    ┌─────────────┴─────────────┐
                    │                           │
            Availability Zone A        Availability Zone B
                    │                           │
              EC2 instance 1              EC2 instance 2
                    │                           │
                    └──── Auto Scaling Group ──┘
```

This design can:

- Distribute traffic
- Replace unhealthy instances
- Add instances during high demand
- Remove instances during low demand
- Continue operating if one instance fails
- Continue operating if one Availability Zone has a problem

---

# 57. Vertical Scalability

**Vertical scaling** means increasing or decreasing the capacity of one server.

It is also called:

```text
Scaling up or scaling down
```

---

## Scaling Up

Scaling up means changing to a more powerful server.

Example:

```text
t3.micro → t3.large
```

The larger instance may provide:

- More virtual CPUs
- More memory
- Better network performance
- Greater EBS bandwidth

---

## Scaling Down

Scaling down means changing to a smaller server.

Example:

```text
t3.large → t3.micro
```

This can reduce cost when the larger capacity is no longer required.

---

## Vertical Scaling Example

```text
Before:
1 EC2 instance
2 vCPU
4 GiB RAM

After:
1 EC2 instance
8 vCPU
32 GiB RAM
```

The number of servers stays the same, but the server becomes more powerful.

---

## Advantages of Vertical Scaling

- Relatively simple
- May not require application redesign
- Useful for databases
- Useful for older applications
- Keeps the workload on one server

---

## Disadvantages of Vertical Scaling

- The server has a maximum possible size.
- Changing the instance type may require downtime.
- A single server remains a failure point.
- Larger instances can be expensive.
- It does not automatically provide high availability.
- One server must still handle the entire workload.

---

## Vertical Scaling on EC2

For many EBS-backed EC2 instances:

1. Stop the instance.
2. Change the instance type.
3. Start the instance.
4. Test the application.

Example:

```text
t3.micro → t3.medium
```

Before resizing, check:

- AMI architecture
- Instance-type compatibility
- EBS compatibility
- Network requirements
- Licence restrictions
- Expected price
- Required downtime

---

## When to Use Vertical Scaling

Vertical scaling can be suitable when:

- The application cannot run across several servers.
- A database needs more memory.
- The workload is small.
- Simplicity is more important than high availability.
- The application has not been designed for horizontal scaling.

---

# 58. Horizontal Scalability

**Horizontal scaling** means adding or removing servers.

It is also called:

```text
Scaling out or scaling in
```

---

## Scaling Out

Scaling out means adding more servers.

Example:

```text
2 EC2 instances → 6 EC2 instances
```

This increases the total capacity of the application.

---

## Scaling In

Scaling in means removing unnecessary servers.

Example:

```text
6 EC2 instances → 2 EC2 instances
```

This can reduce cost during quiet periods.

---

## Horizontal Scaling Example

```text
Before:
1 EC2 instance

After:
Application Load Balancer
├── EC2 instance 1
├── EC2 instance 2
├── EC2 instance 3
└── EC2 instance 4
```

Traffic must be distributed between the instances.

This is normally handled by a load balancer.

---

## Advantages of Horizontal Scaling

- Can support large workloads
- Improves fault tolerance
- Can operate across Availability Zones
- Works well with Auto Scaling
- Capacity can be added automatically
- Failed servers can be replaced
- No single instance must handle all traffic

---

## Disadvantages of Horizontal Scaling

- The application may need redesigning.
- Data must be shared or synchronised.
- Session management becomes more complicated.
- A load balancer is normally required.
- Monitoring and troubleshooting become more complex.
- Instances should be configured consistently.

---

## Stateless Applications

Horizontal scaling works best when application servers are **stateless**.

A stateless server does not store important user-session data only on its local disk.

Instead, shared state can be stored in services such as:

- Amazon RDS
- Amazon DynamoDB
- Amazon ElastiCache
- Amazon EFS
- Amazon S3

This allows any healthy server to process the next request.

---

## Vertical vs Horizontal Scaling

| Vertical scaling | Horizontal scaling |
| --- | --- |
| Changes one server’s size | Changes the number of servers |
| Scale up or down | Scale out or in |
| Simpler | More flexible |
| Has a maximum server size | Can scale across many servers |
| May require downtime | Can often scale without downtime |
| Does not remove one-server failure risk | Can improve fault tolerance |
| Useful for some databases | Useful for web applications |

---

# 59. High Availability

A highly available application continues operating when part of the system fails.

---

## Single Point of Failure

A **single point of failure** is one component whose failure can stop the entire service.

Example:

```text
Internet
   ↓
One EC2 instance
```

If the EC2 instance fails, the website becomes unavailable.

---

## Removing the Single Point of Failure

```text
                   Load Balancer
                   /           \
          EC2 instance 1    EC2 instance 2
          eu-west-2a        eu-west-2b
```

If instance 1 fails, the load balancer can send traffic to instance 2.

If Availability Zone A fails, the instance in Availability Zone B can continue serving traffic.

---

## High-Availability Principles

- Use more than one instance.
- Distribute instances across Availability Zones.
- Use health checks.
- Replace failed resources automatically.
- Avoid storing important data on only one local server.
- Back up persistent data.
- Test failure and recovery.
- Monitor the application.
- Use managed multi-AZ services when appropriate.

---

## Availability Zones

Availability Zones are separate locations inside an AWS Region.

For high availability in London, an application could use subnets in:

```text
eu-west-2a
eu-west-2b
eu-west-2c
```

The exact Availability Zone letters can map differently between AWS accounts.

Use at least two Availability Zones for a highly available design.

---

## High Availability Is Not Backup

High availability keeps the service running during failures.

A backup allows lost or damaged data to be restored.

An application normally needs both:

```text
High availability + Backups
```

Replication without backups may copy accidental deletions or corrupted data to the other replicas.

---

# 60. High Availability and Scalability for EC2

A common highly available EC2 architecture uses:

- Application Load Balancer
- Auto Scaling group
- Launch template
- EC2 instances in multiple Availability Zones
- Target group
- Health checks
- CloudWatch metrics and alarms

---

## Example Architecture

```text
                         Internet
                            │
                Application Load Balancer
                            │
              ┌─────────────┴─────────────┐
              │                           │
      Public subnet – AZ A       Public subnet – AZ B
              │                           │
        EC2 instance 1               EC2 instance 2
              │                           │
              └──── Auto Scaling Group ──┘
```

For stronger security, the EC2 application instances can be placed in private subnets while the internet-facing load balancer uses public subnets.

---

## What Each Component Does

| Component | Purpose |
| --- | --- |
| Load balancer | Distributes requests |
| Target group | Contains application targets |
| Health check | Identifies healthy targets |
| Launch template | Defines how new instances are created |
| Auto Scaling group | Maintains and changes instance capacity |
| CloudWatch | Collects metrics and triggers alarms |
| Multiple AZs | Protects against one-location failure |

---

## Example Failure

Suppose instance 1 stops responding:

1. The load balancer’s health check fails.
2. The target becomes unhealthy.
3. The load balancer stops sending it new requests.
4. The Auto Scaling group detects the unhealthy instance.
5. The Auto Scaling group terminates and replaces it.
6. Traffic continues to the healthy instance.

---

# 61. What Is Load Balancing?

**Load balancing** means distributing incoming network traffic across multiple targets.

Targets can include:

- EC2 instances
- IP addresses
- Containers
- Lambda functions for supported load balancers
- Application endpoints

---

## Without a Load Balancer

```text
All users
    ↓
One EC2 instance
```

Problems include:

- One failure point
- Limited capacity
- Manual traffic management
- Difficult maintenance
- Poor horizontal scalability

---

## With a Load Balancer

```text
Users
  ↓
Load Balancer
├── EC2 instance 1
├── EC2 instance 2
└── EC2 instance 3
```

The load balancer provides a single entry point and sends requests to healthy targets.

---

## Basic Load-Balancing Flow

1. A client resolves the load balancer’s DNS name.
2. The client connects to a load-balancer node.
3. A listener accepts the connection.
4. Listener rules are evaluated.
5. The request is forwarded to a target group.
6. The load balancer selects a healthy target.
7. The target processes the request.
8. The response returns to the client.

---

# 62. Why Use a Load Balancer?

Load balancers can provide:

- Traffic distribution
- Health checking
- Fault tolerance
- One application entry point
- Horizontal scalability
- SSL/TLS termination
- Routing rules
- Integration with Auto Scaling
- Multi-AZ traffic distribution
- Easier maintenance

---

## Traffic Distribution

Instead of one server receiving every request, traffic is spread across multiple servers.

```text
100 requests
    ↓
Load balancer
├── Instance 1 receives some requests
├── Instance 2 receives some requests
└── Instance 3 receives some requests
```

The exact distribution depends on the load-balancer type, algorithm, target health and active connections.

---

## Maintenance

A server can be removed from the target group for maintenance.

The load balancer can continue sending traffic to the remaining healthy targets.

---

## Failure Handling

If one target becomes unhealthy, the load balancer stops selecting it for new traffic.

This protects users from being intentionally routed to a known failed server.

---

## Single Entry Point

Clients connect to the load balancer’s DNS name rather than individual instance IP addresses.

Example:

```text
nginx-learning-alb-123456.eu-west-2.elb.amazonaws.com
```

A custom domain can point to the load balancer using Route 53 or another DNS provider.

---

# 63. Why Use an Elastic Load Balancer?

**Elastic Load Balancing**, also called **ELB**, is AWS’s managed load-balancing service.

---

## Managed by AWS

AWS manages:

- Load-balancer infrastructure
- Scaling of load-balancer capacity
- Fault tolerance
- Load-balancer software
- Availability Zone nodes
- Integration with AWS services

The customer manages:

- Load-balancer type
- Subnets and Availability Zones
- Listeners
- Listener rules
- Target groups
- Health checks
- Security groups
- Certificates
- Monitoring and application targets

---

## ELB Benefits

- Automatically distributes traffic
- Integrates with EC2 Auto Scaling
- Supports health checks
- Supports multiple Availability Zones
- Integrates with ACM certificates
- Publishes CloudWatch metrics
- Can produce access logs
- Integrates with Route 53
- Supports internet-facing and internal designs
- Removes the need to manage load-balancer servers manually

---

## Internet-Facing vs Internal

### Internet-Facing Load Balancer

Receives requests from internet clients.

Example:

```text
Internet → Public load balancer → Application targets
```

### Internal Load Balancer

Used for private communication inside a VPC.

Example:

```text
Web tier → Internal load balancer → Application tier
```

An internal load balancer is not directly internet-facing.

---

# 64. Health Checks

A **health check** is a test used by a load balancer to determine whether a target can receive traffic.

---

## Health-Check Example

For an NGINX server:

```text
Protocol: HTTP
Port: Traffic port
Path: /health
Success code: 200
```

The load balancer repeatedly requests:

```text
http://TARGET-IP/health
```

If it receives the expected response, the target can become healthy.

---

## Target Health States

| State | Meaning |
| --- | --- |
| Initial | Target is being registered or checked |
| Healthy | Target passed the required checks |
| Unhealthy | Target failed the required checks |
| Draining | Target is being deregistered |
| Unused | Target is not used by the load balancer |
| Unavailable | Health status cannot currently be determined |

Exact status names can vary by load-balancer and target type.

---

## Health-Check Settings

| Setting | Meaning |
| --- | --- |
| Protocol | HTTP, HTTPS or another supported protocol |
| Port | Port used for the check |
| Path | Application endpoint being checked |
| Interval | Time between checks |
| Timeout | Time allowed for a response |
| Healthy threshold | Successful checks required |
| Unhealthy threshold | Failed checks required |
| Success codes | HTTP codes treated as successful |

---

## Good Health Endpoint

A useful health endpoint should:

- Respond quickly
- Return the expected success code
- Check essential application functionality
- Avoid performing expensive work
- Avoid requiring user authentication
- Avoid redirect loops

Example:

```bash
echo "healthy" | sudo tee /var/www/html/health
```

The endpoint becomes:

```text
http://SERVER/health
```

---

## EC2 Health vs Application Health

### EC2 Status Check

Checks the virtual machine and underlying infrastructure.

### Load-Balancer Health Check

Checks whether the application responds on the configured protocol, port and path.

An EC2 instance can be running while NGINX is stopped.

```text
EC2 status: Healthy
Application health: Unhealthy
```

---

# 65. Types of Load Balancers on AWS

AWS supports the following Elastic Load Balancing types.

| Type | Main OSI layer | Common use |
| --- | --- | --- |
| Application Load Balancer | Layer 7 | HTTP, HTTPS, web applications and APIs |
| Network Load Balancer | Layer 4 | TCP, UDP and TLS workloads |
| Gateway Load Balancer | Layer 3/4 gateway | Virtual network appliances |
| Classic Load Balancer | Layer 4/7 | Older legacy applications |

---

## Application Load Balancer

Best suited for:

- Websites
- HTTP APIs
- HTTPS applications
- Microservices
- Containers
- Host-based routing
- Path-based routing

---

## Network Load Balancer

Best suited for:

- TCP applications
- UDP applications
- TLS listeners
- Very high-performance networking
- Low-latency connections
- Static IP requirements
- Preserving client IP information

---

## Gateway Load Balancer

Used for virtual network appliances such as:

- Firewalls
- Intrusion-detection systems
- Intrusion-prevention systems
- Deep packet inspection
- Security appliances

---

## Classic Load Balancer

Classic Load Balancer is the previous-generation load balancer.

For new applications, AWS normally recommends selecting an Application, Network or Gateway Load Balancer based on the workload.

---

# 66. Load Balancer Security Groups

Application Load Balancers use security groups.

Network Load Balancers also support security groups in current AWS configurations.

---

## Two-Security-Group Design

Use separate security groups for:

1. The load balancer
2. The application instances

---

## Load-Balancer Security Group

Example:

```text
Name: alb-public-sg
```

Inbound rules:

| Type | Port | Source |
| --- | ---: | --- |
| HTTP | 80 | `0.0.0.0/0` |
| HTTPS | 443 | `0.0.0.0/0` |

If IPv6 is enabled:

| Type | Port | Source |
| --- | ---: | --- |
| HTTP | 80 | `::/0` |
| HTTPS | 443 | `::/0` |

---

## Instance Security Group

Example:

```text
Name: nginx-asg-instance-sg
```

Inbound rule:

| Type | Port | Source |
| --- | ---: | --- |
| HTTP | 80 | `alb-public-sg` |

Optional lab administration rule:

| Type | Port | Source |
| --- | ---: | --- |
| SSH | 22 | My IP |

The EC2 web servers do not need HTTP access directly from:

```text
0.0.0.0/0
```

Only the load balancer should reach their application port.

---

## Security Flow

```text
Internet
   ↓ TCP 80 or 443
alb-public-sg
   ↓ TCP 80
nginx-asg-instance-sg
   ↓
NGINX
```

This prevents users from bypassing the load balancer and directly accessing the web servers over HTTP.

---

## Health-Check Security

The instance security group must allow the health-check protocol and port from the load balancer.

If health checks use HTTP port 80:

```text
Inbound TCP 80
Source: alb-public-sg
```

allows both application requests and health checks.

---

# 67. Application Load Balancer

An **Application Load Balancer**, or **ALB**, operates at Layer 7 of the OSI model.

Layer 7 is the application layer.

An ALB understands HTTP and HTTPS requests.

---

## ALB Features

- HTTP and HTTPS listeners
- Host-based routing
- Path-based routing
- HTTP-header routing
- Query-string routing
- HTTP-method routing
- Source-IP routing
- Redirects
- Fixed responses
- Weighted forwarding
- Sticky sessions
- WebSocket support
- HTTP/2 support
- gRPC support
- TLS termination
- AWS WAF integration
- Authentication integrations
- Multiple target groups

---

## ALB Architecture

```text
Client
  ↓ HTTP or HTTPS
Application Load Balancer
  ↓ Listener rule
Target group
├── EC2 instance
├── EC2 instance
└── EC2 instance
```

---

## ALB Target Types

An ALB target group can use supported target types such as:

| Target type | Meaning |
| --- | --- |
| Instance | Routes to EC2 instances |
| IP | Routes to private IP addresses |
| Lambda | Invokes Lambda functions |

The target type is selected when the target group is created.

---

# 68. Application Load Balancer – Part 2

## Listeners

A **listener** checks for connection requests using a configured protocol and port.

Examples:

```text
HTTP listener:  Port 80
HTTPS listener: Port 443
```

Each listener has:

- Protocol
- Port
- Default action
- Optional rules
- Certificate and security policy for HTTPS

---

## Listener Rules

Listener rules decide what the ALB should do with a request.

Rules contain:

- Priority
- Conditions
- Actions

The ALB evaluates rules in priority order.

If no custom rule matches, the default rule is used.

---

## Listener Actions

Actions can include:

- Forward to a target group
- Redirect to another URL or protocol
- Return a fixed response
- Authenticate users for supported configurations

---

## HTTP-to-HTTPS Redirect

A common configuration is:

```text
HTTP listener on port 80
        ↓
Redirect to HTTPS port 443
```

This ensures users use an encrypted connection.

---

## Fixed Response Example

A listener rule could return:

```text
HTTP 503
Maintenance in progress
```

without sending the request to an EC2 instance.

---

# 69. ALB HTTP-Based Traffic Routing

Because an ALB understands HTTP, it can inspect information inside requests.

---

## Path-Based Routing

```text
/images/* → images-target-group
/api/*    → api-target-group
/*        → website-target-group
```

Example:

```text
example.com/api/users
```

is forwarded to the API servers.

---

## Host-Based Routing

```text
shop.example.com → shop-target-group
api.example.com  → api-target-group
admin.example.com → admin-target-group
```

One ALB can route several domain names.

---

## Header-Based Routing

Example:

```text
Header:
X-Environment: testing

Action:
Forward to testing-target-group
```

---

## Query-String Routing

Example request:

```text
example.com/search?version=beta
```

The ALB can route requests containing selected query-string values.

---

## HTTP-Method Routing

Example:

```text
GET requests  → read-target-group
POST requests → write-target-group
```

This should be used carefully because application design and security still need to be handled correctly.

---

## Weighted Target Groups

Traffic can be divided between target groups.

Example:

```text
Target group A: 90%
Target group B: 10%
```

This can support:

- Canary deployments
- Blue/green deployments
- Gradual releases
- Application testing

---

# 70. Application Load Balancer Target Groups

A **target group** is a logical group of resources that receive traffic from a load balancer.

---

## Target Group Configuration

A target group defines:

- Target type
- Protocol
- Port
- VPC
- IP address type
- Protocol version
- Registered targets
- Health-check settings
- Target-group attributes

---

## Example Target Group

```text
Name: nginx-asg-targets
Target type: Instances
Protocol: HTTP
Port: 80
VPC: Default VPC
Health-check path: /health
```

Targets:

```text
EC2 instance 1
EC2 instance 2
EC2 instance 3
```

---

## Registration Process

```text
Register target
      ↓
Initial health check
      ↓
Target passes
      ↓
Target becomes healthy
      ↓
Load balancer sends traffic
```

---

## Deregistration Process

```text
Deregister target
      ↓
Stop receiving new requests
      ↓
Target enters draining state
      ↓
Existing requests complete
      ↓
Target is removed
```

---

## Target Group vs Auto Scaling Group

| Target group | Auto Scaling group |
| --- | --- |
| Used by the load balancer | Manages EC2 capacity |
| Tracks registered targets | Launches and terminates instances |
| Performs application health checks | Maintains desired capacity |
| Routes traffic | Scales infrastructure |

They can work together but are different resources.

---

# 71. Application Load Balancer – Good to Know

## ALB Uses DNS

An ALB provides a DNS name such as:

```text
nginx-learning-alb-123456.eu-west-2.elb.amazonaws.com
```

The underlying IP addresses can change.

Do not hard-code ALB IP addresses.

Use:

- The ALB DNS name
- A Route 53 Alias record
- A supported DNS CNAME where appropriate

---

## Multiple Availability Zones

An Application Load Balancer requires subnets in at least two Availability Zones.

AWS creates load-balancer capacity in the enabled Availability Zones.

Targets should also be distributed across multiple enabled Availability Zones.

---

## Cross-Zone Load Balancing

Cross-zone load balancing allows load-balancer nodes to route traffic to targets across enabled Availability Zones.

For ALBs, cross-zone load balancing is enabled at the load-balancer level. Target-group settings can provide additional control.

---

## Client IP Address

Because the ALB receives the client connection, the backend may see the load balancer as the direct connection source.

The original client IP is provided through headers such as:

```text
X-Forwarded-For
```

The original protocol can be identified through:

```text
X-Forwarded-Proto
```

Applications must only trust forwarded headers from trusted proxies such as the load balancer.

---

## ALB Does Not Provide Static IPs

Application Load Balancer IP addresses can change.

If fixed IP addresses are required, consider:

- Network Load Balancer
- AWS Global Accelerator
- Another supported architecture

---

## Monitoring

Useful ALB CloudWatch metrics include:

- Request count
- Target response time
- Healthy host count
- Unhealthy host count
- HTTP 4xx errors
- HTTP 5xx errors
- Rejected connections
- Processed bytes

Access logging can be configured for more detailed request records.

---

# 72. Network Load Balancer

A **Network Load Balancer**, or **NLB**, operates mainly at Layer 4.

Layer 4 is the transport layer.

An NLB handles network connections without needing to understand HTTP paths or headers.

---

## NLB Protocols

Network Load Balancers support listener protocols such as:

- TCP
- UDP
- TLS
- TCP and UDP

Available options depend on the selected configuration.

---

## NLB Benefits

- Very high performance
- Low latency
- Handles large numbers of connections
- Static IP address per enabled Availability Zone
- Optional Elastic IP for internet-facing IPv4 configurations
- Preserves client IP information for supported traffic
- Supports TCP, UDP and TLS workloads
- Suitable for non-HTTP applications

---

## NLB Use Cases

- Gaming servers
- Voice and media traffic
- Financial applications
- IoT systems
- TCP services
- UDP services
- Applications requiring static IPs
- Very high-performance network workloads

---

## NLB Architecture

```text
Client
  ↓ TCP, UDP or TLS
Network Load Balancer
  ↓
Target group
├── EC2 instance
├── IP address
└── Application Load Balancer in supported designs
```

---

# 73. Network Load Balancer – TCP Layer 4

A Network Load Balancer makes decisions using Layer 4 information such as:

- Source IP
- Source port
- Destination IP
- Destination port
- Protocol
- Connection information

It does not normally route based on:

- URL path
- HTTP header
- Query string
- HTTP method

---

## ALB vs NLB

| Application Load Balancer | Network Load Balancer |
| --- | --- |
| Layer 7 | Layer 4 |
| HTTP and HTTPS focused | TCP, UDP and TLS focused |
| Understands URL paths | Does not route by URL path |
| Supports host-based routing | Routes network connections |
| No fixed ALB IPs | Static IP per enabled AZ |
| Suitable for websites and APIs | Suitable for high-performance network services |
| Adds forwarded HTTP headers | Can preserve client IP for supported traffic |

---

## TLS on an NLB

An NLB can use:

### TLS Listener

The NLB terminates TLS using a certificate.

```text
Client → TLS → NLB → TCP or TLS → Target
```

### TCP Listener on Port 443

The NLB passes encrypted traffic to the target without decrypting it.

```text
Client → Encrypted TCP → NLB → Encrypted TCP → Target
```

This is known as TLS pass-through.

---

# 74. Sticky Sessions

A **sticky session** sends a user’s requests to the same target for a configured period.

It is also called:

```text
Session affinity
```

---

## Without Stickiness

```text
Request 1 → Instance A
Request 2 → Instance B
Request 3 → Instance C
```

---

## With Stickiness

```text
Request 1 → Instance A
Request 2 → Instance A
Request 3 → Instance A
```

The load balancer commonly uses a cookie to remember the selected target.

---

## Types of ALB Stickiness

ALB stickiness can use:

- Load-balancer-generated duration cookies
- Application-generated cookies
- Target-group stickiness for weighted target groups

---

## Why Use Sticky Sessions?

They can help older or stateful applications where session information is stored locally on one server.

Example:

```text
User logs in
Session stored on Instance A
Later requests must return to Instance A
```

---

## Disadvantages

- Traffic may become uneven.
- One target can receive too many users.
- A failed target can interrupt its sessions.
- Scaling in becomes more complicated.
- It encourages local session state.
- It can reduce the benefits of load balancing.

---

## Preferred Design

Where possible, store session state externally.

Examples:

- Amazon ElastiCache
- Amazon DynamoDB
- Amazon RDS
- Another shared session store

This allows any healthy target to handle the request.

---

# 75. SSL/TLS Basics

**SSL** stands for **Secure Sockets Layer**.

**TLS** stands for **Transport Layer Security**.

TLS is the modern protocol used to encrypt internet communication.

The term SSL is still commonly used, but modern secure connections use TLS.

---

## HTTP vs HTTPS

| HTTP | HTTPS |
| --- | --- |
| Normally uses port 80 | Normally uses port 443 |
| Unencrypted | Encrypted using TLS |
| Data can be read if intercepted | Protects data in transit |
| URL begins with `http://` | URL begins with `https://` |

---

## What TLS Provides

TLS provides:

### Encryption

Prevents third parties from easily reading the traffic.

### Authentication

Helps the client confirm the identity of the server.

### Integrity

Helps detect whether the traffic was modified.

---

## Simplified TLS Handshake

```text
Client connects to server
        ↓
Server presents certificate
        ↓
Client validates certificate
        ↓
Encryption settings are agreed
        ↓
Encrypted session begins
```

The full process depends on the TLS version and selected cipher suite.

---

# 76. Load Balancer SSL Certificate

An HTTPS listener requires a server certificate.

For an ALB, certificates can be managed using:

- AWS Certificate Manager
- IAM certificate storage for some supported cases

AWS Certificate Manager is commonly preferred.

---

## Certificate Information

A certificate contains information such as:

- Domain name
- Certificate authority
- Validity period
- Public key
- Digital signature

The private key must remain protected.

---

## ACM Certificate Process

1. Open AWS Certificate Manager.
2. Request a public certificate.
3. Enter the domain name.
4. Validate domain ownership.
5. Create an HTTPS listener on the load balancer.
6. Select the ACM certificate.
7. Select an appropriate TLS security policy.
8. Point DNS to the load balancer.

---

## Domain Validation

ACM commonly supports DNS validation.

Example:

```text
Domain: app.example.com
```

ACM provides a DNS validation record.

After the record is added, ACM verifies domain control.

DNS-validated ACM certificates can normally renew automatically while the required conditions continue to be met.

---

## HTTPS Listener

Example:

```text
Protocol: HTTPS
Port: 443
Certificate: ACM certificate
Default action: Forward to nginx-asg-targets
```

A TLS security policy controls supported:

- TLS versions
- Cipher suites
- Negotiation settings

Use a current security policy compatible with required clients.

---

# 77. SSL Server Name Indication

**SNI** stands for **Server Name Indication**.

SNI allows one load balancer listener to use different certificates for different domain names.

---

## Without SNI

Historically, hosting several HTTPS domains on one IP address was difficult because certificate selection happened before the HTTP hostname was available.

---

## With SNI

The client includes the requested hostname during the TLS handshake.

Example:

```text
shop.example.com
api.example.com
admin.example.com
```

The load balancer selects the matching certificate.

---

## ALB Certificate List

An HTTPS listener can have:

- One default certificate
- Additional certificates in a certificate list

Example:

```text
Default certificate: example.com
Additional certificate: api.example.com
Additional certificate: shop.example.net
```

SNI-compatible clients receive the certificate matching the requested hostname.

The default certificate is used when a suitable additional certificate is not selected.

---

# 78. Elastic Load Balancers and SSL

Load balancers can manage TLS in several ways.

---

## TLS Termination

The client’s TLS connection ends at the load balancer.

```text
Client → HTTPS → ALB → HTTP → EC2
```

The load balancer:

1. Presents the certificate.
2. Negotiates TLS.
3. Decrypts the request.
4. Sends the request to the target.

### Advantages

- Certificates are managed centrally.
- EC2 instances perform less TLS processing.
- Application servers can use a simpler HTTP configuration.
- ACM integration simplifies certificate management.

---

## End-to-End Encryption

Traffic is encrypted between both:

- Client and load balancer
- Load balancer and target

```text
Client → HTTPS → ALB → HTTPS → EC2
```

This can be used when encryption is required across the complete path.

The target group uses HTTPS, and the target must run HTTPS.

---

## TLS Pass-Through

A Network Load Balancer with a TCP listener can pass encrypted traffic through without decrypting it.

```text
Client → Encrypted TCP → NLB → Encrypted TCP → Target
```

The backend target manages:

- Certificate
- TLS negotiation
- Decryption

---

## HTTP-to-HTTPS Redirect

A common ALB configuration is:

```text
Listener 80:
Redirect to HTTPS 443

Listener 443:
Forward to target group
```

This ensures normal HTTP requests are redirected to HTTPS.

---

# 79. Connection Draining

**Connection draining** allows existing requests to finish when a target is removed.

For modern target groups, this is controlled by the **deregistration delay**.

---

## Without Connection Draining

```text
Target removed
      ↓
Active request immediately interrupted
      ↓
User receives an error
```

---

## With Connection Draining

```text
Target starts deregistering
      ↓
No new requests are sent
      ↓
Existing requests can finish
      ↓
Deregistration completes
```

The target displays:

```text
Draining
```

---

## Deregistration Delay

The default ALB target-group deregistration delay is commonly:

```text
300 seconds
```

It can be adjusted based on application requirements.

Shorter delays may suit short web requests.

Long-running requests may require more time.

---

## When Connection Draining Is Used

- Scaling in
- Instance maintenance
- Deployments
- Target deregistration
- Auto Scaling replacement
- Availability Zone changes

The operating system or application should not be shut down before important in-flight requests have had time to finish.

---

# 80. What Is an Auto Scaling Group?

An **Auto Scaling group**, or **ASG**, manages a collection of EC2 instances.

It attempts to maintain the required capacity and can automatically add, replace or remove instances.

---

## ASG Capacity Settings

An Auto Scaling group uses:

| Setting | Meaning |
| --- | --- |
| Minimum capacity | Lowest capacity allowed |
| Desired capacity | Capacity the group tries to maintain |
| Maximum capacity | Highest capacity allowed |

Example:

```text
Minimum: 2
Desired: 2
Maximum: 6
```

The ASG starts with two instances.

It cannot scale below two or above six unless the limits are changed.

---

## ASG Example

```text
Low demand:
2 instances

High demand:
6 instances

Demand reduces:
2 instances
```

---

## ASG Responsibilities

- Launch EC2 instances
- Maintain desired capacity
- Replace unhealthy instances
- Distribute capacity across configured AZs
- Scale out
- Scale in
- Register instances with target groups
- Deregister instances before termination
- Record scaling activities

---

# 81. Auto Scaling Group in AWS

## Launch Template

An Auto Scaling group needs a definition for new EC2 instances.

A **launch template** can contain:

- AMI
- Instance type
- Key pair
- Security groups
- IAM instance profile
- EBS configuration
- User Data
- Instance metadata settings
- Monitoring configuration
- Tags

Example:

```text
Launch template: nginx-asg-template-v1
AMI: Ubuntu Server LTS
Instance type: t3.micro
Security group: nginx-asg-instance-sg
User Data: Install and configure NGINX
```

---

## Multiple Availability Zones

Configure the ASG with subnets in multiple Availability Zones.

Example:

```text
Public subnet in eu-west-2a
Public subnet in eu-west-2b
```

The ASG attempts to balance capacity across the configured Availability Zones.

---

## Self-Healing

If an instance becomes unhealthy:

```text
Instance becomes unhealthy
        ↓
ASG terminates it
        ↓
ASG launches a replacement
        ↓
Desired capacity is restored
```

This is known as self-healing infrastructure.

---

## Health-Check Grace Period

A new instance may require time to:

- Boot
- Run User Data
- Install software
- Start the application
- Pass health checks

A health-check grace period prevents the ASG from replacing it too quickly.

The grace period should reflect the application’s real startup time.

---

## Launch Template Versions

Launch templates support versions.

Example:

```text
Version 1: Ubuntu + NGINX
Version 2: Updated Ubuntu + NGINX configuration
Version 3: New application release
```

Changing the launch template version affects newly launched instances.

Existing instances are not automatically rebuilt unless an instance refresh or replacement process is performed.

---

# 82. Auto Scaling Group with a Load Balancer

An ASG can be connected to an ALB target group.

---

## Integration Flow

```text
ASG launches instance
        ↓
Instance registers with target group
        ↓
Load balancer performs health checks
        ↓
Target becomes healthy
        ↓
Load balancer sends traffic
```

During scale-in:

```text
ASG selects instance
        ↓
Instance deregisters from target group
        ↓
Connection draining begins
        ↓
Instance terminates
```

---

## Combined Architecture

```text
                         Internet
                            │
                Application Load Balancer
                            │
                      Target Group
                    ┌───────┴───────┐
                    │               │
              EC2 instance 1  EC2 instance 2
                    │               │
                    └────── ASG ────┘
```

---

## Load-Balancer Health Checks in an ASG

The ASG can use load-balancer health information.

This allows it to replace an instance where:

```text
EC2 is running
but
The application is failing
```

Without ELB health checks, the ASG may only see that the EC2 virtual machine itself is running.

---

# 83. Auto Scaling Group Activities

The **Activity** or **Activity history** section records actions performed by the ASG.

---

## Activity Information

An activity can show:

- Start time
- End time
- Description
- Cause
- Status
- Status message
- Instance ID
- Scaling action

---

## Example Activities

```text
Launching a new EC2 instance
Terminating an unhealthy instance
Increasing desired capacity
Decreasing desired capacity
Rebalancing Availability Zones
Failed to launch instance
```

---

## Why Activity History Matters

It helps answer questions such as:

- Why was an instance launched?
- Why was an instance terminated?
- Did a scaling policy run?
- Did the ASG reach a service quota?
- Was the AMI invalid?
- Did the instance type lack capacity?
- Was the security group incorrect?
- Did an IAM permission block the launch?

---

## Common Activity Failures

- Incorrect launch-template configuration
- Invalid AMI
- Incompatible instance type
- Missing IAM permissions
- EC2 capacity unavailable
- Service quota reached
- Invalid key pair
- Security group and VPC mismatch
- Invalid subnet
- KMS permission problem

---

# 84. Auto Scaling, CloudWatch Alarms and Scaling

Amazon CloudWatch collects metrics from AWS resources.

CloudWatch alarms evaluate those metrics.

A scaling policy can respond to the alarm.

---

## Scaling Flow

```text
CloudWatch metric
       ↓
Alarm evaluates threshold
       ↓
Alarm enters ALARM state
       ↓
Scaling policy runs
       ↓
ASG changes desired capacity
```

---

## Example Scale-Out Alarm

```text
Metric: Average CPU utilisation
Threshold: Above 70%
Duration: 5 minutes
Action: Add instances
```

---

## Example Scale-In Alarm

```text
Metric: Average CPU utilisation
Threshold: Below 25%
Duration: 15 minutes
Action: Remove instances
```

Scale-in conditions are often more conservative to prevent capacity being removed too quickly.

---

## Useful Scaling Metrics

- Average CPU utilisation
- Network in
- Network out
- ALB request count per target
- Queue length
- Application latency
- Custom application metrics
- Number of pending jobs

---

## Alarm States

| State | Meaning |
| --- | --- |
| OK | Metric is within the expected threshold |
| ALARM | Threshold has been breached |
| Insufficient data | CloudWatch lacks enough data |

An alarm state does not always mean the application is broken. It means the configured condition has been met.

---

## Instance Warmup

A new instance needs time before its metrics represent normal operation.

Instance warmup helps prevent scaling decisions from being distorted while a new instance is still starting.

Warmup can include time for:

- EC2 boot
- User Data
- Application startup
- Target registration
- Health checks
- Cache warming

---

# 85. Auto Scaling Group Scaling Policies

A scaling policy defines when and how the ASG changes capacity.

---

## Target Tracking Scaling

Target tracking attempts to maintain a metric near a selected target.

Example:

```text
Metric: Average CPU utilisation
Target: 50%
```

It works like a thermostat:

```text
CPU above target → Scale out
CPU below target → Scale in when safe
```

AWS creates and manages the required CloudWatch alarms.

Target tracking is commonly the simplest dynamic scaling policy.

---

## Step Scaling

Step scaling changes capacity based on how far a metric passes a threshold.

Example:

| CPU utilisation | Action |
| --- | --- |
| 60–70% | Add 1 instance |
| 70–85% | Add 2 instances |
| Above 85% | Add 4 instances |

This provides different responses for different demand levels.

CloudWatch alarms must be configured for the policy.

---

## Simple Scaling

Simple scaling performs one adjustment when an alarm is triggered.

Example:

```text
CPU above 70%
        ↓
Add 1 instance
        ↓
Wait for cooldown
```

It is less flexible than target tracking or step scaling and is generally considered an older approach.

---

## Scheduled Scaling

Scheduled scaling changes capacity at known times.

Example:

```text
Monday–Friday at 08:00:
Desired capacity = 6

Monday–Friday at 19:00:
Desired capacity = 2
```

It is useful for predictable traffic patterns.

---

## Predictive Scaling

Predictive scaling analyses historical metric data and forecasts future demand.

It can add capacity before expected traffic arrives.

It is useful when demand follows repeated patterns.

Predictive scaling requires sufficient metric history before useful forecasts can be created.

---

## Manual Scaling

An administrator directly changes:

```text
Desired capacity
```

This is useful for:

- Testing
- Planned maintenance
- Temporary capacity changes
- Learning how the ASG behaves

It is not automatic.

---

## Scaling Policy Comparison

| Policy | Best suited for |
| --- | --- |
| Target tracking | Maintaining a metric near a target |
| Step scaling | Different actions for different alarm sizes |
| Simple scaling | Basic single adjustments |
| Scheduled scaling | Known traffic schedules |
| Predictive scaling | Forecastable recurring demand |
| Manual scaling | Testing or planned changes |

---

## Scale-Out vs Scale-In Safety

Scale out quickly enough to protect performance.

Scale in carefully to avoid:

- Removing too much capacity
- Interrupting requests
- Constant scaling up and down
- Terminating instances still needed
- Increasing latency

Use:

- Instance warmup
- Deregistration delay
- Suitable evaluation periods
- Conservative scale-in settings
- Minimum capacity
- Application-aware metrics

---

# Practical Demo: ALB and Auto Scaling Group

This lab extends the previous Ubuntu and NGINX work.

---

## Final Architecture

```text
                             Internet
                                │
                    nginx-learning-alb
                  HTTP 80 or HTTPS 443
                                │
                    nginx-asg-targets
                     Health check /health
                   ┌────────────┴────────────┐
                   │                         │
          EC2 in eu-west-2a         EC2 in eu-west-2b
                   │                         │
                   └── nginx-learning-asg ───┘
                       Min 2, Desired 2,
                             Max 4
```

---

## Step 1: Create the ALB Security Group

Create:

```text
Name: alb-public-sg
Description: Allows public web traffic to the learning ALB
```

Inbound rules:

| Type | Port | Source |
| --- | ---: | --- |
| HTTP | 80 | `0.0.0.0/0` |
| HTTPS | 443 | `0.0.0.0/0` |

Only add HTTPS when a certificate and HTTPS listener will be configured.

---

## Step 2: Create the Instance Security Group

Create:

```text
Name: nginx-asg-instance-sg
Description: Allows NGINX traffic only from the ALB
```

Inbound rules:

| Type | Port | Source |
| --- | ---: | --- |
| HTTP | 80 | `alb-public-sg` |
| SSH | 22 | My IP |

The SSH rule is optional for the lab. Systems Manager Session Manager can provide an alternative management path.

---

## Step 3: Create the Launch Template

Create:

```text
Name: nginx-asg-template
Version: 1
AMI: Current Ubuntu Server LTS
Instance type: t3.micro
Security group: nginx-asg-instance-sg
Key pair: abu-nginx-key.pem
```

Do not select a fixed subnet in the launch template because the ASG will select subnets across multiple Availability Zones.

---

## Step 4: Add User Data

```bash
#!/bin/bash
set -e

apt-get update -y
apt-get install -y nginx curl

TOKEN=$(curl -sS --fail -X PUT \
  -H "X-aws-ec2-metadata-token-ttl-seconds: 21600" \
  http://169.254.169.254/latest/api/token)

INSTANCE_ID=$(curl -sS --fail \
  -H "X-aws-ec2-metadata-token: $TOKEN" \
  http://169.254.169.254/latest/meta-data/instance-id)

AZ=$(curl -sS --fail \
  -H "X-aws-ec2-metadata-token: $TOKEN" \
  http://169.254.169.254/latest/meta-data/placement/availability-zone)

cat > /var/www/html/index.html <<EOF
<!doctype html>
<html lang="en">
<head>
  <meta charset="utf-8">
  <title>Abubakar's Auto Scaling Lab</title>
</head>
<body>
  <h1>Hello from the Auto Scaling Group!</h1>
  <p>Instance ID: ${INSTANCE_ID}</p>
  <p>Availability Zone: ${AZ}</p>
</body>
</html>
EOF

echo "healthy" > /var/www/html/health

systemctl enable nginx
systemctl restart nginx
```

Each instance displays its own instance ID and Availability Zone.

---

## Step 5: Create the Target Group

Create:

```text
Name: nginx-asg-targets
Target type: Instances
Protocol: HTTP
Port: 80
VPC: Same VPC as the launch template
```

Health check:

```text
Protocol: HTTP
Path: /health
Port: Traffic port
Success code: 200
```

Do not manually register temporary instances when the target group will be managed by the ASG.

---

## Step 6: Create the Application Load Balancer

Create:

```text
Name: nginx-learning-alb
Scheme: Internet-facing
IP address type: IPv4
VPC: Same VPC as the target group
```

Select at least two public subnets in different Availability Zones.

Example:

```text
Public subnet in eu-west-2a
Public subnet in eu-west-2b
```

Attach:

```text
alb-public-sg
```

Listener:

```text
HTTP port 80
Default action: Forward to nginx-asg-targets
```

---

## Step 7: Create the Auto Scaling Group

Create:

```text
Name: nginx-learning-asg
Launch template: nginx-asg-template
Version: 1
VPC: Same VPC as the ALB
Subnets: At least two AZs
```

Capacity:

```text
Minimum: 2
Desired: 2
Maximum: 4
```

Attach:

```text
nginx-asg-targets
```

Enable Elastic Load Balancing health checks and configure a suitable health-check grace period.

---

## Step 8: Wait for Healthy Targets

Open:

```text
EC2 → Target Groups → nginx-asg-targets → Targets
```

Wait for both targets to show:

```text
Healthy
```

If they remain unhealthy, check:

- User Data
- NGINX status
- Security groups
- Health-check path
- Health-check port
- Subnet routing
- Network ACLs

---

## Step 9: Test the Load Balancer

Copy the ALB DNS name:

```text
nginx-learning-alb-123456.eu-west-2.elb.amazonaws.com
```

Open:

```text
http://ALB-DNS-NAME
```

Refresh several times.

The page may display different:

- Instance IDs
- Availability Zones

Traffic distribution is not guaranteed to alternate perfectly on every refresh because connections and browser behaviour can be reused.

Test with:

```bash
for request_number in {1..10}; do
  curl -s http://ALB-DNS-NAME
done
```

---

## Step 10: Test a Failed Target

Connect to one target and stop NGINX:

```bash
sudo systemctl stop nginx
```

The `/health` check should fail.

The target should eventually become:

```text
Unhealthy
```

The ALB should stop intentionally routing new traffic to that target.

If the ASG uses ELB health checks, it may replace the unhealthy instance after the configured grace and evaluation periods.

---

## Step 11: Test Manual Scaling

Change desired capacity:

```text
2 → 3
```

The ASG should:

1. Launch a new instance.
2. Run User Data.
3. Register it with the target group.
4. Wait for the health check.
5. Place it into service.

Review:

```text
Auto Scaling Groups → Activity
```

---

## Step 12: Add Target Tracking

Create a dynamic scaling policy:

```text
Policy type: Target tracking
Metric: Average CPU utilisation
Target value: 50%
```

The policy attempts to maintain average ASG CPU utilisation near 50%.

For web applications, ALB request count per target may sometimes represent demand better than CPU.

---

## Step 13: Add HTTPS

When a domain is available:

1. Request an ACM certificate.
2. Validate the domain.
3. Add an HTTPS listener on port 443.
4. Select the certificate.
5. Forward HTTPS to `nginx-asg-targets`.
6. Change HTTP port 80 to redirect to HTTPS.
7. Point DNS to the ALB.
8. Test certificate validation and renewal requirements.

---

# Useful AWS CLI Commands

List load balancers:

```bash
aws elbv2 describe-load-balancers \
  --region eu-west-2 \
  --output table
```

List target groups:

```bash
aws elbv2 describe-target-groups \
  --region eu-west-2 \
  --output table
```

Check target health:

```bash
aws elbv2 describe-target-health \
  --target-group-arn TARGET-GROUP-ARN \
  --region eu-west-2
```

List Auto Scaling groups:

```bash
aws autoscaling describe-auto-scaling-groups \
  --region eu-west-2 \
  --output table
```

View scaling activities:

```bash
aws autoscaling describe-scaling-activities \
  --auto-scaling-group-name nginx-learning-asg \
  --region eu-west-2 \
  --output table
```

Change desired capacity:

```bash
aws autoscaling set-desired-capacity \
  --auto-scaling-group-name nginx-learning-asg \
  --desired-capacity 3 \
  --region eu-west-2
```

---

# Troubleshooting

## ALB Returns HTTP 503

Possible causes:

- No targets are registered.
- No targets are healthy.
- The listener forwards to the wrong target group.
- The ASG has not launched instances.
- Target registration is incomplete.

Check:

```text
Target Groups → Targets
```

---

## Target Is Unhealthy

Check:

- NGINX is running.
- The health-check path exists.
- The success code is correct.
- The instance security group allows the ALB.
- The application listens on the target-group port.
- The target is in an enabled Availability Zone.
- Network ACLs allow the traffic.
- User Data completed successfully.

Commands:

```bash
sudo systemctl status nginx
```

```bash
curl -i http://localhost/health
```

```bash
sudo less /var/log/cloud-init-output.log
```

---

## ALB Times Out

Check:

- The ALB security group allows client traffic.
- The instance security group allows traffic from the ALB.
- The target is healthy.
- The route tables are correct.
- The application is listening.
- The Network ACL allows listener and return traffic.

---

## ASG Does Not Launch Instances

Review the ASG Activity history.

Common causes:

- Invalid AMI
- Incorrect launch-template version
- Instance-type capacity unavailable
- Invalid security group
- VPC mismatch
- Invalid subnet
- Missing IAM permissions
- KMS permission failure
- Service quota reached

---

## ASG Does Not Scale Out

Check:

- Maximum capacity has not been reached.
- The scaling policy is enabled.
- The CloudWatch metric has data.
- The alarm has reached `ALARM`.
- Instance warmup is considered.
- Scaling processes are not suspended.
- Desired capacity has room to increase.

---

## ASG Scales Repeatedly

Possible causes:

- Thresholds are too sensitive.
- Warmup is too short.
- Scale-in happens too quickly.
- Application startup increases CPU.
- Health checks fail during startup.
- The selected metric does not represent demand properly.

---

## HTTPS Certificate Error

Check:

- The certificate covers the requested hostname.
- DNS points to the correct ALB.
- The certificate is issued.
- The HTTPS listener uses the correct certificate.
- The certificate is in the same Region as the ALB.
- The client supports the selected TLS policy.
- The domain-validation record still exists where required.

---

# Load-Balancing and Scaling Checklist

- [ ] Use at least two Availability Zones.
- [ ] Use more than one application instance.
- [ ] Select the correct load-balancer type.
- [ ] Give resources meaningful names.
- [ ] Restrict instance traffic to the load-balancer security group.
- [ ] Configure a reliable health endpoint.
- [ ] Confirm targets become healthy.
- [ ] Store application state outside individual instances.
- [ ] Use a launch template.
- [ ] Set sensible minimum, desired and maximum capacity.
- [ ] Configure a suitable health-check grace period.
- [ ] Configure instance warmup.
- [ ] Use deregistration delay.
- [ ] Use HTTPS for production traffic.
- [ ] Store certificates in ACM where suitable.
- [ ] Redirect HTTP to HTTPS.
- [ ] Monitor ALB and ASG CloudWatch metrics.
- [ ] Review scaling Activity history.
- [ ] Test instance and AZ failure scenarios.
- [ ] Review ELB, EC2 and public IPv4 costs.
- [ ] Delete unused load balancers.
- [ ] Delete unused target groups and launch templates.
- [ ] Remove unnecessary Auto Scaling groups.
- [ ] Review AWS Billing after every lab.

---

# Quick Revision Questions

1. What is scalability?
2. What is elasticity?
3. What is high availability?
4. What is the difference between scalability and high availability?
5. What is vertical scaling?
6. What is horizontal scaling?
7. What is the difference between scaling out and scaling in?
8. Why are stateless servers easier to scale horizontally?
9. What is a single point of failure?
10. Why should instances be distributed across Availability Zones?
11. What does a load balancer do?
12. Why are health checks required?
13. What is the difference between EC2 and application health?
14. What does ELB stand for?
15. What is the difference between an internet-facing and internal load balancer?
16. Which OSI layer does an ALB use?
17. Which OSI layer does an NLB use?
18. When should an ALB be selected?
19. When should an NLB be selected?
20. What is a listener?
21. What is a listener rule?
22. What is path-based routing?
23. What is host-based routing?
24. What is a target group?
25. What target types can an ALB use?
26. Why should EC2 HTTP access be restricted to the ALB security group?
27. Why should an ALB DNS name be used instead of hard-coded IPs?
28. What does `X-Forwarded-For` contain?
29. What is a sticky session?
30. What are the disadvantages of sticky sessions?
31. What is the difference between SSL and TLS?
32. What does an HTTPS certificate prove?
33. What is TLS termination?
34. What is end-to-end encryption?
35. What is TLS pass-through?
36. What does SNI stand for?
37. How does SNI support multiple domains?
38. What is connection draining?
39. What is deregistration delay?
40. What is an Auto Scaling group?
41. What are minimum, desired and maximum capacity?
42. What is stored inside a launch template?
43. What happens when an ASG instance becomes unhealthy?
44. What is a health-check grace period?
45. How does an ASG integrate with a target group?
46. What information is available in ASG Activity history?
47. What is a CloudWatch alarm?
48. What is instance warmup?
49. What is target tracking scaling?
50. What is step scaling?
51. What is simple scaling?
52. What is scheduled scaling?
53. What is predictive scaling?
54. Why should scale-in be more conservative than scale-out?
55. Which resources can continue generating charges after a lab?

---

# Key Takeaways

- Scalability handles changes in demand.
- Elasticity adjusts resources dynamically.
- High availability protects against infrastructure failure.
- Vertical scaling changes the size of one server.
- Horizontal scaling changes the number of servers.
- Horizontal scaling works best with stateless application servers.
- High availability normally requires multiple Availability Zones.
- A load balancer distributes traffic between healthy targets.
- Elastic Load Balancing is managed by AWS.
- An ALB operates at Layer 7 and understands HTTP and HTTPS.
- An NLB operates at Layer 4 and handles TCP, UDP and TLS traffic.
- ALBs support host, path, header and query-string routing.
- Listeners accept connections on configured ports.
- Listener rules select actions and target groups.
- Target groups contain application targets and health checks.
- Security groups should prevent users from bypassing the load balancer.
- Sticky sessions keep a user on the same target.
- External session storage is usually more scalable than stickiness.
- TLS encrypts traffic and verifies server identity.
- ACM can manage certificates used by an AWS load balancer.
- SNI allows multiple certificates on one HTTPS listener.
- TLS can terminate at the load balancer or continue to the target.
- Connection draining allows in-flight requests to finish.
- An ASG maintains EC2 capacity.
- Launch templates define new EC2 instances.
- Minimum, desired and maximum values control ASG capacity.
- ASGs can balance instances across Availability Zones.
- ASGs can replace unhealthy instances automatically.
- CloudWatch alarms can trigger scaling actions.
- Target tracking attempts to maintain a selected metric.
- Step scaling uses different actions for different demand levels.
- Scheduled scaling handles predictable changes.
- Predictive scaling forecasts future demand.
- Load balancers and Auto Scaling improve infrastructure, but applications must still be designed for resilience.

---

# Official AWS References

- [What is Elastic Load Balancing?](https://docs.aws.amazon.com/elasticloadbalancing/latest/userguide/what-is-load-balancing.html)
- [How Elastic Load Balancing works](https://docs.aws.amazon.com/elasticloadbalancing/latest/userguide/how-elastic-load-balancing-works.html)
- [Application Load Balancer introduction](https://docs.aws.amazon.com/elasticloadbalancing/latest/application/introduction.html)
- [Application Load Balancer listeners](https://docs.aws.amazon.com/elasticloadbalancing/latest/application/load-balancer-listeners.html)
- [Application Load Balancer target groups](https://docs.aws.amazon.com/elasticloadbalancing/latest/application/load-balancer-target-groups.html)
- [Application Load Balancer health checks](https://docs.aws.amazon.com/elasticloadbalancing/latest/application/target-group-health-checks.html)
- [Application Load Balancer security groups](https://docs.aws.amazon.com/elasticloadbalancing/latest/application/load-balancer-update-security-groups.html)
- [Application Load Balancer sticky sessions](https://docs.aws.amazon.com/elasticloadbalancing/latest/application/edit-target-group-attributes.html)
- [Application Load Balancer certificates](https://docs.aws.amazon.com/elasticloadbalancing/latest/application/https-listener-certificates.html)
- [Create an HTTPS listener](https://docs.aws.amazon.com/elasticloadbalancing/latest/application/create-https-listener.html)
- [Network Load Balancer introduction](https://docs.aws.amazon.com/elasticloadbalancing/latest/network/introduction.html)
- [Network Load Balancer listeners](https://docs.aws.amazon.com/elasticloadbalancing/latest/network/load-balancer-listeners.html)
- [Network Load Balancer target groups](https://docs.aws.amazon.com/elasticloadbalancing/latest/network/load-balancer-target-groups.html)
- [What is Amazon EC2 Auto Scaling?](https://docs.aws.amazon.com/autoscaling/ec2/userguide/what-is-amazon-ec2-auto-scaling.html)
- [Auto Scaling groups](https://docs.aws.amazon.com/autoscaling/ec2/userguide/auto-scaling-groups.html)
- [Create an ASG using a launch template](https://docs.aws.amazon.com/autoscaling/ec2/userguide/create-asg-launch-template.html)
- [ASG capacity limits](https://docs.aws.amazon.com/autoscaling/ec2/userguide/asg-capacity-limits.html)
- [ASG health checks](https://docs.aws.amazon.com/autoscaling/ec2/userguide/ec2-auto-scaling-health-checks.html)
- [Dynamic scaling](https://docs.aws.amazon.com/autoscaling/ec2/userguide/as-scale-based-on-demand.html)
- [Target tracking scaling](https://docs.aws.amazon.com/autoscaling/ec2/userguide/as-scaling-target-tracking.html)
- [Step and simple scaling](https://docs.aws.amazon.com/autoscaling/ec2/userguide/as-scaling-simple-step.html)
- [Predictive scaling](https://docs.aws.amazon.com/autoscaling/ec2/userguide/predictive-scaling-policy-overview.html)
