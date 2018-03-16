local network = import 'network/module.libsonnet';
local compute = import 'compute/module.libsonnet';

{
    // Required parameters are broken out to a separate set to 
    // allow the use ot error constructs. The use of std.mergePatch
    // to allow for partial overrides of complete parameters caused the whole
    // parameters set to be materialized, which prematurely triggered any 
    // error clauses within the parameters.
    local requiredParameters = {
        name: error "'name' is a required parameter",
        imageReference: error "'imageReference' is a required parameter",
        adminUserName: error "'adminUserName' is a required parameter", // CLI is using current user's user name by default...
        location: error "'location' is a required parameter", // CLI is using resource group's location by default. We could consider doing so as well...        
    },
 
    local parameters = requiredParameters + std.mergePatch({
        disableOverprovision: false, 
        instanceCount: 2,
        upgradePolicy: 'manual', 
        adminPassword: null,
        authenticationType: if self.osType == 'Windows' then 'rdp' else 'ssh',
        vmSku: 'Standard_D1_v2', 
        sshPublicKeys: [],
        loadBalancer: null, // { sku: null },
        virtualNetwork: null,
        applicationGateway: null, // { subnetPrefix: null, sku: 'Standard_Large', capacity: 10 }, // ISSUE: How to provide defaults for optional parameters
        backendPoolName: null,
        natPoolName: null,
        backendPort: null,
        publicIpAllocationMethod: 'dynamic',
        dataDisks: [], 
        osType: null, // error "'osType' is a required parameters",
        subnet: null,
        customData: null,
        licenseType: null,
        singlePlacementGroup: self.instanceCount <= 100,
        publicIpAddress: null,
        publicIpAddressDnsName: null,
        publicIpAddressPerVm: false,
        zones: [], 
        dataDiskSizes: [],
        dataDiskCaching: null,
        identity: null
    }, $.parameters),

    imageFromAlias(aliasOrImage)::
        //
        // extract display name from the content/vm_aliases.json file. The content/vm_aliases file 
        // can be found at:
        // https://raw.githubusercontent.com/Azure/azure-rest-api-specs/master/arm-compute/quickstart-templates/aliases.json
        // 
        assert std.type(aliasOrImage) == 'object' || std.type(aliasOrImage) == 'string' : "imageFromAlias parameter expected 'object' or 'string' type parameter - got %s" % [ std.type(aliasOrImage) ];
        local vmImages = (import 'cli/content/vm_alisases.json').outputs.aliases.value;
        if std.type(parameters.imageReference) == 'string' && std.objectHas(vmImages.Linux, aliasOrImage) then
            vmImages.Linux[aliasOrImage]
        else if std.type(parameters.imageReference) == 'string' && std.objectHas(vmImages.Windows, aliasOrImage) then
            vmImages.Windows[aliasOrImage]
        else
            assert std.type(aliasOrImage) == 'object' : "Unable to find image '%s'" % [ aliasOrImage ];
            aliasOrImage,



    buildVirtualNetwork(parameters)::
        // Optionally build a virtual network. 
        local shouldCreateVnet = parameters.virtualNetwork == null;
        if shouldCreateVnet then 
            network.VirtualNetwork.new('%sVNET' % [ parameters.name ])
                .withSubnet('%sSubnet' % [ parameters.name ], addressPrefix='10.0.0.0/24')
        else
            null,

    buildPublicIpAddress(parameters)::
        // Optionally build a public ip address
        local shouldCreatePublicIpAddress = parameters.publicIpAddress == null;
        if shouldCreatePublicIpAddress then 
            network.PublicIpAddress.new('%sLBPublicIP' % [ parameters.name ])
                .withAllocationMethod(parameters.publicIpAllocationMethod)
        else 
            null,

    buildLoadBalancer(parameters, virtualNetwork, publicIpAddress)::
        local shouldCreateLoadBalancer = parameters.loadBalancer == null;
        if shouldCreateLoadBalancer then
            network.LoadBalancer.new('%sLB' % [ parameters.name ])
                .withIpConfiguration('loadBalancerFrontEnd')
                .withPublicIpAddress(publicIpAddress)
                .withBackendAddressPool(parameters.backendPoolName)
                .withNatRule(parameters.authenticationType)
        else
            null,

    // Build all resources created by the module...   
    local publicIpAddress = $.buildPublicIpAddress(parameters),
    local virtualNetwork = $.buildVirtualNetwork(parameters),
    local loadBalancer = $.buildLoadBalancer(parameters, virtualNetwork, publicIpAddress),
    local vmss = compute.VirtualMachineScaleSet.new(
                            name=parameters.name, 
                            overProvision=!parameters.disableOverprovision,
                            capacity=parameters.instanceCount,
                            upgradePolicy=parameters.upgradePolicy,
                            skuName=parameters.vmSku)
        .fromImage($.imageFromAlias(parameters.imageReference))
        .withAuth(parameters.adminUserName, parameters.adminPassword, parameters.sshPublicKeys)
        .withIdentity(parameters.identity)
        .behindLoadBalancer(loadBalancer, virtualNetwork)
        .withDataDisks(parameters.dataDiskSizes, parameters.dataDiskCaching),

    resources: [
        virtualNetwork,
        publicIpAddress,
        loadBalancer,
        vmss,
    ],
    outputs: {
        virtualMachineScaleSet: {
            type: 'string',
            value: vmss.id
        },
        [if virtualNetwork != null then 'virtualNetwork']: {
            type: 'string',
            value: virtualNetwork.id
        },
    },

// Boilerplate code - everything below this line is either for testing or should be 
// part of the consumer of the module... 

    asTemplate():: {
        "$schema": "https://schema.management.azure.com/schemas/2015-01-01/deploymentTemplate.json#",
        contentVersion: "1.0.0.0",
        parameters: {},
        resources: [
            resource 
            for resource in $.resources if resource != null
        ],
        outputs: $.outputs
    },
 } {
    parameters: {
        name: 'simples_ubuntu',
        adminUserName: 'johanste',
        // adminPassword: '$ecreT$3612',
        imageReference: 'UbuntuLTS',
        sshPublicKeys: [ "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQCXwbIlLS57sL6S7LKplMtT1UJLZXkKNaWmLum1r+MMqncIFVdWbqsjSB1hHYxjFP5VxR/cK5Kq1jmAq57S6JeOlC1JC86Ka+S5EHrboZo1t/zNbAFRcQXxdLgqSB3767Q24W48fhhKngCKuVJ8bvvwTC0WskgY2ePlwlG1Erfzc0twnVkHOYISM0zFGEdKcjqYR1PaYXmaPzaZsFMQAv3ymUd1hM4mj3ZfHm34M4rxjlUaTrhxVdN5z2TBHFjJa6YLulmex9g4MRaaHQU9xDL5BXpWHRmyepQ+P1KBjOd9VUam789+BCYaQ5ZC/9XaPDVvwOUkQaF7PinNgI98Nx+T JohanSte@Johans-MacBook-Pro.local\n" ],
        dataDiskSizes: 1023,
        identity: '[system]',
    }, 
}.asTemplate() 
