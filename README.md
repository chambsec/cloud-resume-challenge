# Cloud Resume Challenge — AWS Edition

**🌐 Live Site:** [chamb.dev](https://www.chamb.dev) &nbsp;|&nbsp; **👤 Author:** [Jamar Chambers](https://www.linkedin.com/in/chambsec/)

---

## The Story Behind This Project

I'm a Radiologic Technologist with nearly a decade of experience at places like Memorial Sloan Kettering Cancer Center. For years I worked inside some of the most regulated data environments in healthcare — managing audit logs, enforcing HIPAA compliance, governing access controls on clinical imaging systems.

At some point I realized something: I was already thinking like a security engineer. I just didn't have the cloud infrastructure skills to match.

So I decided to build them.

The Cloud Resume Challenge by Forrest Brazeal was the first real project I tackled. The goal sounds simple — host your resume on AWS. But the deeper you go, the more you realize it's actually a full-stack cloud engineering project in disguise. By the end I had built a serverless backend, written infrastructure as code, and set up an automated CI/CD pipeline. All from scratch.

This is that project.

---

## What I Built

### Architecture

```
Browser → GoDaddy DNS (chamb.dev)
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
- Resume written in HTML and CSS, hosted on **Amazon S3** as a static website
- Served globally via **Amazon CloudFront** with HTTPS enforced through **AWS Certificate Manager**
- Custom domain `chamb.dev` connected via GoDaddy CNAME records
- **AWS WAF** enabled on CloudFront for protection against common web threats

### Backend
- Live visitor counter that increments on every visit
- **AWS Lambda** (Python 3.12) reads and updates the count atomically
- Count stored in **Amazon DynamoDB**
- **Amazon API Gateway** exposes a public `/count` HTTP endpoint
- CORS configured so only `www.chamb.dev` can call the API

### Infrastructure as Code
- All backend resources defined and managed with **Terraform**
- Existing manually-built resources imported into Terraform state
- IAM roles scoped with least-privilege — Lambda only has the exact DynamoDB permissions it needs

### CI/CD Pipeline
- **GitHub Actions** automatically deploys on every push to `main`
- Uploads `index.html` to S3 and invalidates the CloudFront cache
- AWS credentials stored as encrypted GitHub Secrets — never in code
- Full deployment completes in under 60 seconds

---

## The Real Challenges

I want to be honest about this — it wasn't smooth. Here are the real problems I ran into and how I worked through them.

### DNS Almost Broke Me
The SSL certificate for `www.chamb.dev` got stuck on "Pending validation" for hours. Turned out my CNAME record in GoDaddy was missing the `www` prefix in the Name field — a single detail that silently broke everything. I learned to verify DNS records character by character and use [dnschecker.org](https://dnschecker.org) to watch propagation in real time.

### Wrong Region, No Certificate
When I went to attach my SSL certificate to CloudFront, the dropdown was completely empty. Spent time troubleshooting before discovering that CloudFront only accepts ACM certificates created in `us-east-1` — no exceptions. My certificate was in `us-east-2`. Had to request a new one in the right region.

### The Visitor Counter That Wouldn't Work
My Lambda function tested perfectly in the AWS console. But the visitor counter on my live site showed `—` no matter what. The culprit was CORS — the browser was blocking the API call from `chamb.dev` because the response was missing an `Access-Control-Allow-Origin` header. Browser DevTools → Network tab revealed it immediately. Fixed it by updating Lambda to return explicit CORS headers and adding an OPTIONS route in API Gateway.

### GoDaddy and the Root Domain Problem
GoDaddy doesn't allow CNAME records on the root domain (`@`), so I couldn't point `chamb.dev` directly at CloudFront. The workaround was using GoDaddy's built-in domain forwarding to redirect `chamb.dev` → `https://www.chamb.dev`, which then resolves via CNAME to CloudFront.

### Terraform Didn't Know What I'd Already Built
After writing all my Terraform config, running `terraform plan` showed zero changes — because I had built everything manually first. Had to use `terraform import` to pull each resource into Terraform state one by one. The IAM role had a different path than expected (`/service-role/`) which would have caused Terraform to destroy and recreate it. Caught it by carefully reading the plan output before applying.

### GitHub Actions Couldn't Find My File
The CI/CD pipeline failed immediately with "index.html does not exist." Simple fix — the file wasn't committed to the repo. GitHub Actions runs against your repository, not your local machine. Lesson learned.

---

## What I Learned

Beyond the technical skills, this project taught me how to troubleshoot systematically. Every problem I hit had a root cause. The key was testing each layer independently — Lambda first, then API Gateway, then the browser — instead of guessing at the whole system at once.

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

**Tools:** Terraform · GitHub Actions · Python 3.12 · HTML/CSS · AWS CLI · Git

---

## Author

**Jamar Chambers** — R.T. (R) (ARRT) · M.S. Cybersecurity  
Radiologic Technologist → Cloud Security Engineer  
[chamb.dev](https://www.chamb.dev) · [LinkedIn](https://www.linkedin.com/in/chambsec/) · [GitHub](https://github.com/chambsec)

