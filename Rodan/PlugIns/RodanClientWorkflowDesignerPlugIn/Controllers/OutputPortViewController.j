@import <Foundation/Foundation.j>

@import "../Views/OutputPortView.j"
@import <RodanKit/OutputPort.j>
@import "WorkflowJobViewController.j"
@import "ConnectionViewController.j"

@implementation OutputPortViewController : CPObject
{
    BOOL                            isUsed                      @accessors;
    CPString                        outputPortType              @accessors;

    WorkflowJobViewController       workflowJobViewController   @accessors;
    ResourceListViewController      resourceListViewController  @accessors;

    //associated view
    OutputPortView                  outputPortView              @accessors;

    OutputPort                      outputPort                  @accessors;

    ConnectionViewController        connection                  @accessors;
}


- (id)initWithType:(CPString)aType workflowJobRef:(WorkflowJobViewController)aWorkflowJobRef resourceListRef:(ResourceListViewController)aResourceListRef
{
    self = [super init];

    if (self)
    {
        outputPortType = aType;
        isUsed = NO;

        workflowJobViewController = aWorkflowJobRef;
        resourceListViewController = aResourceListRef;

    }

    return self;
}



@end