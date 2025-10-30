global:
  scrape_interval: ${scrape_interval}
  evaluation_interval: 15s

alerting:a
  alertmanagers:
    - static_configs:
        - targets:
          # - alertmanager:9093

rule_files:
  # - "first_rules.yml"
  # - "second_rules.yml"

scrape_configs:
  - job_name: 'prometheus'
    static_configs:
      - targets: ['localhost:9090']

  - job_name: 'slurm_exporter'
    static_configs:
      - targets: ['${slurm_exporter_url}']
        labels:
          instance: 'slurm-head-node'

  - job_name: 'node_exporter'
    static_configs:
      - targets: ['${node_exporter_url}']
        labels:
          instance: 'slurm-head-node'

  # Add AWS EC2 Service Discovery for compute nodes
  - job_name: 'ec2_nodes'
    ec2_sd_configs:
      - region: ${region}
        port: 9100
        filters:
          - name: "tag:ClusterName"
            values: ["${cluster_name}"]
    relabel_configs:
      - source_labels: [__meta_ec2_tag_Name]
        target_label: instance
      - source_labels: [__meta_ec2_tag_NodeType]
        target_label: node_type