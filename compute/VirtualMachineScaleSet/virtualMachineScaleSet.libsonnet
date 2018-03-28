local armmodule = import 'core/module.libsonnet';

local LinuxOsMixin = {

    _IdentityExtensionName:: 'ManagedIdentityExtensionForLinux',

    withAuth(userName, password=null, sshKeys=null)::

        self {
            properties +: {
                virtualMachineProfile +: {
                    osProfile +: {
                        adminUserName: userName,
                        [if password != null then 'adminPassword']: password,
                        [if sshKeys != null then'linuxConfiguration']: {
                            disablePasswordAuthentication: password == null,
                            ssh: {
                                publicKeys: [
                                    {
                                        keyData: sshKey,
                                        path: "/home/%s/.ssh/authorized_keys" % [ userName ],
                                    }
                                    for sshKey in sshKeys
                                ],
                            },
                        },
                    },
                },
            },
        },
    };

local WindowsOsMixin = {

    _IdentityExtensionName:: 'ManagedIdentityExtensionForWindows',

    withAuth(userName, password)::
        assert password != null : 'Windows Virtual Machine needs a (valid) password';
        self {
            properties +: {
                virtualMachineProfile +: {
                    osProfile +: {
                        adminUserName: userName,
                        adminPassword: password,
                    },
                },
            },
        },
    };

local ManagedPlatformImageOsDiskMixin = {
    fromImage(image, storageAccountType=null)::
        self {
            properties +: {
                virtualMachineProfile +: {
                    storageProfile +: {
                        imageReference: image,
                        osDisk: {
                            caching: 'ReadWrite',
                            managedDisk: {
                                storageAccountType: storageAccountType
                            },
                            createOption: 'FromImage',
                        },
                    },
                },
            },
        },
    };

local NativePlatformImageOsDiskMixin = {
    fromImage(image, osVhdUri, name, storageAccountType=null)::
        self {
            properties +: {
                virtualMachineProfile +: {
                    storageProfile +: {
                        osDisk: {
                            name: name,
                            imageReference: image,
                            caching: 'ReadWrite',
                            createOption: 'FromImage',
                            osType: self.osType,
                            image: image,
                            vhd: { uri: osVhdUri },
                        },
                    },
                },
            },
        },
    };


