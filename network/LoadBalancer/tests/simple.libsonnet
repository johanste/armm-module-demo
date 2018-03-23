local LoadBalancer = import '../module.libsonnet';
local PublicIp = import 'network/PublicIpAddress/module.libsonnet';
local Vnet = import 'network/VirtualNetwork/module.libsonnet';

local vnet = Vnet {
    parameters: {
        name: 'thevnet',
        subnet: 'subnet'
    },
};

LoadBalancer {
    parameters:: {
        name: 'lb',
        sku: 'basic',
        ipConfiguration: 'first',
        publicIpAddress: false,
        virtualNetwork: vnet.resource,
        subnet: vnet.outputs.subnet.value[0],
    },
}
