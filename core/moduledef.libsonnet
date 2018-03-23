local stdex = (import 'module.libsonnet').stdex;


{
    parameters:: error "'parameters' is a required attribute of a module",
    parameterMetadata:: error "A module must declare it's parameters and associated metadata",

    arguments::
        stdex.mergeParameters($.parameters, $.parameterMetadata),

    resources:[],         
    outputs: {},
}