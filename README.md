# AWS Learning

This repository documents my AWS learning, revision notes and hands-on cloud projects completed as part of the CoderCo DevOps Academy.

The repository covers AWS fundamentals, IAM, EC2, storage, networking, load balancing, containers, serverless, Route 53 and CloudFront, alongside practical projects built in the AWS Console.

---

## Repository Contents

### 1. Introduction to AWS
AWS fundamentals, global infrastructure, Regions, Availability Zones, edge locations and core cloud concepts.

[View Introduction to AWS](./01-introduction-to-aws.md)

### 2. IAM
Users, groups, roles, policies, least privilege, MFA and access management.

[View IAM Notes](./02-iam.md)

### 3. EC2 and Compute
EC2 instances, instance types, AMIs, user data, pricing models and compute services.

[View EC2 and Compute](./03-ec2-and-compute.md)

### 4. Security Groups and Cloud Networking Basics
Security Groups, inbound/outbound rules, ports, protocols and basic AWS network security.

[View Security Groups and Cloud Networking](./04-security-group-and-cloud-networking-basics.md)

### 5. Storage
EBS, EFS, S3, storage classes, snapshots, lifecycle management and AWS storage concepts.

[View Storage Notes](./05-storage.md)

### 6. Load Balancing and Scalability
Elastic Load Balancing, target groups, Auto Scaling, launch templates, health checks and high availability.

[View Load Balancing and Scalability](./06-load-balancing-and-scalability.md)

### 7. Containers on AWS
ECS, ECR, Fargate and AWS container services.

[View Containers on AWS](./07-containers-on-aws.md)

### 8. Serverless
Lambda, DynamoDB, API Gateway and serverless application concepts.

[View Serverless Notes](./08-serverless.md)

### 9. AWS Networking
VPCs, subnets, route tables, Internet Gateways, NAT Gateways, VPC peering and AWS networking.

[View AWS Networking](./09-aws-networking.md)

### 10. DNS and Route 53
DNS fundamentals, hosted zones, records, routing policies, health checks and Route 53.

[View DNS and Route 53](./10-dns-route53.md)

### 11. CDN and CloudFront
Content delivery networks, CloudFront distributions, origins, caching, HTTPS and invalidations.

[View CDN and CloudFront](./11-cdn-cloudfront.md)

---

## Hands-On AWS Projects

### Assignment 1 — VPC and Networking
Built a custom VPC with public and private subnets, route tables, an Internet Gateway, NAT Gateway, EC2 instances, Security Groups and bastion-style access.

[View Assignment 1](./assignments/01-vpc-networking/)

### Assignment 2 — Application Load Balancer and Auto Scaling
Built a multi-AZ web architecture using private EC2 instances, an Application Load Balancer, target groups, Auto Scaling, Route 53, ACM and HTTPS.

[View Assignment 2](./assignments/02-alb-auto-scaling/)

### Assignment 3 — S3, CloudFront and Route 53
Hosted a static website in S3, delivered it through CloudFront, configured a custom domain with Route 53 and HTTPS, and tested cache invalidation.

[View Assignment 3](./assignments/03-s3-cloudfront-route53/)

### Assignment 4 — Serverless API
Built a serverless API using API Gateway, Lambda, DynamoDB, IAM and CloudWatch.

[View Assignment 4](./assignments/04-serverless-api/)

---

## Learning Progression

```text
AWS Fundamentals
       |
       v
IAM and Security
       |
       v
EC2 and Storage
       |
       v
Networking
       |
       v
Load Balancing and Auto Scaling
       |
       v
Containers and Serverless
       |
       v
Route 53 and CloudFront
       |
       v
Hands-On AWS Projects
       |
       v
Terraform / Infrastructure as Code
```

---

## Core AWS Skills

| Category | Skills |
|---|---|
| Compute | EC2, AMIs, instance types and user data |
| Identity | IAM users, roles, policies, MFA and least privilege |
| Networking | VPCs, subnets, route tables, IGWs, NAT Gateways and Security Groups |
| Storage | S3, EBS, EFS, snapshots and storage classes |
| Availability | ALB, target groups, health checks and Auto Scaling |
| DNS | Route 53 hosted zones, records and routing policies |
| CDN | CloudFront distributions, caching and invalidations |
| Serverless | Lambda, API Gateway and DynamoDB |
| Monitoring | CloudWatch logs and metrics |
| Security | ACM, HTTPS, IAM permissions and network controls |

---

## Why AWS Matters in DevOps

AWS provides the infrastructure and managed services used to build, deploy, scale and monitor modern applications.

Learning AWS has helped me understand how compute, networking, security, storage, DNS, monitoring and application delivery work together in a cloud environment.

The hands-on projects were especially useful because they required me to troubleshoot real configuration issues rather than only learn the theory.

---

## Skills Developed

- Building custom VPC networks
- Configuring public and private subnets
- Managing EC2 instances
- Applying Security Groups and IAM permissions
- Configuring NAT and internet access
- Building highly available ALB architectures
- Using Auto Scaling and health checks
- Managing DNS with Route 53
- Configuring HTTPS with ACM
- Hosting static websites with S3
- Delivering content with CloudFront
- Building Lambda-based serverless APIs
- Storing data in DynamoDB
- Reading CloudWatch logs
- Troubleshooting AWS networking and service integrations
- Cleaning up chargeable AWS resources
- Documenting cloud projects in GitHub

---

## Security Reminder

Never commit:

- AWS access keys
- Secret access keys
- Session tokens
- Passwords
- `.pem` private keys
- API secrets
- Other credentials or sensitive information

Use IAM least privilege, MFA and appropriate secret-management practices.

---

## Next Step

The next stage of my DevOps learning is:

```text
Terraform
Infrastructure as Code
Reusable AWS infrastructure
Automation
```

---

## Author

**Abubakar Mohamed**

Aspiring DevOps Engineer currently completing the CoderCo DevOps Academy.

[Connect with me on LinkedIn](https://www.linkedin.com/in/abubakar-mohamed-3047a5211/)
