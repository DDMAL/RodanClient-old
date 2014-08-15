@import <Foundation/Foundation.j>

@import "../Views/InputPortView.j"
@import <RodanKit/InputPort.j>
@import "WorkflowJobViewController.j"
@import "LinkViewController.j"

@implementation InputPortViewController : CPObject
{
    BOOL                            isUsed                      @accessors;
    CPString                        inputPortType                   @accessors;

    WorkflowJobViewController       WorkflowJobViewController   @accessors;
    LinkViewController              linkViewController          @accessors;

    InputPort                       iPort                       @accessors;
}

- (id)initWithType:(CPString)aType workflowJobRef:(WorkflowJobViewController)aWorkflowJobRef linkRef:(LinkViewController)aLinkRef
{
    self = [super init];

    if (self)
    {
        inputPortType = aType;
        isUsed = NO;

        wkflowJobViewController = aWorkflowJobRef;
        linkViewController = aLinkRef;
    }

    return self;
}



@end