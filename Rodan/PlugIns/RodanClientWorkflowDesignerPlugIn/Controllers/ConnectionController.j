@import <Foundation/CPObject.j>

@import <RodanKit/Connection.j>
@import "OutputPortViewController.j"
@import "InputPortViewController.j"
@import "ResourceListViewController.j"
@import "WorkflowJobViewController.j"


@implementation ConnectionController : CPObject
{
    CPBezierPath                pathAToB                @accessors;

    CGPoint                     endPoint                @accessors;
    CGPoint                     controlPoint1           @accessors;
    CGPoint                     controlPoint2           @accessors;
    CGPoint                     startPoint              @accessors;
    CPString                    name                    @accessors;

    BOOL                        isUsed                  @accessors;

    //associated references
    Connection                  connection              @accessors; //reference to server model

    OutputPortViewController    outputReference         @accessors;
    InputPortViewController     inputReference          @accessors;

    WorkflowJobViewController   outputWorkflowJob       @accessors;
    WorkflowJobViewController   inputWorkflowJob        @accessors;

    ResourceListViewController  resourceListRef         @accessors;
}

- (id)initWithName:(CPString)aName outputWorkflowJob:(WorkflowJobViewController)oWorkflowJob inputWorkflowJob:(WorkflowJobViewController)iWorkflowJob outputRef:(OutputPortViewController)oRef inputRef:(InputPortViewController)iRef resourceListRef:(ResourceListViewController)rRef;
{
    self = [super init];

    if (self)
    {
        endPoint = CGPointMake(0.0, 0.0);
        controlPoint1 = CGPointMake(0.0, 0.0);
        controlPoint2 = CGPointMake(0.0, 0.0);
        startPoint = CGPointMake(0.0, 0.0);

        inputWorkflowJob = iWorkflowJob;
        outputWorkflowJob = oWorkflowJob;
        outputReference = oRef;
        inputReference = iRef;
        resourceListRef = rRef;

        name = aName;
        isUsed = false;
        pathAToB = [[CPBezierPath alloc] init];

    }
    return self
}


- (void)makeConnectPointAtCurrentPoint:(CGPoint)currentPt controlPoint1:(CGPoint)ctrlPt1 controlPoint2:(CGPoint)ctrlPt2 endPoint:(CGPoint)endPt
{
    startPoint = currentPt
    controlPoint1 = ctrlPt1
    controlPoint2 = ctrlPt2
    endPoint = endPt;
}



@end