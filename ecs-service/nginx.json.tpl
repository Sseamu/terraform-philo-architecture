[
  {
    "name": "${application_name}_nginx",
    "image": "${aws_nginx_repository}:${tag}",
    "essential": true,
    "logConfiguration": {
      "logDriver": "awslogs",
      "options": {
        "awslogs-region": "${region}",
        "awslogs-stream-prefix": "nginx-service",
        "awslogs-group": "awslogs-all-${service_type}"
      }
    },
    "portMappings": [
      {
        "containerPort": ${nginx_container_port},
        "protocol": "tcp"
      }
    ],
    "healthCheck":{
      "command":["CMD-SHELL","curl -f http://localhost:80 || exit 1"],
      "interval" :30,
      "timeout" :5,
      "retries" :3
    },
    "serviceRegistries": [
      {
        "registryArn": "${registry_arn}"
      }
    ],
    "cpu": 1,
    "environment": [
      {
        "name": "PORT",
        "value": "80"
      }
    ],
    "mountPoints": [],
    "memory": 1024,
    "volumesFrom": []
  }
]