armmodule.Resource {
    apiVersion: '2017-12-01',
    type: 'Microsoft.Compute/virtualMachineScaleSets',

    new(name,
        osType,
        imageReference,
        skuName='standard_d1_v2',
        capacity=3,
        overProvision=null, 
        platformFaultDomainCount=null,
        singlePlacementGroup=null,
        upgradePolicy='manual',
        zoneBalance=null,
        virtualNetwork=null,
        subnet=null)::
        
        local osMixin = if osType == 'windows' then 
                            WindowsOsMixin 
                        else 
                            LinuxOsMixin;

        (self + osMixin + ManagedPlatformImageOsDiskMixin {
            name: name,
            sku: {
                capacity: capacity,
                name: skuName,
            },
            properties: {
                [if overProvision != null then 'overProvision']: overProvision,
                [if platformFaultDomainCount != null then 'platformFaultDomainCount']: platformFaultDomainCount,
                [if singlePlacementGroup != null then 'singlePlacementGroup']: singlePlacementGroup,
                upgradePolicy: {
                    mode: upgradePolicy
                },
                [if zoneBalance != null then 'zoneBalance']: zoneBalance,
                virtualMachineProfile: {
                    osProfile: {
                        computerNamePrefix: $.makeComputerNamePrefix(name)
                    },
                    storageProfile: {
                        dataDisks: [],
                    },
                },
            },
        }).onSubnet(virtualNetwork, subnet).fromImage(imageReference),

    makeComputerNamePrefix(name)::
        local computerNamePrefix = armmodule.stdex.strReplace(name, '_', '');
        computerNamePrefix + std.md5(computerNamePrefix)[0:5],

    withIdentity(nameOrId)::
        if nameOrId == null then 
            self
        else 
            assert nameOrId == '[system]' : "Only system assigned identity supported right now (expected '[system]', got '%s')" % [ nameOrId ];
            self {
                [if nameOrId == '[system]' then 'identity']: {
                    type: "SystemAssigned"
                },
                properties +: {
                    virtualMachineProfile +: {
                        extensionProfile +: {
                            extensions +: [
                                {
                                    name: $._IdentityExtensionName,
                                    properties +: {
                                        autoUpgradeMinorVersion: true,
                                        publisher: "Microsoft.ManagedIdentity",
                                        settings: {
                                            port: 50342
                                        },
                                        type: $._IdentityExtensionName,
                                        typeHandlerVersion: "1.0"
                                    }
                                }
                            ]
                        },
                    }
                },
            },

    withSku(name, tier='standard', capacity=3)::
        self {
            sku: {
                tier: tier,
                capacity: capacity,
                name: name,
            },

            // We can tell the user that they called the same function more than once
            // by replacing the method. TODO: Is this a good idea? 
            withSku(name, tier='standard', capacity=3)::
                error 'withSku called multiple times - a mistake has been made!',
                
        },

    
    behindLoadBalancer(loadBalancer, vnet, subnet=null, backendAddressPool=null, natPool=null)::
        if loadBalancer == null then 
            self 
        else 
            local lbName = armmodule.resourceName(loadBalancer);
            local vnetName = armmodule.resourceName(vnet);
            local backendAddressPoolName = armmodule.stdex.coalesce([backendAddressPool, loadBalancer.properties.backendAddressPools[0].name]);
            local natPoolName = if natPool != null then natPool else if std.length(loadBalancer.properties.inboundNatPools) > 0 then loadBalancer.properties.inboundNatPools[0].name else null;
            local subnetName = if subnet != null then subnet else vnet.properties.subnets[0].name;
            local ipConfigurationName = '%sIPConfig' % [ lbName ];

            self.withDependency(loadBalancer).withDependency(vnet) {
                properties +: {
                    virtualMachineProfile +: {
                        networkProfile +: {
                            local isPrimary = std.length(self.networkInterfaceConfigurations) == 1,

                            networkInterfaceConfigurations +: [
                                {
                                    name: '%sNic' % [ $.name ], 
                                    properties: {
                                        primary: isPrimary,
                                        ipConfigurations: [
                                            { 
                                                name: ipConfigurationName,
                                                properties: {
                                                    loadBalancerBackendAddressPools: [
                                                        {
                                                            id: "[concat(resourceId('Microsoft.Network/loadBalancers', '%s'), '/backendAddressPools/%s')]" % [ lbName, backendAddressPoolName ],
                                                        }
                                                    ],
                                                    subnet: {
                                                        id: "[concat(resourceId('Microsoft.Network/virtualNetworks', '%s'), '/subnets/%s')]" % [ vnetName, subnetName ],
                                                    },
                                                    [if natPoolName != null then 'loadBalancerInboundNatPools']: [
                                                        {
                                                        id: "[concat(resourceId('Microsoft.Network/loadBalancers', '%s'), '/inboundNatPools/%s')]" % [ lbName, natPoolName ],
                                                        },
                                                    ],
                                                },
                                            }
                                        ]
                                    }
                                }
                            ]
                        },
                    },
                },
            },

    withDataDisks(dataDisks, caching=null, storageAccountType=null)::
        assert std.type(dataDisks) == 'array' || std.type(dataDisks) == 'number' : "Expected type of dataDisks to be one of ('array', 'number), got '%s'" % [ std.type(dataDisks)];
        local diskArray = if std.type(dataDisks) == 'number' then [ dataDisks ] else dataDisks;
        local lun = std.length($.properties.virtualMachineProfile.storageProfile.dataDisks) + 1;
        local numDisksToAdd = std.length(diskArray);
        if numDisksToAdd == 0 then 
            self
        else
            self {
                properties +: {
                    virtualMachineProfile +: {
                        storageProfile +: {
                            dataDisks +: [
                                {
                                    lun: lun + index - 1,
                                    createOption: 'empty',
                                    caching: caching,
                                    diskSizeGB: diskArray[index],
                                    managedDisk: {
                                        storageAccountType: null
                                    },
                                },
                                for index in std.range(0, numDisksToAdd - 1)
                            ],
                        },      
                    },
                },
            },

    
    _onSubnetById(subnet)::
        local parts = std.split(subnet, '/');
        local vnetName = parts[8];
        local subnetName = parts[10];

        self._onSubnetCore(vnetName, subnetName),

    _onSubnetCore(vnetName, subnetName)::
        self  {
                properties +: {
                    virtualMachineProfile +: {
                        networkProfile +: {
                            local isPrimary = std.length(self.networkInterfaceConfigurations) == 1,

                            networkInterfaceConfigurations +: [
                                {
                                    name: '%s' % [vnetName], 
                                    properties: {
                                        primary: isPrimary,
                                        ipConfigurations: [
                                            { 
                                                name: '%s-%s' % [vnetName, subnetName], 
                                                properties: {
                                                    subnet: {
                                                        id: "[concat(resourceId('Microsoft.Network/virtualNetworks', '%s'), '/subnets/%s')]" % [ vnetName, subnetName ],
                                                    },
                                                },
                                            }
                                        ]
                                    }
                                }
                            ]
                        },
                    },
                },
            },

    onSubnet(vnet, subnet=null)::
        if vnet == null && subnet == null then
            self
        else if vnet == null && armmodule.isValidResourceId(subnet) then
            self._onSubnetById(subnet)
        else if armmodule.isResource(vnet) then
            self.withDependency(vnet)._onSubnetCore(vnet.name, subnet)
        else 
            self,
}