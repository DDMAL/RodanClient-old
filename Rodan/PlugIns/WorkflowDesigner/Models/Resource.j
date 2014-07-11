@import <Ratatosk/WLRemoteTransformers.j>
@import "User.j"

@implementation Resource : WLRemoteObject
{
    CPString    pk                  @accessors;
    CPString    uuid                @accessors;
    CPString    name                @accessors;
    CPString    project             @accessors;
    CPString    resourceFile        @accessors;
    CPString    compatResourceFile  @accessors;

    CPString    resourceType        @accessors;
    CPString    workflow            @accessors;

    User        creator             @accessors;
    CPString    origin              @accessors;

    CPDate    created             @accessors;
    CPDate    updated             @accessors;

}

+ (CPArray)remoteProperties
{
    return [
        ['pk', 'url'],
        ['uuid', 'uuid'],
        ['name', 'name'],
        ['project', 'project'],
        ['resourceFile', 'resource_file'],
        ['compatResourceFile', 'compat_resource_file'],
        ['resourceType', 'resource_type'],
        ['workflow', 'workflow'],
        ['origin', 'origin'],
        ['created', 'created', [[WLDateTransformer alloc] init], true],
        ['updated', 'updated', [[WLDateTransformer alloc] init], true],
        ['creator', 'creator', [WLForeignObjectTransformer forObjectClass:User]]
    ];
}

- (CPString)remotePath
{
    if ([self pk])
        return [self pk]
    else
        return @"/resources/";
}

@end