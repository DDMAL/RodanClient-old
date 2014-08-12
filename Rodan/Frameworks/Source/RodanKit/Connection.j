@import "RKModel.j"
@import "InputPort.j"
@import "OutputPort.j"
@import "Workflow.j"
@import "WorkflowJob.j"

@implementation Connection : RKModel
{
    CPString        pk                  @accessors;
    CPString        inputPort           @accessors;
    CPString        inputWorkflowJob    @accessors;

    CPString        outputPort          @accessors;
    CPString        outputWorkflowJob   @accessors;
    CPString        workflow            @accessors;
}

+ (CPArray)remoteProperties
{
    return [
        ['pk', 'url'],
        ['uuid', 'uuid'],
        ['inputPort', 'input_port'],
        ['inputWorkflowJob', 'input_workflow_job'],
        ['outputPort', 'output_port'],
        ['outputWorkflowJob', 'output_workflow_job'],
        ['workflow', 'workflow']
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
        return [[CPBundle mainBundle] objectForInfoDictionaryKey:"ServerHost"] + @"/connections/";
    }
}

@end