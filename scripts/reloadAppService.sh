sudo systemctl daemon-reexec
sudo systemctl daemon-reload
sudo systemctl enable ipfs-node-manager.service
sudo systemctl start ipfs-node-manager.service
sudo systemctl status ipfs-node-manager.service
