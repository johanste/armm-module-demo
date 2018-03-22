local core = import 'core/module.libsonnet';
local stdex = core.stdex;

{
    parameterMetadata:: {
        name: {
            type: 'string'
        },
        allocationMethod: {
            type: 'string',
            defaultValue: 'dynamic'
        },
    },

    local parameters = stdex.mergeParameters($.parameters, $.parameterMetadata),
    instance:: $.new(parameters.name, allocationMethod = parameters.allocationMethod),

    new(name, allocationMethod=null)::
        assert stdex.isString(name) : "Incorrect type for parameter 'name' - expected 'string', got '%s'" % [ std.type(name)];
        assert allocationMethod == null || stdex.isString(allocationMethod) : "Incorrect type for parameter 'parameters' - expected 'object', got '%s'" % [ std.type(name)];

        local instance = (import 'publicIpAddress.libsonnet').new(
            name=name);

        instance.withAllocationMethod(allocationMethod),

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