[
  {
    "name": "${application_name}_nginx",
    "image": "${aws_nginx_repository}:${tag}",
    "essential": true,
    "logConfiguration": {
      "logDriver": "awslogs",
      "options": {
        "awslogs-region": "${region}",
        "awslogs-stream-prefix": "staging-service",
        "awslogs-group": "awslogs-service-staging-${service_type}"
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
  },
  {
    "name": "${application_name}_frontend",
    "image": "${aws_front_repository}:${tag}",
    "essential": true,
    "logConfiguration": {
      "logDriver": "awslogs",
      "options": {
        "awslogs-region": "${region}",
        "awslogs-stream-prefix": "staging-service",
        "awslogs-group": "awslogs-service-staging-${service_type}"
      }
    },
    "portMappings": [
      {
        "containerPort": ${frontend_container_port},
        "protocol": "tcp"
      }
    ],
    "healthCheck":{
      "command":["CMD-SHELL","curl -f http://localhost:3000 || exit 1"],
      "interval" :30,
      "timeout" :5,
      "retries" :3
    },
    "cpu": 2,
    "environment": [
      {
        "name": "PORT",
        "value": "3000"
      }
    ],
    "mountPoints" : [ {
      "sourceVolume": "philoberry_home",
      "containerPath": "/jenkins_philoberry_home"
    }],
    "memory": 4096,
    "volumesFrom": []
  },
  {
    "name": "${application_name}_express",
    "image": "${aws_express_repository}:${tag}",
    "essential": true,
    "logConfiguration": {
      "logDriver": "awslogs",
      "options": {
        "awslogs-region": "${region}",
        "awslogs-stream-prefix": "staging-service",
        "awslogs-group": "awslogs-service-staging-${service_type}"
      }
    },
    "portMappings": [
      {
        "containerPort": ${express_container_port},
        "protocol": "tcp"
      }
    ],
    "healthCheck":{
      "command":["CMD-SHELL","curl -f http://localhost:8000/healthcheck || exit 1"],
      "interval" :30,
      "timeout" :5,
      "retries" :3
    },
    "cpu": 1,
		"dependsOn": [
      {
        "containerName": "${application_name}_frontend",
        "condition": "HEALTHY"
      }
    ],
    "environment": [
      {
        "name": "PORT",
        "value": "8000"
      }
    ],
    "mountPoints": [],
    "memory": 2048,
    "volumesFrom": []
  }
]