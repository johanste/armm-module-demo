local Module = import 'core/moduledef.libsonnet';

Module {

    id:: $.resource.id,

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

    outputs: {
        id: {
            type: 'string',
            value: $.id
        }
    }
}