local armmodule = import '../core/module.libsonnet';

armmodule.Resource {
 
    apiVersion: '2017-11-01',

    new(name, addressPrefixes=['10.0.0.0/16'], ddosProtection=null, enableVmProtection=null)::
        $ + {
            name: name,
            type: 'Microsoft.Network/virtualNetworks',
            properties: {
                [if ddosProtection != null then 'enableDdosProtection']: ddosProtection,
                [if enableVmProtection != null then 'enableVmProtection']: enableVmProtection,
                addressSpace: {
                    addressPrefixes: addressPrefixes
                },
                subnets: [],
            },
        },

    withDnsServers(dnsServers)::
        self {
            properties +: {
                dhcpOptions +: {
                    dnsServers +: dnsServers
                },
            },
        },

    withNetworkSecurityGroup(networkSecurityGroup)::
        local subnets = self.properties.subnets;

        self.withDependency(networkSecurityGroup) {
            properties +: {
                subnets: subnets[0:std.length(subnets) - 1] + 
                    [ subnets[std.length(subnets) - 1 ] {
                        properties +: {
                            networkSecurityGroup: {
                                id: networkSecurityGroup.id
                            }
                        }
                    }],
            },
        },        

    withSubnet(nameParam=null, addressPrefix, serviceEndpoints=null)::
        local name = if nameParam != null then nameParam else 'subnet%s' % [ std.length(self.properties.subnets) + 1 ];

        self {
            properties +: {
                subnets +: [
                    {
                        name: name,
                        properties: {
                            addressPrefix: addressPrefix,
                            [if serviceEndpoints != null then 'serviceEndpoints']: serviceEndpoints
                        }
                    },
                ],
            },
        },
}