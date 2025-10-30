[
  {
    "name": "prometheus",
    "image": "${prometheus_image}",
    "essential": true,
    "portMappings": [
      {
        "containerPort": ${prometheus_port},
        "hostPort": ${prometheus_port},
        "protocol": "tcp"
      }
    ],
    "mountPoints": [
      {
        "sourceVolume": "prometheus-data",
        "containerPath": "/prometheus",
        "readOnly": false
      },
      {
        "sourceVolume": "prometheus-config",
        "containerPath": "/etc/prometheus",
        "readOnly": true
      }
    ],
    "environment": [
      {
        "name": "AWS_REGION",
        "value": "${region}"
      }
    ],
    "command": [
      "--config.file=/etc/prometheus/prometheus.yml",
      "--storage.tsdb.path=/prometheus",
      "--storage.tsdb.retention.time=${retention_period}",
      "--web.console.libraries=/usr/share/prometheus/console_libraries",
      "--web.console.templates=/usr/share/prometheus/consoles",
      "--web.enable-lifecycle"
    ],
    "logConfiguration": {
      "logDriver": "awslogs",
      "options": {
        "awslogs-group": "${log_group}",
        "awslogs-region": "${region}",
        "awslogs-stream-prefix": "prometheus"
      }
    },
    "memory": 2048,
    "cpu": 1024
  },
  {
    "name": "prometheus-config-reloader",
    "image": "jimmidyson/configmap-reload:v0.7.1",
    "essential": true,
    "volumesFrom": [],
    "mountPoints": [
      {
        "sourceVolume": "prometheus-config",
        "containerPath": "/etc/prometheus",
        "readOnly": true
      }
    ],
    "environment": [],
    "command": [
      "--volume-dir=/etc/prometheus",
      "--webhook-url=http://localhost:${prometheus_port}/-/reload"
    ],
    "logConfiguration": {
      "logDriver": "awslogs",
      "options": {
        "awslogs-group": "${log_group}",
        "awslogs-region": "${region}",
        "awslogs-stream-prefix": "prometheus-config-reloader"
      }
    },
    "memory": 128,
    "cpu": 128
  }
]