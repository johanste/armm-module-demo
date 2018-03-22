local armmodule = import 'core/module.libsonnet';

{
    ResourceTemplate:: armmodule.Resource {
        apiVersion: '2015-06-15',
        type: 'Microsoft.Network/publicIpAddresses',
        name: error "'name' is a required property",

        withAllocationMethod(allocationMethod)::
            if allocationMethod == null then
                self
            else
                self {
                    properties +: {
                        publicIPAllocationMethod: allocationMethod
                    },
                },
    },

    new(name, allocationMethod=null)::
        $.ResourceTemplate {
            name: name
        }.withAllocationMethod(allocationMethod)
}