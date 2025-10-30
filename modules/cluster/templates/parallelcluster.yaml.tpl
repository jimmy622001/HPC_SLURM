# AWS ParallelCluster Configuration
Region: ${region}

Image:
  Os: alinux2

HeadNode:
  InstanceType: ${head_node_instance_type}
  Networking:
    SubnetId: ${split(",", subnet_ids)[0]}
    SecurityGroups:
      - ${head_node_sg_id}
  Ssh:
    KeyName: ${ssh_key_name}
  LocalStorage:
    RootVolume:
      Size: 50
      VolumeType: gp3
      Iops: 3000
    EphemeralVolume:
      MountDir: /scratch
  CustomActions:
    OnNodeStart:
      Script: s3://${bucket_name}/scripts/head_node_setup.sh
  Iam:
    AdditionalIamPolicies:
      - Policy: arn:aws:iam::aws:policy/AmazonS3FullAccess
      - Policy: arn:aws:iam::aws:policy/CloudWatchAgentServerPolicy

Scheduling:
  Scheduler: slurm
  SlurmQueues:
    - Name: compute
      CapacityType: ${enable_spot_instances ? "SPOT" : "ONDEMAND"}
      ComputeResources:
        - Name: compute-nodes
          MinCount: ${min_compute_nodes}
          MaxCount: ${max_compute_nodes}
          InstanceTypes: 
%{ for instance_type in split(",", compute_instance_types) ~}
            - ${instance_type}
%{ endfor ~}
      Networking:
        SubnetIds:
%{ for subnet_id in split(",", subnet_ids) ~}
          - ${subnet_id}
%{ endfor ~}
        PlacementGroup:
          Enabled: ${placement_group ? "true" : "false"}
        SecurityGroups:
          - ${compute_node_sg_id}
      ComputeSettings:
        LocalStorage:
          RootVolume:
            Size: 35
            VolumeType: gp3
          EphemeralVolume:
            MountDir: /scratch
      CustomActions:
        OnNodeStart:
          Script: s3://${bucket_name}/scripts/compute_node_setup.sh

SharedStorage:
%{ if shared_storage_type == "efs" ~}
  - MountDir: /shared
    Name: efs
    StorageType: Efs
    EfsSettings:
      FileSystemId: ${shared_storage_id}
      EncryptionInTransit: true
%{ endif ~}
%{ if shared_storage_type == "fsx_lustre" ~}
  - MountDir: /lustre
    Name: fsx-lustre
    StorageType: FsxLustre
    FsxLustreSettings:
      FileSystemId: ${shared_storage_id}
%{ endif ~}

Monitoring:
  Logs:
    CloudWatch:
      Enabled: true
      RetentionInDays: 14
  Dashboards:
    CloudWatch:
      Enabled: true