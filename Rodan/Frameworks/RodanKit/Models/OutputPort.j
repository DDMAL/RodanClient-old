@import "OutputPortType.j"
@import "WorkflowJob.j"


@implementation OutputPort : WLRemoteObject
{
    CPString        pk                 @accessors;
    CPString        uuid                @accessors;

    WorkflowJob     workflowJob         @accessors;
    OutputPortType  outputPortType      @accessors;
    CPString        label                @accessors;

}

+ (CPArray)remoteProperties
{
    return [
        ['pk', 'url'],
        ['uuid', 'uuid'],
        ['workflowJob', 'workflowJob', [WLForeignObjectTransformer forObjectClass:WorkflowJob]],
        ['label', 'label'],
        ['outputPortType', 'output_port_type', [WLForeignObjectTransformer forObjectClass:OutputPortType]]
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