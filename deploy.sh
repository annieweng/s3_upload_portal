#setup aws credential first
#validate the template
aws cloudformation validate-template   --region us-east-1   --template-body file://cloudformation/setaed-upload-portal.yaml
#deploy the stack
aws cloudformation deploy \
  --region us-east-1 \
  --stack-name setaed-upload-portal \
  --template-file cloudformation/setaed-upload-portal.yaml \
  --capabilities CAPABILITY_NAMED_IAM \
  --parameter-overrides \
      SiteDomainName=data.seta-ed.com \
      AcmCertificateArn=arn:aws:acm:us-east-1:396231126076:certificate/1a9d32b2-850f-41b2-a056-46fb69a52259 \
      NotifyFromEmail=uploads@seta-ed.com \
      NotifyToEmail=ivy@seta-ed.com,melina@seta-ed.com,yun-en@seta-ed.com