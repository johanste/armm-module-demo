local Module = import 'core/moduledef.libsonnet';
local NetworkSecurityGroup = import 'network/NetworkSecurityGroup/module.libsonnet';

Module {
    parameterMetadata:: {
        name: {
            type: 'string'
        },
        addressPrefix: {
            type: 'string',
            defaultValue: '10.0.0.0/16'
        },
        subnet: {
            type: 'string',
            defaultValue: 'default'
        },
        subnetAddressPrefix: {
            type: 'string',
            defaultValue: '10.0.0.0/24',
        },
        networkSecurityGroup: {
            type: [ 'string', 'object' ],
            defaultValue: null
        },
    },

    //
    // The instance member contains the resource as created "by default" from the 
    // given set of parameters.
    // 
    virtualNetwork:: $.new(
                    name = $.arguments.name,
                    addressPrefix = $.arguments.addressPrefix
                ).withSubnet(
                    name = $.arguments.subnet,
                    addressPrefix = $.arguments.subnetAddressPrefix
                ).withNetworkSecurityGroup($.arguments.networkSecurityGroup),

    new(name, addressPrefix)::
        (import 'virtualNetwork.libsonnet').new(
            name=name,
            addressPrefix=addressPrefix
        ),

    withAccess(accessType)::
        self {
            networkSecurityGroup:: NetworkSecurityGroup {
                parameters: {
                    name: $.arguments.name + 'NSG',
                    rule: accessType
                },
            },
        },

    outputs: {
        
        id: {
            type: 'string',
            value: $.virtualNetwork.id
        },
        subnet: {
            type: 'array',
            value: [subnet.name for subnet in $.virtualNetwork.properties.subnets],
        },
    }
} 

{
    parameters:: {
        name: 'thevnet'
    },
}