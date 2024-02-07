${jsonencode([for container_config in containers :
    {
        "user": "1000",
        "command": "${container_config.command}",
        "cpu": "${container_config.cpu}",
        "essential": "${container_config.essential}",
        "image": "${container_config.image}",
        "linuxParameters": {
            "initProcessEnabled": true,
            "capabilities": {
                "drop": ["ALL"]
            }
        },
        "privileged": false,
        "readonlyRootFilesystem": false,
        "logConfiguration": {
            "logDriver": "awslogs",
            "options": {
                "awslogs-group": "${awslogs-group}",
                "awslogs-region": "${region}",
                "awslogs-stream-prefix": "${container_config.logs_stream_prefix}"
            }
        },
        "healthCheck": {
            "command": "${container_config.health_check.command}",
            "interval": "${container_config.health_check.interval}",
            "timeout": "${container_config.health_check.timeout}",
            "retries": "${container_config.health_check.retries}",
            "startPeriod": "${container_config.health_check.start_period}"
        },
        "memory": "${container_config.memory}",
        "memoryReservation": "${container_config.memory_reservation}",
        "name": "server",
        "portMappings": [for port in container_config.ports :
            {
                "name": "${task_name}",
                "containerPort": "${port.container_port}",
                "hostPort": "${port.host_port}",
                "protocol": "${port.protocol}",
                "appProtocol": "${port.app_protocol}"
            }
        ]
    }
])}