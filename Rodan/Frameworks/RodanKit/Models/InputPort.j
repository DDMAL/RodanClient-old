@import "RKModel.j"
@import "InputPortType.j"
@import "WorkflowJob.j"

@implementation InputPort : RKModel
{
    InputPortType   inputPortType   @accessors;
    CPString        label           @accessors;
    WorkflowJob     workflowJob     @accessors;
}

+ (CPArray)remoteProperties
{
    return [
        ['pk', 'url'],
        ['uuid', 'uuid'],
        ['InputPortType', 'input_port_type', [WLForeignObjectTransformer forObjectClass:InputPortType]],
        ['label', 'label'],
        ['workflowJob', 'workflow_job', [WLForeignObjectTransformer forObjectClass:WorkflowJob]]
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
        return @"/inputport/";
    }
}

@end