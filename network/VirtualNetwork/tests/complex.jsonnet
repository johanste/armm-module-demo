local VirtualNetwork = import '../module.libsonnet';
local NetworkSecurityGroup = import 'network/NetworkSecurityGroup/module.libsonnet';
local PublicIpAddress = import 'network/PublicIpAddress/module.libsonnet';

local frontendNsg = NetworkSecurityGroup.new('frontendNsg')
    .withRule('ssh');

local backendNsg = NetworkSecurityGroup.new('backendNsg')
    .withRule('ssh', access='deny', priority=756)
;

local publicIp = PublicIpAddress{
        parameters: {
            name: 'pip'
    }
};


local vnet = VirtualNetwork.new('davnet')
    .withDnsServers(['10.0.0.1'])
    .withSubnet('frontend', addressPrefix='10.0.0.0/24')
    .withNetworkSecurityGroup(frontendNsg)
    .withSubnet('backend', addressPrefix='10.0.1.0/24')
    .withNetworkSecurityGroup(backendNsg);

{
    resources: [  
        frontendNsg,
        backendNsg, 
        vnet
    ] + publicIp.resources
} 
