keep-in-foreground
log-facility=-
log-queries
log-dhcp
no-hosts
dhcp-boot=http://192.168.209.134:8080/boot.ipxe
dhcp-range=192.168.209.2,192.168.209.100,30m
domain=example.com
dhcp-host=08:00:27:ab:10:01,192.168.209.3,master-1.example.com,infinite
dhcp-host=08:00:27:ab:10:02,192.168.209.4,master-2.example.com,infinite
dhcp-host=08:00:27:ab:10:03,192.168.209.5,master-3.example.com,infinite
address=/provisioner-1.example.com/192.168.209.134
address=/master-1.example.com/192.168.209.3
address=/master-2.example.com/192.168.209.4
address=/master-3.example.com/192.168.209.5