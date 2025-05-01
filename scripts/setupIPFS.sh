#!/bin/sh

setupService="$1"

ipfsNodeService=$(cat << 'EOF'
[Unit]
Description=IPFS Node
After=network.target

[Service]
ExecStart=/usr/local/bin/ipfs daemon
ExecReload=/usr/local/bin/ipfs daemon
Restart=on-failure
User=ubuntu
Group=ubuntu
[Install]
WantedBy=default.target
EOF
)

ipfsClusterService=$(cat << 'EOF'
[Unit]
Description=IPFS Cluster Service
After=network.target

[Service]
ExecStart=/usr/local/bin/ipfs-cluster-service daemon -- bootstrap /ip4/172.31.4.32/tcp/9096/p2p/12D3K>
ExecReload=/usr/local/bin/ipfs-cluster-service daemon-- bootstrap /ip4/172.31.4.32/tcp/9096/p2p/12D3K>
Restart=on-failure
User=ubuntu
Group=ubuntu
[Install]
WantedBy=default.target
EOF
)

RED="\e[91;37m"
ENDCOLOR="\e[0m"

if [ "$setupService" = "node" ];then
   
    echo -e "\n${RED}Downloading...${ENDCOLOR}\n"
    wget https://dist.ipfs.tech/kubo/v0.34.1/kubo_v0.34.1_linux-amd64.tar.gz
    tar -xvf kubo_v0.34.1_linux-amd64.tar.gz
    sudo mv kubo/ipfs /usr/local/bin/

    echo -e "\n${RED}Initializing...${ENDCOLOR}\n"
    sudo -u ubuntu /usr/local/bin/ipfs init
    sudo echo "$ipfsNodeService" >> /etc/systemd/system/ipfs-node.service

    echo -e "\n${RED}Starting...${ENDCOLOR}\n"
    sudo systemctl daemon-reload
    sudo systemctl enable ipfs-node.service
    sudo systemctl start ipfs-node.service

elif [ "$setupService" = "cluster" ]; then

    echo -e "\n${RED}Downloading...${ENDCOLOR}\n"
    wget https://dist.ipfs.tech/ipfs-cluster-ctl/v1.1.2/ipfs-cluster-ctl_v1.1.2_linux-amd64.tar.gz
    tar -xvf ipfs-cluster-ctl_v1.1.2_linux-amd64.tar.gz
    sudo mv ipfs-cluster-ctl/ipfs-cluster-ctl /usr/local/bin/

    wget https://dist.ipfs.tech/ipfs-cluster-service/v1.1.2/ipfs-cluster-service_v1.1.2_linux-amd64.tar.gz
    tar -xvf ipfs-cluster-service_v1.1.2_linux-amd64.tar.gz
    sudo mv ipfs-cluster-service/ipfs-cluster-service /usr/local/bin/

    echo -e "\n${RED}Initializing...${ENDCOLOR}\n"
    sudo -u ubuntu /usr/local/bin/ipfs-cluster-service init
    echo "$ipfsClusterService" | sudo tee /etc/systemd/system/ipfs-cluster.service > /dev/null

    #echo -e "\n${RED}Starting...${ENDCOLOR}\n"
    #sudo systemctl daemon-reload
    #sudo systemctl enable ipfs-cluster.service
    #sudo systemctl start ipfs-cluster.service

elif [ "$setupService" = "secret" ]; then
    cat /home/ubuntu/.ipfs-cluster/service.json | grep secret
fi
