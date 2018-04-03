# Modules

## Definition
A module is a jsonnet library that, when evaluated, yields an object conforming to the following subset of attributes of an ARM template: 

```
{
    resources: [
        { <resource definition> }
    ],

    outputs: {
        ...: {
            ...
        }
        ...
    }
}
```
*(In fact, an existing ARM template intended for inline use is a valid Module per this definition)*

A module can be parameterized. Argument values are passed to the module by injecting a 'parameters' environment variable into the execution environment (equivaluent of passing a `ext-str parameters=...` to the [jsonnet cli](http://jsonnet.org/implementation/commandline.html))

## Conventions
In addition to the core definition of a module, there are several conventions that, when followed, provide surrounding tooling with additional information/capabilities.

### Introspection/module metadata

A module may declare parameters that it supports by providing a parmameterMetadata attribute. The parameterMetadata attribute includes the name, type and default value for parameters. *TODO: additional functionality can be added to parameterMetadata, including imperative validation, descriptions, enum values etc.)*

Example: 
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

A caller may inspect what arguments a module provides by examining the *parameterMetadata* field of the module. 
The *parameterMetadata* can also be used by the module (or caller) to validate the provided parameters.

*TODO: if we rename `parameterMetadata` to `parameters`, and make sure we follow the same schema as an ARM template's parameters section, we have an ever stronger correlation between `ARM templates` and `Modules`. This way, we'd also make it a formal part of a module definition rather than a convention*
### Id field

In many cases, a module logically defines a root (anchor) resource with a set of dependent resources. A module may chose to expose this id to other modules by providing a top level id attribute. 

## Platform libraries

### Module base implementation

A module author may take advantage of a core module definition that provides validation of parameters based on parameterMetadata.

### Resource base implementation

