keep-in-foreground
log-facility=-
log-queries
log-dhcp
no-hosts

dhcp-range=192.168.209.100,192.168.209.200,30m

enable-tftp
tftp-root=/var/lib/tftpboot

dhcp-userclass=set:ipxe,iPXE
dhcp-boot=tag:ipxe,http://192.168.209.134:8080/boot.ipxe


domain=example.com
dhcp-host=08:00:27:ab:10:01,192.168.209.138,master-1.example.com,infinite
dhcp-host=08:00:27:ab:10:02,192.168.209.139,master-2.example.com,infinite
dhcp-host=08:00:27:ab:10:03,192.168.209.140,master-3.example.com,infinite
address=/provisioner-1.example.com/192.168.209.134
address=/master-1.example.com/192.168.209.138
address=/master-2.example.com/192.168.209.139
address=/master-3.example.com/192.168.209.140