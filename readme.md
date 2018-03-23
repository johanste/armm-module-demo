## Module
### Consumption
Evaluating a module yields an object conforming to the following subset of attributes of an ARM template: 
```
{
    resources: [
        { ... }
    ],

    outputs: {
        ...: {
            ...
        }
        ...
    }
}
```
Arguments are passed to the module by injecting a parameters object with parameter name/value key/value pairs. 

Example:
```
(import 'module.libsonnet') { 
    parameters: { 
        stringValue: 'a string', 
        optionalIntegerValue: 2}
    }
```
### Introspection/module metadata
A caller can inspect what arguments a module provides by examining the parameterMetadata field. 
```
{
    parameterMetadata:: {
        stringValue: {
            type: 'string'
        },
        optionalIntegerValue: {
            type: 'number',
            defaultValue: 7
        }
    }
}
```
The `parameterMetadata` will also be used by the module to validate the provided parameters.

## Resource
