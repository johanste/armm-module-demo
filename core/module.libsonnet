{
    Resource:: import './resource.libsonnet',

    isValidResourceId(value)::
        if std.type(value) != 'string' then false
        else value[0] == '[' || std.startsWith(value, '/subscriptions'),

    isResource(resource)::
        $.stdex.isObject(resource) && $.stdex.get(resource, 'type', null) != null,

    isModule(object)::
        $.stdex.isObject(object) && $.stdex.get(object, 'resources', null) != null,
        
    resourceId(instanceOrString)::
        if $.stdex.isString(instanceOrString) then instanceOrString
        else if 'id' in instanceOrString then instanceOrString.id
        else error "'Tried to get id from object that didn't have an id - '%s'" % [ instanceOrString ],

    resourceName(instanceOrName)::
        if std.type(instanceOrName) == 'string' then
            assert instanceOrName[0] != '[' : "TODO: Computed names not supported yet...";
            local parts = std.split(instanceOrName, '/');
            if std.length(parts) >= 8 then
                // The 7th segment of an id is the name...
                parts[7] 
            else
                instanceOrName
        else instanceOrName.name,

    stdex:: {

        isString(val)::
            std.type(val) == 'string',

        isObject(val)::
            std.type(val) == 'object',

        isArray(val)::
            std.type(val) == 'array',

        mergeParameters(parameters, metadata, acceptUnknownParameters = false)::
            // UNDONE: Check type + validate value
            local unknownParameters = [
                parameterName
                for parameterName in std.objectFieldsAll(parameters) 
                if !(parameterName in metadata)
            ];
            assert acceptUnknownParameters || std.length(unknownParameters) == 0 : "Unexpected parameters '%s' received. Expected one of '%s'" % [ unknownParameters, std.objectFieldsAll(metadata) ];

            local mergedParameters = parameters {
                local validator = 
                                if 'validate' in metadata[k] then 
                                    metadata[k].validate 
                                else function(val) val,

                [k] : if k in super then validator(super[k]) else if 'defaultValue' in metadata[k] then metadata[k].defaultValue else error "Missing parameter '%s'" % [ k ]
                for k in std.set(std.objectFieldsAll(parameters) + std.objectFieldsAll(metadata))
            };
            mergedParameters,

 
        get(instance, member, default)::
            assert self.isObject(instance) : "Incorrect type for parameter 'instance' - expected 'object', got '%s'" % [ std.type(instance) ];
            assert self.isString(member) : "Incorrect type parameter 'member' - expected 'string', got '%s'" % [ std.type(member) ];
            
            if std.objectHasAll(instance, member) then
                instance[member]
            else
                default,
                
        last(arr)::
            assert std.type(arr) == 'array' : "parameter 'arr' must be of type 'array' - got " % [ std.type(arr) ];
            local len = std.length(arr);
            if len == 0 then 
                null
            else 
                arr[std.length(arr) - 1],

        strReplace(str, from, to)::
            if str == '' then ''
            else if std.startsWith(str, from) then to + self.strReplace(std.substr(str, std.length(from), std.length(str) - std.length(from)), from, to)
            else std.substr(str, 0, 1) + self.strReplace(std.substr(str, 1, std.length(str) - 1), from, to),
    },
}

