@import <Foundation/CPObject.j>



@implementation Link : CPObject
{
    CPBezierPath        pathAToB;
    CGPoint             endPoint            @accessors;
    CGPoint             controlPoint1       @accessors;
    CGPoint             controlPoint2       @accessors;
    CGPoint             currentPoint        @accessors;
    CPString            name                @accessors;

    CPUInteger          workflowStart       @accessors;
    CPUInteger          workflowEnd         @accessors;
    CPUInteger          outputRef           @accessors;
    CPUInteger          inputRef            @accessors;
    CPUInteger          resourceListRef     @accessors;

    BOOL                isUsed              @accessors;
}

- (id)initWithName:(CPString)aName workflowStart:(CPUInteger)wflowStart workflowEnd:(CPUInteger)wflowEnd outputRef:(CPUInteger)oRef inputRef:(CPUInteger)iRef resourceListRef:(CPUInteger)rRef;
{
    self = [super init];

    if (self)
    {
        endPoint = CGPointMake(0.0, 0.0);
        controlPoint1 = CGPointMake(0.0, 0.0);
        controlPoint2 = CGPointMake(0.0, 0.0);
        currentPoint = CGPointMake(0.0, 0.0);

        workflowStart = wflowStart;
        workflowEnd = wflowEnd;
        outputRef = oRef;
        inputRef = iRef;
        resourceListRef = rRef;

        name = aName;
        isUsed = false;
        pathAToB = [[CPBezierPath alloc] init];

    }
    return self
}


- (void)makeConnectPointAtCurrentPoint:(CGPoint)currentPt controlPoint1:(CGPoint)ctrlPt1 controlPoint2:(CGPoint)ctrlPt2 endPoint:(CGPoint)endPt
{
    currentPoint = currentPt
    controlPoint1 = ctrlPt1
    controlPoint2 = ctrlPt2
    endPoint = endPt;
}



@end