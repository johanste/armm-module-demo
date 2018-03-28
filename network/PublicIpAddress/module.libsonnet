local core = import 'core/module.libsonnet';
local stdex = core.stdex;
local Module = import 'core/moduledef.libsonnet';

Module {
    parameterMetadata:: {
        name: {
            type: 'string'
        },
        allocationMethod: {
            type: 'string',
            defaultValue: 'dynamic'
        },
    },

    resource:: $.new($.arguments.name, allocationMethod = $.arguments.allocationMethod),

    new(name, allocationMethod=null)::
        assert stdex.isString(name) : "Incorrect type for parameter 'name' - expected 'string', got '%s'" % [ std.type(name)];
        assert allocationMethod == null || stdex.isString(allocationMethod) : "Incorrect type for parameter 'parameters' - expected 'object', got '%s'" % [ std.type(name)];

        local resource = (import 'publicIpAddress.libsonnet').new(
            name=name);

        resource.withAllocationMethod(allocationMethod),

    outputs: {
        id: {
            type: 'string',
            value: $.resource.id
        }
    }
}