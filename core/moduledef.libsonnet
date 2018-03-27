local module = import 'module.libsonnet';
local stdex = module.stdex;


{
    parameters:: std.extVar('parameters'),
    parameterMetadata:: error "A module must declare it's parameters and associated metadata",

    id:: $.outputs,

    arguments::
        stdex.mergeParameters($.parameters, $.parameterMetadata),

    resources:std.flattenArrays(
    [
        if module.isResource(self[key]) then [ self[key] ] else self[key].resources,
        for key in std.objectFieldsAll(self) if key != 'resources' && (module.isResource(self[key]) || module.isModule(self[key]))
    ]),
    outputs: {},
}