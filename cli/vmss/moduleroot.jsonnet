local m = import './module.libsonnet';

function(params)
    m {
        parameters: {
            [k]: ((params.parameters)[k]).value
            for k in std.objectFieldsAll(params.parameters)
        },
    } {
        '$schema': 'https://schema.management.azure.com/schemas/2015-01-01/deploymentTemplate.json#',
        contentVersion: '0.0.0.1'
    }

