resource "aws_codepipeline" "frontend_codepipeline" {
  name     = "philoberry-frontend-pipeline"
  role_arn = aws_iam_role.codepipeline_role.arn

  artifact_store {
    location = aws_s3_bucket.front_codepipeline_bucket.bucket
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
        ConnectionArn    = aws_codestarconnections_connection.github.arn
        FullRepositoryId = "bandicow/philoberry-project" // Owner/Repo 형식으로 설정합니다.
        BranchName       = "main"
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

resource "aws_codestarconnections_connection" "github" {
  provider_type = "GitHub"
  name          = "github-connection"
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
    location = aws_s3_bucket.backend_codepipeline_bucket.bucket
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
        ConnectionArn    = aws_codestarconnections_connection.github.arn
        FullRepositoryId = "bandicow/philoberry-project" // Owner/Repo 형식으로 설정합니다.
        BranchName       = "main"
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
  name             = "philoberry_backend_app"
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
