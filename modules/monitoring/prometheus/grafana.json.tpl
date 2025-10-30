[
  {
    "name": "grafana",
    "image": "${grafana_image}",
    "essential": true,
    "portMappings": [
      {
        "containerPort": ${grafana_port},
        "hostPort": ${grafana_port},
        "protocol": "tcp"
      }
    ],
    "mountPoints": [
      {
        "sourceVolume": "grafana-data",
        "containerPath": "/var/lib/grafana",
        "readOnly": false
      }
    ],
    "environment": [
      {
        "name": "GF_SECURITY_ADMIN_USER",
        "value": "${admin_user}"
      },
      {
        "name": "GF_SECURITY_ADMIN_PASSWORD",
        "value": "${admin_password}"
      },
      {
        "name": "GF_INSTALL_PLUGINS",
        "value": "grafana-piechart-panel,grafana-worldmap-panel"
      },
      {
        "name": "GF_SERVER_ROOT_URL",
        "value": "https://%(domain)s/"
      },
      {
        "name": "GF_PATHS_PROVISIONING",
        "value": "/etc/grafana/provisioning"
      },
      {
        "name": "GF_AUTH_ANONYMOUS_ENABLED",
        "value": "false"
      },
      {
        "name": "GF_DASHBOARDS_DEFAULT_HOME_DASHBOARD_PATH",
        "value": "/etc/grafana/provisioning/dashboards/slurm-overview.json"
      }
    ],
    "logConfiguration": {
      "logDriver": "awslogs",
      "options": {
        "awslogs-group": "${log_group}",
        "awslogs-region": "${region}",
        "awslogs-stream-prefix": "grafana"
      }
    },
    "healthCheck": {
      "command": [
        "CMD-SHELL",
        "wget -q --spider http://localhost:${grafana_port}/api/health || exit 1"
      ],
      "interval": 30,
      "timeout": 5,
      "retries": 3,
      "startPeriod": 60
    },
    "memory": 1024,
    "cpu": 512
  }
]