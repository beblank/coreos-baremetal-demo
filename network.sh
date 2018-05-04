set -x

internal_ip="192.168.209.137"

interfaces=$(ifconfig -a | perl scripts/parse_ifconfig.pl "$internal_ip")
nat_interface=$(echo "$interfaces" | cut -d, -f 1)
internal_interface=$(echo "$interfaces" | cut -d, -f 2)