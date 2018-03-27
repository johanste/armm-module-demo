local core = import 'module.libsonnet';

{
    id:: "[resourceId('%s', '%s')]" % [ self.type, self.name ],
    type: error "resource must have a 'type' property",
    apiVersion: error "resource must have a 'apiVersion' property",
    location: "[resourceGroup().location]",
    name: error "'name' is a required property for resources",

    dependsOn:[],
    tags: {},
    withDependency(resourceOrId)::
        if core.isResource(resourceOrId) || core.isModule(resourceOrId) then 
            self {
                dependsOn +: [ resourceOrId.id ]
            }
        else
            self,

    properties: {

    },
}