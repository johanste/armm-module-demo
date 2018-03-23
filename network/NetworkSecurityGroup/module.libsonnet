local Module = import 'core/moduledef.libsonnet';

Module {
    parameterMetadata:: {
        name: {
            type: 'string'
        },
        rule: {
            type: 'string',
            defaultValue: null,
        },
    },

    resource::
        (import 'networkSecurityGroup.libsonnet').new($.arguments.name).withRule($.arguments.rule),

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