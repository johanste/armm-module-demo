local Module = import 'core/moduledef.libsonnet';
local VirtualMachineScaleSet = import 'virtualMachineScaleSet.libsonnet';

Module {

    parameterMetadata:: {
        name: {
            type: 'string',
        },
        osType: {
            type: 'string', 
            defaultValue: 'linux',
        },
        skuName: {
            type: 'string',
            defaultValue: 'standard_d1_v2',
        },
        imageReference: {
            type: 'object',
        },
        capacity: {
            type: 'number',
            defaultValue: 3
        },
        overProvision: {
            type: 'boolean',
            defaultValue: null,
        },
        platformFaultDomainCount: {
            type: 'number',
            defaultValue: null,
        },
        singlePlacementGroup: {
            type: 'number',
            defaultValue: null,
        },
        upgradePolicy: {
            type: 'string',
            defaultValue: 'manual',
        },
        zoneBalance: {
            type: 'boolean',
            defaultValue: null
        }
    },

    resource:: VirtualMachineScaleSet.new (
        name = $.arguments.name,
        imageReference = $.arguments.imageReference,
        osType = $.arguments.osType,
        skuName = $.arguments.skuName,
        capacity = $.arguments.capacity,
        overProvision = $.arguments.overProvision,
        platformFaultDomainCount = $.arguments.platformFaultDomainCount,
        singlePlacementGroup = $.arguments.singlePlacementGroup,
        upgradePolicy = $.arguments.upgradePolicy,
        zoneBalance = $.arguments.zoneBalance
    ),

    resources: [
        $.resource
    ],
    outputs: {
        id: {
            type: 'string',
            value: $.resource.id
        }
    }
}