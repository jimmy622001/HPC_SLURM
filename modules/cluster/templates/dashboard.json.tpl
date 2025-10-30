{
    "widgets": [
        {
            "type": "text",
            "x": 0,
            "y": 0,
            "width": 24,
            "height": 2,
            "properties": {
                "markdown": "# ${cluster_name} - SLURM Cluster Dashboard\nThis dashboard provides monitoring for the SLURM cluster components including head node, compute nodes, and job statistics."
            }
        },
        {
            "type": "metric",
            "x": 0,
            "y": 2,
            "width": 8,
            "height": 6,
            "properties": {
                "view": "timeSeries",
                "stacked": false,
                "metrics": [
                    [ "AWS/EC2", "CPUUtilization", "InstanceId", "i-HEADNODEPLACEHOLDER", { "label": "Head Node CPU" } ]
                ],
                "region": "${region}",
                "title": "Head Node CPU Utilization"
            }
        },
        {
            "type": "metric",
            "x": 8,
            "y": 2,
            "width": 8,
            "height": 6,
            "properties": {
                "view": "timeSeries",
                "stacked": false,
                "metrics": [
                    [ "AWS/EC2", "NetworkIn", "InstanceId", "i-HEADNODEPLACEHOLDER", { "label": "Network In" } ],
                    [ "AWS/EC2", "NetworkOut", "InstanceId", "i-HEADNODEPLACEHOLDER", { "label": "Network Out" } ]
                ],
                "region": "${region}",
                "title": "Head Node Network Traffic"
            }
        },
        {
            "type": "metric",
            "x": 16,
            "y": 2,
            "width": 8,
            "height": 6,
            "properties": {
                "view": "timeSeries",
                "stacked": false,
                "metrics": [
                    [ "CWAgent", "mem_used_percent", "InstanceId", "i-HEADNODEPLACEHOLDER", { "label": "Memory Used %" } ]
                ],
                "region": "${region}",
                "title": "Head Node Memory Usage"
            }
        },
        {
            "type": "metric",
            "x": 0,
            "y": 8,
            "width": 12,
            "height": 6,
            "properties": {
                "view": "timeSeries",
                "stacked": true,
                "metrics": [
                    [ "AWS/AutoScaling", "GroupInServiceInstances", "AutoScalingGroupName", "compute-nodes", { "label": "Compute Nodes (Running)" } ]
                ],
                "region": "${region}",
                "title": "Compute Nodes Count"
            }
        },
        {
            "type": "metric",
            "x": 12,
            "y": 8,
            "width": 12,
            "height": 6,
            "properties": {
                "view": "timeSeries",
                "stacked": false,
                "metrics": [
                    [ "AWS/EC2", "CPUUtilization", "AutoScalingGroupName", "compute-nodes", { "stat": "Average", "label": "Average CPU" } ],
                    [ "AWS/EC2", "CPUUtilization", "AutoScalingGroupName", "compute-nodes", { "stat": "Maximum", "label": "Max CPU" } ],
                    [ "AWS/EC2", "CPUUtilization", "AutoScalingGroupName", "compute-nodes", { "stat": "Minimum", "label": "Min CPU" } ]
                ],
                "region": "${region}",
                "title": "Compute Nodes CPU Utilization"
            }
        },
        {
            "type": "log",
            "x": 0,
            "y": 14,
            "width": 24,
            "height": 6,
            "properties": {
                "query": "SOURCE '/aws/parallelcluster/${cluster_name}' | fields @timestamp, @message\n| filter @message like /slurm/\n| sort @timestamp desc\n| limit 100",
                "region": "${region}",
                "title": "SLURM Scheduler Logs",
                "view": "table"
            }
        },
        {
            "type": "metric",
            "x": 0,
            "y": 20,
            "width": 12,
            "height": 6,
            "properties": {
                "view": "timeSeries",
                "stacked": false,
                "metrics": [
                    [ { "expression": "SEARCH('{AWS/Usage,Resource,Service,Type} Resource=\"${cluster_name}\" MetricName=\"ResourceCount\" Service=\"ParallelCluster\"', 'Average', 300)", "id": "e1", "period": 300 } ]
                ],
                "region": "${region}",
                "title": "SLURM Jobs Running"
            }
        },
        {
            "type": "metric",
            "x": 12,
            "y": 20,
            "width": 12,
            "height": 6,
            "properties": {
                "view": "timeSeries",
                "stacked": false,
                "metrics": [
                    [ "AWS/EFS", "TotalIOBytes", "FileSystemId", "fs-EFSPLACEHOLDER", { "stat": "Sum" } ]
                ],
                "region": "${region}",
                "title": "Shared Storage I/O"
            }
        }
    ]
}