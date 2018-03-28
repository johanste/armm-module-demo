local Module = import 'core/moduledef.libsonnet';

// Resolution of modules can be made simpler (or at least different) by having a custom resolver
// or by having a top-level ARM (or platform) module from which one can access individual modules
// by "dotting" into the name (i.e. local arm = import 'arm.libsonnet'; arm.compute.VirtualNetwork { 
//  bla bla})
//
// For expedience, just use the standard import to allow for use of vanilla 
// import statements. 
local VirtualNetwork = import 'network/VirtualNetwork/module.libsonnet';
local NetworkSecurityGroup = import 'network/NetworkSecurityGroup/module.libsonnet';
local VirtualMachineScaleSet = import 'compute/VirtualMachineScaleSet/module.libsonnet';

// Technically, there is nothing that *requires* a module to extend the core Module. Anything
// looking enough like a module (i.e. manifests a resources array, and output dictionary and optionally
// a parameterMetadata dictionary and accepts a 'parameters' dictionary with arguments works just as well)
// However, using Module as base gives you basic parameter validation and collection of all generated resources
// into the resources array for free...
Module {

    // Parameter metadata allows for introspection of the module to understand what
    // parameters can be passed to the module as well as other metadata such as 
    // default values and parameter types. 
    parameterMetadata: {
        name: {
            type: 'string',
            defaultValue: 'vmss'
        },
        size: {
            type: 'string',
            defaultValue: 'Standard_DS1_V2'
        },
        allowPublicAccess: {
            type: ['boolean', 'string', 'object' ],
            defaultValue: true
        },
        subnet: {
            type: 'string',
            defaultValue: null
        },
    },

    // It is easy to conditionally create a resource.
    // The arguments member was populated automagically by the base module based on
    // parameters passed in to the module and default values for the module parameters
    networkSecurityGroup:: if $.arguments.allowPublicAccess then 
                            NetworkSecurityGroup {
                                parameters: {
                                    name: $.arguments.name + 'nsg',
                                    rule: 'ssh'
                               } 
                            },


    virtualNetwork:: if $.arguments.subnet == null then VirtualNetwork {
        parameters: {
            name: $.arguments.name + 'vnet',
            addressPrefix: if $.arguments.size == 'small' then '10.0.0.0/24' else '10.0.0.0/16',
            subnet: 'frontend',
            networkSecurityGroup: $.networkSecurityGroup
        }
    },

    virtualMachineScaleSet:: VirtualMachineScaleSet {
        parameters: {
            name: $.arguments.name,
            imageReference: 'ubuntuLTS', // TODO: Move the simple/commonly used image names from the CLI VMSS module to the platform VMSS module
            skuName: $.arguments.size,
            // Passing a resource as an argument to another module sets up a dependency automagically
            [if $.arguments.subnet == null then 'virtualNetwork']: $.virtualNetwork.virtualNetwork, // ISSUE - getting 'root' instance from a module is ugly here
            [if $.arguments.subnet != null then 'subnet']: $.arguments.subnet
        },
    },

} 
// Parameters below are not part of the actual module - they are here to allow for quick testing
// of the module. 
{
    parameters:: {
        size: 'Standard_A0',
        allowPublicAccess: true,
        subnet: '/subscriptions/43fb366f-2061-4600-9d5d-795a6a0bba4c/resourceGroups/cli/providers/Microsoft.Network/virtualNetworks/vnet/subnets/default'
    }
}