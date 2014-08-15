@import <Foundation/Foundation.j>

@import "../Views/OutputPortView.j"
@import <RodanKit/OutputPort.j>
@import "WorkflowJobViewController.j"
@import "LinkViewController.j"

@implementation OutputPortViewController : CPObject
{
    BOOL                            isUsed                      @accessors;
    CPString                        outputPortType              @accessors;

    WorkflowJobViewController       wkflowJobViewController     @accessors;
    LinkViewController              linkViewController          @accessors;

    OutputPort                      oPort                       @accessors;
}


- (id)initWithType:(CPString)aType workflowJobRef:(WorkflowJobViewController)aWorkflowJobRef linkRef:(LinkViewController)aLinkRef
{
    self = [super init];

    if (self)
    {
        outputPortType = aType;
        isUsed = NO;

        wkflowJobViewController = aWorkflowJobRef;
        linkViewController = aLinkRef;
    }

    return self;
}



@end