resource "aws_codepipeline" "frontend_codepipeline" {
  name     = "philoberry-frontend-pipleline"
  role_arn = aws_iam_role.codepipeline_role.arn

  artifact_store {
    location = aws_s3_bucket.codepipeline_bucket.bucket
    type     = "S3"
  }

  stage {
    name = "Source"

    action {
      name             = "Source"
      category         = "Source"
      owner            = "ThirdParty"
      provider         = "GitHub"
      version          = "1"
      output_artifacts = ["source_output"]

      configuration = {
        Owner      = "bandicow" //github owner
        Repo       = "philoberry-project"
        Branch     = "main"
        OAuthToken = var.github_token
      }

    }
  }

  stage {
    name = "Deploy"

    action {
      name            = "Deploy"
      category        = "Deploy"
      owner           = "AWS"
      provider        = "CodeDeployToECS"
      input_artifacts = ["source_output"]
      version         = "1"

      configuration = {
        ApplicationName     = aws_codedeploy_app.philoberry_app.name
        DeploymentGroupName = aws_codedeploy_deployment_group.group.deployment_group_name
      }
    }
  }
}


resource "aws_codedeploy_app" "philoberry_app" {
  compute_platform = "ECS"
  name             = "philoberry_front_app"
}

resource "aws_codedeploy_deployment_group" "group" {
  app_name              = aws_codedeploy_app.philoberry_app.name
  deployment_group_name = "philoberry-deployment-group"
  service_role_arn      = aws_iam_role.codepipeline_role.arn

  deployment_config_name = "CodeDeployDefault.ECSAllAtOnce"

  ecs_service {
    cluster_name = var.ecs_cluster_name
    service_name = var.front_ecs_service_name
  }
}

resource "aws_codepipeline" "backend_codepipeline" {
  name     = "philoberry-backend-pipleline"
  role_arn = aws_iam_role.codepipeline_role.arn

  artifact_store {
    location = aws_s3_bucket.codepipeline_bucket.bucket
    type     = "S3"
  }

  stage {
    name = "Source"

    action {
      name             = "Source"
      category         = "Source"
      owner            = "ThirdParty"
      provider         = "GitHub"
      version          = "1"
      output_artifacts = ["source_output"]

      configuration = {
        Owner      = "bandicow" //github owner
        Repo       = "philoberry-project"
        Branch     = "main" // 백엔드 코드 위치에 따라 이를 수정해야 할 수 있습니다.
        OAuthToken = var.github_token
      }

    }
  }

  stage {
    name = "Deploy"

    action {
      name            = "Deploy"
      category        = "Deploy"
      owner           = "AWS"
      provider        = "CodeDeployToECS"
      input_artifacts = ["source_output"]
      version         = "1"

      configuration = {
        ApplicationName     = aws_codedeploy_app.backend_app.name
        DeploymentGroupName = aws_codedeploy_deployment_group.backend_group.deployment_group_name
      }
    }
  }
}



resource "aws_codedeploy_app" "backend_app" {
  compute_platform = "ECS"
  name             = "philoberry_back_app"
}

resource "aws_codedeploy_deployment_group" "backend_group" {
  app_name              = aws_codedeploy_app.backend_app.name
  deployment_group_name = "philoberry-backend-deployment-group"
  service_role_arn      = aws_iam_role.codepipeline_role.arn

  deployment_config_name = "CodeDeployDefault.ECSAllAtOnce"

  ecs_service {
    cluster_name = var.ecs_cluster_name
    service_name = var.backend_ecs_service_name
  }
}
