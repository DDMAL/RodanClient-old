@import "OutputPortType.j"
@import "WorkflowJob.j"


@implementation OutputPort : WLRemoteObject
{
    CPString        pk                 @accessors;
    CPString        uuid                @accessors;

    CPString        workflowJob         @accessors;
    CPString        outputPortType      @accessors;
    CPString        label                @accessors;

}

+ (CPArray)remoteProperties
{
    return [
        ['pk', 'url'],
        ['uuid', 'uuid'],
        ['workflowJob', 'workflowJob'],
        ['label', 'label'],
        ['outputPortType', 'output_port_type']
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
        return @"/outputport/";
    }
}

@end