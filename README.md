# SETA-ED District Upload Portal (S3 + CloudFront + Presigned POST + SES Notify)

This package contains:
- `cloudformation/setaed-upload-portal.yaml` - Creates S3 buckets, KMS, CloudFront + ACM, API Gateway, Lambda presign, and S3->Lambda email notification.
- `site/index.html` - Static upload portal (drag & drop) that requests a presigned POST and uploads directly to S3.

## Prereqs (us-east-1)
1) **ACM Certificate** in us-east-1 for `data.seta-ed.com` (or your chosen domain).
2) **SES** in us-east-1:
   - Verify `uploads@seta-ed.com` (or verify domain `seta-ed.com`).
   - If SES is in Sandbox, you can only send to verified recipients.

## Deploy CloudFormation
Example:
```bash
aws cloudformation deploy \
  --region us-east-1 \
  --stack-name setaed-upload-portal \
  --template-file cloudformation/setaed-upload-portal.yaml \
  --capabilities CAPABILITY_NAMED_IAM \
  --parameter-overrides \
      SiteDomainName=data.seta-ed.com \
      AcmCertificateArn=arn:aws:acm:us-east-1:...:certificate/... \
      HostedZoneId=ZXXXXXXXXXXXXX
```

If you are not using Route53, omit HostedZoneId.

## Update `index.html` with API endpoint
After stack deploy, grab the output `HttpApiEndpoint`, and replace:
`REPLACE_WITH_HTTP_API_ENDPOINT`
inside `site/index.html`.

## Upload the  upload web site to the SiteBucket
Get `SiteBucketName` from CloudFormation outputs:
```bash
aws s3 cp site/index.html s3://setaed-upload-portal-sitebucket-x0ifyn8pvg4i/index.html
aws s3 cp site/favicon.ico s3://setaed-upload-portal-sitebucket-x0ifyn8pvg4i/favicon.ico
#refresh/invalidate cloudfront cache
aws cloudfront list-distributions --query "DistributionList.Items[*].{Id:Id,Domain:DomainName,Aliases:Aliases.Items}" --output table
aws cloudfront create-invalidation --distribution-id E27SPGJH7SHU0F  --paths "/*"
```

Then open the portal URL from outputs:
- `https://data.seta-ed.com/` (if custom domain)
- or CloudFront domain URL.

## What happens on upload
- Browser requests `/presign` from API Gateway.
- Lambda returns a presigned POST with constraints (1GB, encrypted SSE-KMS).
- Browser uploads directly to UploadDataBucket.
- S3 triggers notifier Lambda.
- Notifier sends email to ivy@seta-ed.com with a presigned download link.

