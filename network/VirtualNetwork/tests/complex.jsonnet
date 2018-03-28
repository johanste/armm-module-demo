local Module = import 'core/moduledef.libsonnet';

local VirtualNetwork = import '../virtualNetwork.libsonnet';
local NetworkSecurityGroup = import 'network/NetworkSecurityGroup/module.libsonnet';
local PublicIpAddress = import 'network/PublicIpAddress/module.libsonnet';

// Test module definition that builds up a vnet with two subnets and 
// respective NSGs
Module {

    parameterMetadata: {
        name: {
            type: 'string'
        },
        frontendNsg: {
            type: 'object',
            defaultValue: {
                name: '%sfrontendNsg' % [ $.arguments.name ],
                rule: 'ssh'
            },
        },
        backendNsg: {
            type: 'object',
            defaultValue: {
                name: '%sbackendNsg' % [ $.arguments.name ],
            },            
        },
    },

    frontendNsg:: NetworkSecurityGroup {
        parameters: $.arguments.frontendNsg
    },

    backendNsg:: NetworkSecurityGroup {
        parameters: $.arguments.backendNsg
    },

    publicIp:: PublicIpAddress{
            parameters: {
                name: 'pip'
        } 
    },

    vnet: VirtualNetwork.new('davnet')
        .withDnsServers(['10.0.0.1'])
        .withSubnet('frontend', addressPrefix='10.0.0.0/24')
        .withNetworkSecurityGroup($.frontendNsg)
        .withSubnet('backend', addressPrefix='10.0.1.0/24')
        .withNetworkSecurityGroup($.backendNsg),
} 

// Parameters passed in to module
{
    parameters: {
        name: 'testingdav',
        backendNsg: {
            name: '%soverridden' % [ $.arguments.name ],
            rule: 'ssh'
        },
    }
}