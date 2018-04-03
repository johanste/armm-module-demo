local m = import './module.libsonnet';

function(args)
    m {
        parameters: {
            [k]: ((args.parameters)[k]).value
            for k in std.objectFieldsAll(args.parameters)
        },
    } {
        '$schema': 'https://schema.management.azure.com/schemas/2015-01-01/deploymentTemplate.json#',
        contentVersion: '0.0.0.1'
    }

