class myfirewall::params {

$firewall_status  = 'running'
$firewall_service = 'firewalld'
$myrichrule  = 'rule family="ipv4" source address="192.168.0.0/24" service name="http" accept'
$myrichrule1 = 'rule family="ipv4" source address="192.168.10.0/24" service name="http" accept'
}
