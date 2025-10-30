#!/bin/bash
# ParallelCluster information for ${cluster_name}
# Region: ${region}

# Configuration location
CONFIG_S3_URI="${config_s3_uri}"

# Cluster management commands
CREATE_CMD="pcluster create-cluster --cluster-name ${cluster_name} --cluster-configuration ${config_s3_uri} --region ${region}"
UPDATE_CMD="pcluster update-cluster --cluster-name ${cluster_name} --cluster-configuration ${config_s3_uri} --region ${region}"
DELETE_CMD="pcluster delete-cluster --cluster-name ${cluster_name} --region ${region}"
DESCRIBE_CMD="pcluster describe-cluster --cluster-name ${cluster_name} --region ${region}"
STATUS_CMD="pcluster list-clusters --region ${region} --query 'clusters[?clusterName==`${cluster_name}`]'"