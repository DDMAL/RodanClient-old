@import "RKModel.j"

@implementation ResourceAssignment : RKModel
{
    CPString    inputPort   @accessors;
    CPArray     resources   @accessors;
    CPString    workflow    @accessors;
    CPString    workflowJob @accessors;
}

+ (CPArray)remoteProperties
{
    return [
        ['pk', 'url'],
        ['uuid', 'uuid'],
        ['inputPort', 'input_port'],
        ['resources', 'resources'],
        ['workflow', 'workflow'],
        ['workflowJob', 'workflow_job']
    ];
}

- (CPString)remotePath
{
    if ([self pk])
        return [self pk]
    else
        return [[CPBundle mainBundle] objectForInfoDictionaryKey:"ServerHost"] + @"/resourceassignments/";
}

@end