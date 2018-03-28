{
    name: {
        type: 'string'
    },
    imageReference: {
        type: ['string', 'object'],
    },
    adminUserName: {
        type: 'string'
    },
    location: {
        type: 'string'
    },
    disableOverprovision: {
        type: 'boolean',
        defaultValue: false,
    }, 
    instanceCount: {
        type: 'integer',
        defaultValue: 2,
    },
    upgradePolicy: {
        type: 'string',
        defaultValue: 'manual', 
    },
    adminPassword: {
        type: 'string',
        defaultValue: null
    },
    authenticationType: {
        type: 'string',
        defaultValue: if $.osType == 'Windows' then 'rdp' else 'ssh',
    },
    vmSku: {
        type: 'string',
        defaultValue: 'Standard_D1_v2', 
    },
    sshPublicKeys: {
        type: 'string', 
        defaultValue: [],
    },
    loadBalancer: {
        type: ['object', 'string'],
        defaultValue: null, // { sku: null },
    },
    loadBalancerSku: {
        type: 'string',
        defaultValue: null,
    },
    virtualNetwork: {
        type: [ 'object', 'string' ],
        defaultValue: '[new]',
    },
    backendPoolName: {
        type: 'string', 
        defaultValue: null,
    },
    natPoolName: {
        type: 'string',
        defaultValue: null,
    },
    backendPort: {
        type: 'string',
        defaultValue: null,
    },
    publicIpAllocationMethod: {
        type: 'string',
        defaultValue: 'dynamic',
    },
    dataDiskSizes: {
        type: ['array', 'number' ],
        defaultValue: [],
    }, 
    osType: {
        type: 'string',
        defaultValue: null, // error "'osType' is a required parameters",
    },
    subnet: {
        type: [ 'string', 'object' ],
        defaultValue: null,
    },
    customData: {
        type: 'string',
        defaultValue: null,
    },
    licenseType: {
        type: 'string',
        defaultValue: null,
    },
    singlePlacementGroup: {
        type: 'boolean',
        defaultValue: $.instanceCount <= 100,
    },
    publicIpAddress: {
        type: [ 'string', 'object' ],
        defaultValue: null,
    },
    publicIpAddressDnsName: {
        type: 'string',
        defaultValue: null,
    },
    publicIpAddressPerVm: {
        type: 'boolean', 
        defaultValue: false,
    },
    zones: {
        type: 'array',
        defaultValue: [],
    }, 
    dataDiskCaching: {
        type: 'string',
        defaultValue: null,
    },
    identity: {
        type: [ 'array', 'string' ],
        defaultValue:null
    }
}