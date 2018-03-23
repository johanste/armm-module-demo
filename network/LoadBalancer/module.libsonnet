local Module = import 'core/moduledef.libsonnet';
local LoadBalancer = import 'loadBalancer.libsonnet';

Module {

    parameterMetadata:: {
        name: {
            type: 'string'
        },
        sku: {
            type: 'string',
            defaultValue: null
        },
        publicIpAddress: {
            type: [ 'string', 'boolean', 'object' ],
            defaultValue: null,
        },
        ipConfiguration: {
            type: 'string',
            defaultValue: 'ipconfig'
        },
        virtualNetwork: {
            type: 'object',
            defaultValue: null,
        },
        subnet: {
            type: 'string',
            defaultValue: null,
        },
    },
    resource:: 
        local raw = LoadBalancer.new(
            name = $.arguments.name,
            sku = $.arguments.sku
        ).withIpConfiguration($.arguments.ipConfiguration);
        local addIp = if $.arguments.publicIpAddress != false then raw.withPublicIpAddress($.arguments.publicIpAddress) else raw;
        addIp.onSubnet($.arguments.virtualNetwork, $.arguments.subnet),


    resources: [
        $.resource
    ],
    outputs: {
        id: $.resource.id
    },
}