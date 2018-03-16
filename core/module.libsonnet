{
    Resource:: import './resource.libsonnet',

    isValidResourceId(value)::
        if std.type(value) != 'string' then false
        else value[0] == '[' || std.startsWith(value, '/subscriptions'),

    resourceId(instanceOrString)::
        if ! $.isValidResourceId(instanceOrString) then instanceOrString
        else instanceOrString.id,

    resourceName(instanceOrName)::
        if std.type(instanceOrName) == 'string' then instanceOrName
        else instanceOrName.name,

    stdex:: {

        coalesce(arr)::
            local isNonNull = function(item)
                item != null;

            local nonNullItems = std.filter(isNonNull, arr) ;
            if nonNullItems == [] then
                null
            else 
                nonNullItems[0],

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

