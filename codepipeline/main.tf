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
      owner            = "ThirdParty"
      provider         = "GitHub"
      version          = "1"
      output_artifacts = ["source_output"]

      configuration = {
        Owner                = "bandicow"
        Repo                 = "philoberry-project"
        Branch               = "main"
        OAuthToken           = var.github_token
        PollForSourceChanges = false
      }
    }
  }

  stage {
    name = "Deploy"

    action {
      name            = "Deploy"
      category        = "Deploy"
      owner           = "AWS"
      provider        = "ECS"
      input_artifacts = ["source_output"]
      version         = "1"

      configuration = {
        ClusterName = "philoberry-ecs-cluster"
        ServiceName = var.front_ecs_service_name
        FileName    = "frontimagedefinitions.json"
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
  app_name               = aws_codedeploy_app.philoberry_app.name
  deployment_group_name  = "philoberry-deployment-group"
  service_role_arn       = aws_iam_role.codepipeline_role.arn
  deployment_config_name = "CodeDeployDefault.ECSAllAtOnce"

  blue_green_deployment_config {
    deployment_ready_option {
      action_on_timeout = "CONTINUE_DEPLOYMENT"
    }

    terminate_blue_instances_on_deployment_success {
      action                           = "TERMINATE"
      termination_wait_time_in_minutes = 5
    }
  }

  deployment_style {
    deployment_option = "WITH_TRAFFIC_CONTROL"
    deployment_type   = "BLUE_GREEN"
  }

  ecs_service {
    cluster_name = var.ecs_cluster_name
    service_name = var.front_ecs_service_name
  }

  load_balancer_info {
    target_group_pair_info {
      prod_traffic_route {
        listener_arns = [var.https_listener_arn] // [aws_lb_listener.example.arn]
      }

      target_group {
        name = var.target_group_arn
      }

      target_group {
        name = var.green_target_group_arn
      }

      test_traffic_route {
        listener_arns = [var.http_listener_arn]
      }
    }
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
      owner            = "ThirdParty"
      provider         = "GitHub"
      version          = "1"
      output_artifacts = ["source_output"]

      configuration = {
        Owner                = "bandicow"
        Repo                 = "philoberry-project"
        Branch               = "main"
        OAuthToken           = var.github_token
        PollForSourceChanges = false
      }
    }
  }

  stage {
    name = "Deploy"

    action {
      name            = "Deploy"
      category        = "Deploy"
      owner           = "AWS"
      provider        = "ECS"
      input_artifacts = ["source_output"]
      version         = "1"

      configuration = {
        ClusterName = "philoberry-ecs-cluster"
        ServiceName = var.backend_ecs_service_name
        FileName    = "backendimagedefinitions.json"
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

  blue_green_deployment_config {
    deployment_ready_option {
      action_on_timeout = "CONTINUE_DEPLOYMENT"
    }

    terminate_blue_instances_on_deployment_success {
      action                           = "TERMINATE"
      termination_wait_time_in_minutes = 5
    }
  }

  deployment_style {
    deployment_option = "WITH_TRAFFIC_CONTROL"
    deployment_type   = "BLUE_GREEN"
  }

  ecs_service {
    cluster_name = var.ecs_cluster_name
    service_name = var.backend_ecs_service_name
  }

  load_balancer_info {
    target_group_pair_info {
      prod_traffic_route {
        listener_arns = [var.https_listener_arn] // [aws_lb_listener.example.arn]
      }

      target_group {
        name = var.express_target_group_arn
      }

      target_group {
        name = var.green_express_target_group_arn
      }

      test_traffic_route {
        listener_arns = [var.http_listener_arn]
      }
    }
  }
}
