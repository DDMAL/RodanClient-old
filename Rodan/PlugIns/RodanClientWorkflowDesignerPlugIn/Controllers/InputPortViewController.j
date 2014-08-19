@import <Foundation/Foundation.j>

@import "../Views/InputPortView.j"
@import <RodanKit/InputPort.j>
@import "WorkflowJobViewController.j"
@import "LinkViewController.j"
@import "ConnectionViewController.j"

@implementation InputPortViewController : CPObject
{
    BOOL                            isUsed                      @accessors;
    CPString                        inputPortType               @accessors;

    WorkflowJobViewController       workflowJobViewController   @accessors;
    LinkViewController              linkViewController          @accessors;

    //associated view
    InputPortView                   inputPortView               @accessors;

    InputPort                       inputPort                   @accessors;

    ConnectionController            connection                  @accessors;
}

- (id)initWithType:(CPString)aType workflowJobRef:(WorkflowJobViewController)aWorkflowJobRef
{
    if (self = [super init])
    {
        inputPortType = aType;
        isUsed = NO;

        workflowJobViewController = aWorkflowJobRef;
    }

    return self;
}

@end
