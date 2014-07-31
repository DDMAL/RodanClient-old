


@implementation InputPortType : WLRemoteObject
{
    CPString        pk             @accessors;
    CPString        uuid            @accessors;

    CPString        job             @accessors;
    CPString        name            @accessors;
    CPInteger       minimum         @accessors;
    CPInteger       maximum         @accessors;
    CPInteger       resourceType    @accessors;
}

+ (CPArray)remoteProperties
{
    return [
        ['pk', 'url'],
        ['uuid', 'uuid'],
        ['job', 'job'],
        ['name', 'name'],
        ['minimum', 'minimum'],
        ['maximum', 'maximum'],
        ['resourceType', 'resource_type']
    ];
}


- (CPString)remotePath
{
    if ([self pk])
    {
        return [self pk]
    }
    else
    {
        return @"/inputporttype/";
    }
}

@end