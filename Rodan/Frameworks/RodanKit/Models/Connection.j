@import "RKModel.j"
@import "InputPort.j"
@import "OutputPort.j"
@import "Workflow.j"
@import "WorkflowJob.j"

@implementation Connection : RKModel
{
    InputPort       inputPort           @accessors; //input Port index or actual model
    WorkflowJob     inputWorkflowJob    @accessors;

    OutputPort      outputPort          @accessors;
    WorkflowJob     outputWorkflowJob   @accessors;
    Workflow        workflow            @accessors;

    //NOTE: I/O ports should be string or integer, && I/O WorkflowJob
}

+ (CPArray)remoteProperties
{
    return [
        ['pk', 'url'],
        ['uuid', 'uuid'],
        ['inputPort', 'input_port', [WLForeignObjectTransformer forObjectClass:InputPort]],
        ['inputWorkflowJob', 'input_workflow_job', [WLForeignObjectTransformer forObjectClass:WorkflowJob]],
        ['outputPort', 'output_port', [WLForeignObjectTransformer forObjectClass:OutputPort]],
        ['outputWorkflowJob', 'output_workflow_job', [WLForeignObjectTransformer forObjectClass:WorkflowJob]],
        ['workflow', 'workflow', [WLForeignObjectTransformer forObjectClass:Workflow]]
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
        return @"/connection/";
    }
}

@end