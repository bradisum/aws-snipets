# create a repository
#export AWS_DEFAULT_REGION=eu-west-1
#aws codecommit create-repository --repository-name aws-velocity

# SECURITY GROUPS ]================================================================

# create security group and add rules
aws ec2 create-security-group --group-name cli-sg-web_ssh --description "CLI Web + SSH"
aws ec2 authorize-security-group-ingress --group-id sg-05adc831109d9f0a4 --protocol tcp --port 22 --cidr 0.0.0.0/0
aws ec2 authorize-security-group-ingress --group-id sg-05adc831109d9f0a4 --protocol tcp --port 80 --cidr 0.0.0.0/0


aws ec2 create-security-group --group-name cli-sg-web --description "CLI Web"
aws ec2 authorize-security-group-ingress --group-id .... --protocol tcp --port 80 --cidr 0.0.0.0/0


# list securituy groups
aws ec2 describe-security-groups --group-names my-sg



# LOAD BLAANCER ]====================================================================

# create elb
aws elbv2 create-load-balancer \
--name cli-load-balancer \
--security-groups sg-010a9c1c0a2c8dccb \
--subnets subnet-0394134f subnet-54144b2e subnet-d17a9cba

# create a target group for the elb
aws elbv2 create-target-group \
    --name cli-targets \
    --protocol HTTP \
    --port 80 \
    --target-type instance \
    --vpc-id vpc-3b1be550

# create a listener with a default action to forward to a target group
aws elbv2 create-listener \
    --load-balancer-arn arn:aws:elasticloadbalancing:us-east-2:999505691857:loadbalancer/app/cli-load-balancer/9b9c5ae70dfa0a13 \
    --protocol HTTP \
    --port 80 \
    --default-actions Type=forward,TargetGroupArn=arn:aws:elasticloadbalancing:us-east-2:999505691857:targetgroup/cli-targets/73bd1fb6d2bb1490

# (optional) create a specific rule to forward  (optional)
aws elbv2 create-rule \
    --listener-arn arn:aws:elasticloadbalancing:us-west-2:123456789012:listener/app/my-load-balancer/50dc6c495c0c9188/f2f7dc8efc522ab2 \
    --priority 5 \
    --conditions file://conditions-pattern.json \
    --actions Type=forward,TargetGroupArn=arn:aws:elasticloadbalancing:us-east-2:999505691857:targetgroup/cli-targets/73bd1fb6d2bb1490



# AUTO SCALING ]=======================================================================

# create launch config
aws autoscaling create-launch-configuration \
    --launch-configuration-name cli-launch-config \
    --key-name bill.awsone \
    --image-id ami-0dacb0c129b49f529 \
    --instance-type t2.micro \
    --security-groups sg-05adc831109d9f0a4 \
    --user-data file://ec2_userdata.txt


# create asg
aws autoscaling create-auto-scaling-group \
    --auto-scaling-group-name cli-asg \
    --launch-configuration-name cli-launch-config \
    --health-check-type ELB \
    --health-check-grace-period 120 \
    --min-size 1 \
    --max-size 3 \
    --target-group-arns arn:aws:elasticloadbalancing:us-east-2:999505691857:targetgroup/cli-targets/73bd1fb6d2bb1490 \
    --vpc-zone-identifier "subnet-0394134f,subnet-54144b2e,subnet-d17a9cba"
    #--load-balancer-names cli-load-balancer \ # only for clasic load balancers otherwise select --target-group-arns


# (optional) register targets from cli with instance ids (dont need this as create-autocscaling-group includes target-groups-arn)
aws elbv2 register-targets \
    --target-group-arn arn:aws:elasticloadbalancing:us-west-2:123456789012:targetgroup/my-targets/73e2d6bc24d8a067 \
    --targets Id=i-1234567890abcdef0 Id=i-0abcdef1234567890


# CODE DEPLOY


# create application
aws deploy create-application --application-name cli-giftbot-app


# create deployment group
aws deploy create-deployment-group \
    --application-name cli-giftbot-app \
    --auto-scaling-groups cli-asg \
    --deployment-config-name CodeDeployDefault.OneAtATime \
    --deployment-group-name cli-giftbot-deployment-group \
    --ec2-tag-filters Key=Name,Value=CodeDeployDemo,Type=KEY_AND_VALUE \
    --service-role-arn arn:aws:iam::123456789012:role/CodeDeployDemoRole


# create pipeline
aws codepipeline create-pipeline --cli-input-json file://pipeline.json


# (OPTIONAL) EC2 COMMANDS ]=================================================================== 

# list all instances
aws ec2 describe-instances --output table

# list but format nicely
aws ec2 describe-instances --query 'Reservations[*].Instances[*].[Placement.AvailabilityZone, State.Name, InstanceId]' --output text

# terminate an instance
aws ec2 terminate-instances --instance-ids i-0f8947fb708a6bdf9








