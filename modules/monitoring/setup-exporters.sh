#!/bin/bash
# Setup script for Prometheus exporters on SLURM cluster nodes
set -e

NODE_EXPORTER_VERSION="1.5.0"
SLURM_EXPORTER_VERSION="0.19"

# Function to install Node Exporter
install_node_exporter() {
    echo "Installing Prometheus Node Exporter ${NODE_EXPORTER_VERSION}..."
    
    # Download and extract node exporter
    cd /tmp
    wget https://github.com/prometheus/node_exporter/releases/download/v${NODE_EXPORTER_VERSION}/node_exporter-${NODE_EXPORTER_VERSION}.linux-amd64.tar.gz
    tar xvfz node_exporter-${NODE_EXPORTER_VERSION}.linux-amd64.tar.gz
    
    # Install node exporter binary
    sudo cp node_exporter-${NODE_EXPORTER_VERSION}.linux-amd64/node_exporter /usr/local/bin/
    
    # Create node exporter user
    sudo useradd --no-create-home --shell /bin/false node_exporter || true
    
    # Create systemd service
    sudo tee /etc/systemd/system/node_exporter.service > /dev/null <<EOF
[Unit]
Description=Node Exporter
Wants=network-online.target
After=network-online.target

[Service]
User=node_exporter
Group=node_exporter
Type=simple
ExecStart=/usr/local/bin/node_exporter --collector.filesystem.ignored-mount-points="^/(dev|proc|sys|var/lib/docker/.+|var/lib/kubelet/pods/.+)($|/)" --collector.netclass --collector.netdev --collector.meminfo --collector.cpu

[Install]
WantedBy=multi-user.target
EOF

    # Enable and start service
    sudo systemctl daemon-reload
    sudo systemctl enable node_exporter
    sudo systemctl start node_exporter
    
    echo "Node Exporter installation completed"
}

# Function to install SLURM Exporter (only on head node)
install_slurm_exporter() {
    # Check if SLURM is installed
    if ! command -v sinfo &> /dev/null; then
        echo "SLURM not found, skipping SLURM exporter installation"
        return
    fi
    
    echo "Installing SLURM Exporter ${SLURM_EXPORTER_VERSION}..."
    
    # Install Go (required to build SLURM exporter)
    sudo yum install -y golang git
    
    # Clone and build SLURM exporter
    cd /tmp
    git clone https://github.com/vpenso/prometheus-slurm-exporter.git
    cd prometheus-slurm-exporter
    git checkout v${SLURM_EXPORTER_VERSION}
    make build
    
    # Install the binary
    sudo cp prometheus-slurm-exporter /usr/local/bin/
    
    # Create systemd service
    sudo tee /etc/systemd/system/slurm_exporter.service > /dev/null <<EOF
[Unit]
Description=SLURM Metrics Exporter
Wants=network-online.target
After=network-online.target

[Service]
Type=simple
ExecStart=/usr/local/bin/prometheus-slurm-exporter -listen-address=:9100
Restart=always
RestartSec=10

[Install]
WantedBy=multi-user.target
EOF

    # Enable and start service
    sudo systemctl daemon-reload
    sudo systemctl enable slurm_exporter
    sudo systemctl start slurm_exporter
    
    echo "SLURM Exporter installation completed"
}

# Main installation
echo "Setting up Prometheus exporters..."

# Install Node Exporter on all nodes
install_node_exporter

# Install SLURM Exporter only on head node
if [[ -f /etc/parallelcluster/is_head_node ]]; then
    install_slurm_exporter
fi

echo "Exporter setup completed successfully"