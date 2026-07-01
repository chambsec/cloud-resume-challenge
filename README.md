# Cloud Resume Challenge — AWS Edition

**Live Site:** [chamb.dev](https://chamb.dev) &nbsp;|&nbsp; **Author:** [Chris Chambers](https://www.linkedin.com/in/chambsec/)

---

## What This Became

The Cloud Resume Challenge was the starting point. What it grew into is a full personal brand platform running on AWS with an autonomous publishing pipeline, a private Command Center, and a complete serverless architecture.

If you want to see where this project ended up, the full source and documentation is at [chambsec/chamb-dev](https://github.com/chambsec/chamb-dev).

---

## The Story Behind This Project

I spent years working in highly regulated healthcare environments, managing audit logs, enforcing HIPAA compliance, and maintaining strict access controls for clinical imaging systems. Over time I realized I was already approaching problems with a security-first mindset. I just wanted to expand those skills into cloud engineering.

That realization pushed me to start building.

The Cloud Resume Challenge by Forrest Brazeal became my first major cloud project. What starts as a simple idea, hosting a resume on AWS, quickly turns into a hands-on lesson in real-world cloud engineering. Through the project I built a serverless backend, implemented infrastructure as code, and created an automated CI/CD pipeline from the ground up.

This project represents the transition from working with secure healthcare systems to building modern cloud infrastructure.

---

## What I Built

### Architecture

```
Browser → Cloudflare DNS (chamb.dev)
       → CloudFront CDN (HTTPS + WAF)
       → S3 (Static Website Hosting)

Browser → API Gateway (GET /count)
       → Lambda (Python 3.12)
       → DynamoDB (visitor-counter table)

GitHub Push → GitHub Actions
           → S3 Deploy
           → CloudFront Cache Invalidation
```

### Frontend
- Resume written in HTML and CSS, hosted on Amazon S3 as a static website
- Served globally via Amazon CloudFront with HTTPS enforced through AWS Certificate Manager
- Custom domain chamb.dev connected via Cloudflare DNS with CNAME flattening on the root domain
- AWS WAF enabled on CloudFront for protection against common web threats

### Backend
- Live visitor counter that increments on every visit
- AWS Lambda (Python 3.12) reads and updates the count atomically
- Count stored in Amazon DynamoDB
- Amazon API Gateway exposes a public /count HTTP endpoint
- CORS configured so only chamb.dev can call the API

### Infrastructure as Code
- All backend resources defined and managed with Terraform
- Existing manually-built resources imported into Terraform state
- IAM roles scoped with least-privilege — Lambda only has the exact DynamoDB permissions it needs

### CI/CD Pipeline
- GitHub Actions automatically deploys on every push to main
- Uploads index.html to S3 and invalidates the CloudFront cache
- AWS credentials stored as encrypted GitHub Secrets, never in code
- Full deployment completes in under 60 seconds

---

## The Real Challenges

Here are the real problems I ran into and how I worked through them.

### DNS Almost Broke Me
The SSL certificate for chamb.dev got stuck on "Pending validation" for hours. Turned out my CNAME record was missing a detail that silently broke everything. I learned to verify DNS records character by character and use dnschecker.org to watch propagation in real time.

Later in the project I migrated DNS from GoDaddy to Cloudflare entirely. GoDaddy was locking A records I needed to change and didn't support CNAME flattening on the root domain. Cloudflare solved both problems.

### Wrong Region, No Certificate
When I went to attach my SSL certificate to CloudFront the dropdown was completely empty. Spent time troubleshooting before discovering that CloudFront only accepts ACM certificates created in us-east-1, no exceptions. My certificate was in us-east-2. Had to request a new one in the right region.

### The Visitor Counter That Wouldn't Work
My Lambda function tested perfectly in the AWS console. But the visitor counter on my live site showed nothing no matter what. The culprit was CORS. The browser was blocking the API call because the response was missing an Access-Control-Allow-Origin header. Browser DevTools revealed it immediately. Fixed it by updating Lambda to return explicit CORS headers and adding an OPTIONS route in API Gateway.

### Terraform Didn't Know What I Had Already Built
After writing all my Terraform config, running terraform plan showed zero changes because I had built everything manually first. Had to use terraform import to pull each resource into Terraform state one by one. The IAM role had a different path than expected which would have caused Terraform to destroy and recreate it. Caught it by carefully reading the plan output before applying.

### GitHub Actions Couldn't Find My File
The CI/CD pipeline failed immediately with "index.html does not exist." Simple fix. The file wasn't committed to the repo. GitHub Actions runs against your repository, not your local machine.

---

## What I Learned

Beyond the technical skills, this project taught me how to troubleshoot systematically. Every problem I hit had a root cause. The key was testing each layer independently, Lambda first, then API Gateway, then the browser, instead of guessing at the whole system at once.

I also learned that my healthcare background isn't baggage I need to leave behind. Understanding HIPAA, audit logging, access controls, and compliance frameworks made IAM least-privilege and security-first design feel completely natural. That's the angle I bring to cloud security that most engineers don't have.

---

## AWS Services Used

| Service | Purpose |
|---|---|
| S3 | Static website hosting |
| CloudFront | Global CDN, HTTPS enforcement, WAF |
| ACM | Free SSL/TLS certificate |
| Lambda | Serverless visitor counter function |
| DynamoDB | Persistent visitor count storage |
| API Gateway | HTTP API endpoint |
| IAM | Least-privilege roles and policies |
| CloudWatch | Lambda logging and monitoring |

**Tools:** Terraform · GitHub Actions · Python 3.12 · HTML/CSS · AWS CLI · Git · Cloudflare

---

## Author

**Chris Chambers** — R.T.(R) (ARRT) · M.S. Cybersecurity
Radiologic Technologist → Cloud Security Engineer
[chamb.dev](https://chamb.dev) · [LinkedIn](https://www.linkedin.com/in/chambsec/) · [GitHub](https://github.com/chambsec)

