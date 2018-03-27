local network = {
    LoadBalancer: import 'network/LoadBalancer/loadBalancer.libsonnet',
    PublicIpAddress: import 'network/PublicIpAddress/module.libsonnet',
    VirtualNetwork: import 'network/VirtualNetwork/module.libsonnet',
};
local compute = {
    VirtualMachineScaleSet: import 'compute/VirtualMachineScaleSet/virtualMachineScaleSet.libsonnet'
};

local core = import 'core/module.libsonnet';
local Module = import 'core/moduledef.libsonnet';

Module {

    parameterMetadata:: import 'parameters.libsonnet',

    imageFromAlias(aliasOrImage)::
        //
        // extract display name from the content/vm_aliases.json file. The content/vm_aliases file 
        // can be found at:
        // https://raw.githubusercontent.com/Azure/azure-rest-api-specs/master/arm-compute/quickstart-templates/aliases.json
        // 
        assert std.type(aliasOrImage) == 'object' || std.type(aliasOrImage) == 'string' : "imageFromAlias parameter expected 'object' or 'string' type parameter - got %s" % [ std.type(aliasOrImage) ];
        local vmImages = (import 'cli/content/vm_alisases.json').outputs.aliases.value;
        if std.type(aliasOrImage) == 'string' && std.objectHas(vmImages.Linux, aliasOrImage) then
            vmImages.Linux[aliasOrImage]
        else if std.type(aliasOrImage) == 'string' && std.objectHas(vmImages.Windows, aliasOrImage) then
            vmImages.Windows[aliasOrImage]
        else
            assert std.type(aliasOrImage) == 'object' : "Unable to find image '%s'" % [ aliasOrImage ];
            aliasOrImage,

    // Build a virtual network if one is not provided.
    virtualNetwork:: 
        // Optionally build a virtual network. 
        local shouldCreateVnet = $.arguments.virtualNetwork == '[new]';
        if shouldCreateVnet then 
            network.VirtualNetwork.new(
                    '%sVNET' % [ $.arguments.name ],
                    addressPrefix='10.0.0.0/16')
                .withSubnet('%sSubnet' % [ $.arguments.name ], addressPrefix='10.0.0.0/24')
        else
            $.arguments.virtualNetwork,

    // Build a public IP Address unless on is provided, or the parameters
    // indicate that one is not wanted...
    publicIpAddress::
        // Optionally build a public ip address
        local shouldCreatePublicIpAddress = $.arguments.publicIpAddress == null;
        if shouldCreatePublicIpAddress then 
            network.PublicIpAddress.new('%sLBPublicIP' % [ $.arguments.name ])
                .withAllocationMethod($.arguments.publicIpAllocationMethod)
        else 
            $.arguments.publicIpAddress,

    // Build a front facing load balancer unless on is provided, or the 
    // parameters indicate that one is not wanted...
    loadBalancer::
        local shouldCreateLoadBalancer = $.arguments.loadBalancer == null;
        if shouldCreateLoadBalancer then
            network.LoadBalancer.new('%sLB' % [ $.arguments.name ], sku= $.arguments.loadBalancerSku)
                .withIpConfiguration('loadBalancerFrontEnd')
                .withPublicIpAddress($.publicIpAddress)
                .withBackendAddressPool($.arguments.backendPoolName)
                .withNatRule($.arguments.authenticationType),

    // Build all resources created by the module...   
    virtualMachineScaleSet::
        compute.VirtualMachineScaleSet.new(
                            name= $.arguments.name,
                            osType = 'linux', // UNDONE - support windows again
                            imageReference = self.imageFromAlias($.arguments.imageReference),
                            overProvision = ! $.arguments.disableOverprovision,
                            capacity = $.arguments.instanceCount,
                            upgradePolicy = $.arguments.upgradePolicy,
                            skuName = $.arguments.vmSku
                            )
        .withAuth($.arguments.adminUserName, $.arguments.adminPassword, $.arguments.sshPublicKeys)
        .withIdentity($.arguments.identity)
        .behindLoadBalancer($.loadBalancer, $.virtualNetwork, $.arguments.subnet)
        .withDataDisks($.arguments.dataDiskSizes, $.arguments.dataDiskCaching),

    outputs: {
        virtualMachineScaleSet: {
            type: 'string',
            value: $.virtualMachineScaleSet.id
        },
        [if $.virtualNetwork != null then 'virtualNetwork']: {
            type: 'string',
            value: core.resourceId($.virtualNetwork)
        }
    }
}