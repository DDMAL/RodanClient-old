@import <Foundation/Foundation.j>

@import "../Views/InputPortView.j"
@import <RodanKit/InputPort.j>
@import "WorkflowJobViewController.j"
@import "LinkViewController.j"

@implementation InputPortViewController : CPObject
{
    BOOL                            isUsed                      @accessors;
    CPString                        inputPortType               @accessors;

    WorkflowJobViewController       WorkflowJobViewController   @accessors;
    LinkViewController              linkViewController          @accessors;

    //associated view
    InputPortView                   inputPortView               @accessors;

    InputPort                       inputPort                   @accessors;
}

- (id)initWithType:(CPString)aType workflowJobRef:(WorkflowJobViewController)aWorkflowJobRef
{
    self = [super init];

    if (self)
    {
        inputPortType = aType;
        isUsed = NO;

        wkflowJobViewController = aWorkflowJobRef;
    }

    return self;
}



@end