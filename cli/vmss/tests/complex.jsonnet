(import 'cli/vmss/module.libsonnet')
    {
        parameters:: {
            name: 'complex',
            adminUserName: 'johanste',
            imageReference: 'UbuntuLTS',
            adminPassword: 'super$ecret3611',
            dataDiskSizes: [1024, 2024, 2048],
            publicIpAddress: null,
        } 
    }
