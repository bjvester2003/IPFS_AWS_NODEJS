sudo rm -rf ipfs-cluster*
sudo rm -rf .ipfs-cluster*
sudo rm -rf /usr/local/bin/ipfs-cluster*
sudo rm -rf /etc/systemd/system/ipfs-cluster*
sudo systemctl stop ipfs-cluster.service
sudo systemctl daemon-reload

