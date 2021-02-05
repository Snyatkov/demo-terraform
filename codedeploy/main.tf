#---Create Codedeploy role
resource "aws_iam_role" "CodeDepoy_role_for_demo" {
  name = "CodeDepoy_role_for_demo"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "",
      "Effect": "Allow",
      "Principal": {
        "Service": "codedeploy.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF
}

#---Create CodePipeline role
resource "aws_iam_role" "CodePipeline_role_for_demo" {
  name = "CodePipeline_role_for_demo"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "codepipeline.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF
}

resource "aws_iam_role_policy" "CodePipeline_policy_for_demo" {
  name = "CodePipeline_policy_for_demo"
  role = aws_iam_role.CodePipeline_role_for_demo.id

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect":"Allow",
      "Action": [
        "s3:GetObject",
        "s3:GetObjectVersion",
        "s3:GetBucketVersioning",
        "s3:PutObject"
      ],
      "Resource": [
        "${aws_s3_bucket.codepipeline_bucket.arn}",
        "${aws_s3_bucket.codepipeline_bucket.arn}/*"
      ]
    },
    {
      "Effect": "Allow",
      "Action": [
        "codebuild:BatchGetBuilds",
        "codebuild:StartBuild"
      ],
      "Resource": "*"
    }
  ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "AWSCodeDeployRole" {
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSCodeDeployRole"
  role       = aws_iam_role.CodeDepoy_role_for_demo.name
}

resource "aws_codedeploy_app" "html_to_EC2_for_demo" {
  compute_platform = "Server"
  name             = var.codedeploy_application_name
}

resource "aws_codepipeline" "Pipeline_for_demo_to_EC2" {
  name     = "Pipeline_for_demo_to_EC2"
  role_arn = aws_iam_role.CodePipeline_role_for_demo.arn

  artifact_store {
    location = aws_s3_bucket.codepipeline_bucket.bucket
    type     = "S3"
  }

  stage {
    name = "Source"

    action {
      name             = "Source"
      category         = "Source"
      owner            = "AWS"
      provider         = "CodeStarSourceConnection"
      version          = "1"
      output_artifacts = ["source_output"]

      configuration = {
        ConnectionArn    = aws_codestarconnections_connection.Con_to_github.arn
        FullRepositoryId = "snyatkov/demo-html"
        BranchName       = "main"
      }
    }
  }
  /*
  stage {
    name = "Build"

    action {
      name             = "Build"
      category         = "Build"
      owner            = "AWS"
      provider         = "CodeBuild"
      input_artifacts  = ["source_output"]
      output_artifacts = ["build_output"]
      version          = "1"

      configuration = {
        ProjectName = "test"
      }
    }
  }
*/
  stage {
    name = "Deploy"
    action {
      name            = aws_codedeploy_app.html_to_EC2_for_demo.name
      category        = "Deploy"
      owner           = "AWS"
      provider        = "CodeDeploy"
      input_artifacts = ["source_output"]
      version         = "1"

      configuration = {
        ApplicationName     = var.codedeploy_application_name
        DeploymentGroupName = aws_codedeploy_deployment_group.CodeDeploy_group_for_demo.deployment_group_name
      }
    }
    /*
    action {
      name            = "Deploy"
      category        = "Deploy"
      owner           = "AWS"
      provider        = "CloudFormation"
      input_artifacts = ["build_output"]
      version         = "1"

      configuration = {
        ActionMode     = "REPLACE_ON_FAILURE"
        Capabilities   = "CAPABILITY_AUTO_EXPAND,CAPABILITY_IAM"
        OutputFileName = "CreateStackOutput.json"
        StackName      = "MyStack"
        TemplatePath   = "build_output::sam-templated.yaml"
      }
    }*/
  }
}

resource "aws_codestarconnections_connection" "Con_to_github" {
  name          = "Con_to_github"
  provider_type = "GitHub"
}

resource "aws_s3_bucket" "codepipeline_bucket" {
  bucket = "codepipeline-bucket-demo-html"
  acl    = "private"
}

resource "aws_codedeploy_deployment_group" "CodeDeploy_group_for_demo" {
  app_name               = aws_codedeploy_app.html_to_EC2_for_demo.name
  deployment_group_name  = "CodeDeploy_group_for_demo"
  service_role_arn       = aws_iam_role.CodeDepoy_role_for_demo.arn
  autoscaling_groups     = var.autoscaling_groups
  deployment_config_name = "CodeDeployDefault.OneAtATime"
  deployment_style {
    deployment_option = "WITHOUT_TRAFFIC_CONTROL"
    deployment_type   = "IN_PLACE"
  }
  load_balancer_info {
    elb_info {
      name = var.lb_name
    }
  }
}
