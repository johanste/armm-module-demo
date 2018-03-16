local armmodule = import '../core/module.libsonnet';

armmodule.Resource {

    type: 'Microsoft.Network/loadBalancers',
    apiVersion: '2017-11-01',

    new(name)::
        self {
            name: name
        },

    withIpConfiguration(name)::
        self {
            properties +: {
                frontendIpConfigurations +: [
                    {
                        name: name
                    }
                ],
            },
        },

    withPublicIpAddress(publicIpAddress)::
        if publicIpAddress == null then self else
        local name = armmodule.resourceName(publicIpAddress);
        local existingIpConfigurations = self.properties.frontendIpConfigurations;
        self.withDependency(publicIpAddress) {
            properties +: {
                frontendIpConfigurations: [
                    ipconf 
                    for ipconf in existingIpConfigurations[0:std.length(existingIpConfigurations) - 1]]
                    + [
                        existingIpConfigurations[std.length(existingIpConfigurations) - 1] {
                            properties +: {
                                publicIpAddress +: {
                                    id: "[resourceId('Microsoft.Network/publicIpAddresses', '%s')]" % [ name ],
                                },
                            }
                        }
                    ]
                },
            },

    onSubnet(vnet, subnet=null, ipConfigurationName=null)::
        local vnetName = armmodule.resourceName(vnet);
        local subnetName = if subnet != null then subnet else vnet.properties.subnets[0].name;
        local existingIpConfigurations = self.properties.frontendIpConfigurations;
        self.withDependency(vnet) {
            properties +: {
                frontendIpConfigurations: [
                    ipconf 
                    for ipconf in existingIpConfigurations[0:std.length(existingIpConfigurations) - 1]]
                    + [
                        existingIpConfigurations[0:std.length(existingIpConfigurations) - 1] {
                            properties +: {
                                subnet: {
                                    id: "[concat(resourceId('Microsoft.Network/virtualNetworks', '%s'), '/subnets/%s')]" % [ vnetName, subnetName ],
                                },                                
                            }
                        },
                    ],
                },
            },


    withBackendAddressPool(name)::
        self {
            properties +: {
                backendAddressPools +: [
                    {
                        name: if name != null then name else '%sBEPool' % [ $.name ],
                    }
                ],
            },
        },
    
    withNatRule(ruleOrName)::
        local name = "%sNatPool" % [ $.name ];
        local lastFrontendIpConfiguration = armmodule.stdex.last($.properties.frontendIpConfigurations);
        local frontendIpConfigurationId = "[concat(resourceId('Microsoft.Network/loadBalancers', '%s'), '/frontendIPConfigurations/', '%s')]" % [ $.name, lastFrontendIpConfiguration.name ];

        local builtInRules = {
            ssh: {
                backendPort: 22,
                frontendPortRangeEnd: "50119",
                frontendPortRangeStart: "50000",
                protocol: "tcp"
            }     
        };

        local settings = {
            frontendIPConfiguration: {
                id: frontendIpConfigurationId,
            }
        } + if std.type(ruleOrName) == 'string' then
            builtInRules[ruleOrName]
        else
            ruleOrName;
        
        self + {
            properties +: {
                inboundNatPools +: 
                    [
                        {
                            name: name,
                            properties: settings
                        }
                    ]
                }
            },
}