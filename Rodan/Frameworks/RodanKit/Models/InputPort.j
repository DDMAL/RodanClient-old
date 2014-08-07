@import "InputPortType.j"
@import "WorkflowJob.j"


@implementation InputPort : WLRemoteObject
{
    CPString        pk             @accessors;
    CPString        uuid            @accessors;
    CPString        inputPortType   @accessors;
    CPString        label           @accessors;
    CPString        workflowJob     @accessors;
}

+ (CPArray)remoteProperties
{
    return [
        ['pk', 'url'],
        ['uuid', 'uuid'],
        ['inputPortType', 'input_port_type'],
        ['label', 'label'],
        ['workflowJob', 'workflow_job']
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
        return [[CPBundle mainBundle] objectForInfoDictionaryKey:"ServerHost"] + @"/inputports/";
    }
}

@end