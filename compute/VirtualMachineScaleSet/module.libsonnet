{
    defaultParameters:: {
    },

    instance:: $.new($.defaultParameters + $.parameters),

    new(name, parameters)::
        (import 'virtualMachineScaleSet.libsonnet').new(name),

    resources: [
        $.instance
    ],
    outputs: {
        id: {
            type: 'string',
            value: $.instance.id
        }
    }
}