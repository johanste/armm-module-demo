local stdex = (import 'core/module.libsonnet').stdex;
{
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

    local parameters = stdex.mergeParameters($.parameters, $.parameterMetadata),

    //
    // The instance member contains the resource as created "by default" from the 
    // given set of parameters.
    // 
    resource:: $.new(
                    name = parameters.name,
                    addressPrefix = parameters.addressPrefix
                ).withSubnet(
                    name = parameters.subnet,
                    addressPrefix = parameters.subnetAddressPrefix
                ).withNetworkSecurityGroup(parameters.networkSecurityGroup),

    new(name, addressPrefix)::
        (import 'virtualNetwork.libsonnet').new(
            name=name,
            addressPrefix=addressPrefix
        ),

    resources: [
        $.resource
    ],
    outputs: {
        id: {
            type: 'string',
            value: $.resource.id
        }
    }
}