local armmodule = import '../core/module.libsonnet';

armmodule.Resource {
 
    apiVersion: '2017-11-01',
    type: 'Microsoft.Network/networkSecurityGroups',
    location: "[resourceGroup().location]",

    wellKnownRules:: {
        ssh: {
            name: 'IncomingSSH',
            properties: {
                access: 'Allow',
                direction: "inbound",
                protocol: 'tcp',
                sourcePortRange: 22,
                destinationPortRange: 22,
                sourceAddressPrefix: '*',
                destinationAddressPrefix: '*',
                priority: 1000,
            }
        }
    },

    new(name)::
        self {
            name: name,
            properties: {
                securityRules: [],
            },
        },

    withRule(rule,
            access=null, 
            direction=null,
            priority=null, 
            protocol=null, 
            sourcePortRange=null,
            destinationPortRange=null)::
        local ruleDefinition = if std.type(rule) == 'string' && std.objectHas($.wellKnownRules, rule) then $.wellKnownRules[rule] else rule;
        local overrides = std.prune({
            [if std.type(ruleDefinition) == 'string' then 'name']: ruleDefinition,
            properties: {
                access: access,
                direction: direction,
                priority: priority,
                protocol: protocol,
                sourcePortRange: sourcePortRange,
                destinationPortRange: destinationPortRange,
            },
        });

        self {
            properties +: {
                securityRules +: [
                    std.mergePatch(ruleDefinition,overrides)
                ]
            },
        },
}