local core = import 'core/module.libsonnet';
local stdex = core.stdex;

{
    parameterMetadata:: {
        name: {
            type: 'string'
        }
    },

    local parameters = stdex.mergeParameters($.parameters, $.parameterMetadata),
    instance:: $.new(parameters),

    new(parameters)::
        (import 'networkSecurityGroup.libsonnet').new(parameters),

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