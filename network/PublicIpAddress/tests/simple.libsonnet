local PublicIpAddress = import '../module.libsonnet';

local publicIp = PublicIpAddress.new(name='simplePublicIp', allocationMethod='static');
local module = PublicIpAddress {
    parameters:: {
        name: 'simplePublicIp',
        allocationMethod: 'static'
    },
};

{
    r: publicIp,
    m: module.instance,
}