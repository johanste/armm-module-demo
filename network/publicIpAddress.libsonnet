local armmodule = import '../core/module.libsonnet';

armmodule.Resource {
    
    apiVersion: '2015-06-15',
    type: 'Microsoft.Network/publicIpAddresses',

    new(name)::
        self {
            name: name
        },

    withAllocationMethod(allocationMethod):: 
        self {
            properties +: {
                publicIpAllocationMethod: allocationMethod
            },
        },
}