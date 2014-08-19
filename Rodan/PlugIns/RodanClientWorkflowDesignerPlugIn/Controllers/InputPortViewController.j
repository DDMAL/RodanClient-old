@import <Foundation/Foundation.j>

@import "../Views/InputPortView.j"
@import <RodanKit/InputPort.j>
@import "WorkflowJobViewController.j"
@import "ConnectionViewController.j"

@implementation InputPortViewController : CPObject
{
    BOOL                            isUsed                      @accessors;
    CPString                        inputPortType               @accessors;

    WorkflowJobViewController       workflowJobViewController   @accessors;

    //associated view
    InputPortView                   inputPortView               @accessors;

    InputPort                       inputPort                   @accessors;

    ConnectionViewController        connection                  @accessors;
}

- (id)initWithType:(CPString)aType workflowJobRef:(WorkflowJobViewController)aWorkflowJobRef
{
    self = [super init];

    if (self)
    {
        inputPortType = aType;
        isUsed = NO;

        workflowJobViewController = aWorkflowJobRef;
    }

    return self;
}



@end