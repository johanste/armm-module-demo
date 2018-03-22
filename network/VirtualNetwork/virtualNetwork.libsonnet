local core = import 'core/module.libsonnet';
local stdex = core.stdex;

core.Resource {
 
    apiVersion: '2017-11-01',
    type: 'Microsoft.Network/virtualNetworks',
    
    new(name, subnet=null, subnetAddressPrefix=null, ddosProtection=null, enableVmProtection=null, addressPrefix=null)::
        (self + {
            name: name,
            type: 'Microsoft.Network/virtualNetworks',
            properties: {
                [if ddosProtection != null then 'enableDdosProtection']: ddosProtection,
                [if enableVmProtection != null then 'enableVmProtection']: enableVmProtection,
                subnets: [],
            },
        }).withAddressPrefix(addressPrefix),

    withAddressPrefix(addressPrefix)::
        if addressPrefix == null then 
            self
        else
            assert stdex.isString(addressPrefix) : "Invalid type for parameter addressPrefix - expected 'string', got '%s'" % [ std.type(addressPrefix) ];
            self {
                properties +: {
                    addressSpace: {
                        addressPrefixes +: [ addressPrefix ],
                    },
                },
            },

    withDnsServers(dnsServers)::
        assert stdex.isArray(dnsServers) : "Invalid type for parameter dnsServers - expected 'array', got '%s'" % [ std.type(dnsServers)];

        self {
            properties +: {
                dhcpOptions +: {
                    dnsServers +: dnsServers
                },
            },
        },

    withNetworkSecurityGroup(networkSecurityGroup)::
        if networkSecurityGroup == null then
            self
        else
            local subnets = self.properties.subnets;
            
            self.withDependency(networkSecurityGroup) {
                properties +: {
                    subnets: subnets[0:std.length(subnets) - 1] + 
                        [ subnets[std.length(subnets) - 1 ] {
                            properties +: {
                                networkSecurityGroup: {
                                    id: core.resourceId(networkSecurityGroup)
                                }
                            }
                        }],
                },
            },        

    withSubnet(name =null, addressPrefix, serviceEndpoints=null)::
        local subnetName = if name != null then name else 'subnet%s' % [ std.length(self.properties.subnets) + 1 ];

        self {
            properties +: {
                subnets +: [
                    {
                        name: subnetName,
                        properties: {
                            addressPrefix: addressPrefix,
                            [if serviceEndpoints != null then 'serviceEndpoints']: serviceEndpoints
                        }
                    },
                ],
            },
        },
}