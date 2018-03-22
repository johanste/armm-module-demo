local LoadBalancer = import '../module.libsonnet';
local PublicIp = import 'network/PublicIpAddress/module.libsonnet';

LoadBalancer.new(
    name='testlb'
).withIpConfiguration('default')
.onSubnet((import 'network/VirtualNetwork/module.libsonnet').new('VNET', addressPrefix='10.0.0.0/16').withSubnet('SUBNET', addressPrefix='10.0.0.0/24'))
.withPublicIpAddress(PublicIp.new(name='pip'))
.withIpConfiguration('backend')