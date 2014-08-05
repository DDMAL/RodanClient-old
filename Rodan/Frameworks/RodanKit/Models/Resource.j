@import <Ratatosk/WLRemoteTransformers.j>
@import "RKModel.j"
@import "User.j"

@implementation Resource : RKModel
{
    CPString    projectURI          @accessors;
    CPString    name                @accessors;
    CPString    resourceFile        @accessors;
    CPString    compatResourceFile  @accessors;
    CPString    resourceImage       @accessors;
    CPString    resourceType        @accessors;
    CPInteger   resourceOrder       @accessors;
    CPString    workflow            @accessors;
    CPString    runJob              @accessors;

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
        ['projectURI', 'project'],
        ['name', 'name'],
        ['resourceFile', 'resource_file'],
        ['compatResourceFile', 'compat_resource_file'],
        ['resourceImage', 'resource_image']
        ['resourceType', 'resource_type'],
        ['workflow', 'workflow'],
        ['creator', 'creator', [WLForeignObjectTransformer forObjectClass:User]]
        ['origin', 'origin'],
        ['runJob', 'run_job'],
        ['created', 'created', [[WLDateTransformer alloc] init], true],
        ['updated', 'updated', [[WLDateTransformer alloc] init], true],
    ];
}

- (CPString)remotePath
{
    if ([self pk])
        return [self pk]
    else
        return [[CPBundle mainBundle] objectForInfoDictionaryKey:"ServerHost"] + @"/resources/";
}

@end