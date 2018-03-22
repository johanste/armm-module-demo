local Network = import '../../module.libsonnet';

local publicIp = Network.PublicIpAddress.new('pippe');

local vnet = Network.VirtualNetwork.new('vnet')
    .withSubnet('default', '10.0.0.0/24');

local lb = Network.LoadBalancer.new('lb')
    .withIpConfiguration('front')
    .withPublicIpAddress(publicIp)
    .withBackendAddressPool('backend')
;

{ 
    asTemplate():: {
        "$schema": "https://schema.management.azure.com/schemas/2015-01-01/deploymentTemplate.json#",
        contentVersion: "1.0.0.0",
        parameters: {},
        resources: $.resourcesToCreate
    },
 
    resourcesToCreate: [
        publicIp,
        vnet,
        lb,
    ] 
}.asTemplate()
