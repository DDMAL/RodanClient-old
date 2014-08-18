@import <Foundation/CPObject.j>

@import "../Controllers/OutputPortViewController.j"

var DEFAULT_SIZE = 10.0;

@implementation OutputPortView : CPView
{
    CPBox                       output                      @accessors;
    CGPoint                     outputStart                 @accessors;

    CGRect                      frame                       @accessors;
    CGSize                      boxSize                     @accessors;
    float                       outputSection               @accessors;

    //associated controller
    OutputPortViewController    outputPortViewController    @accessors;

}

- (id)initWithPoint:(CGPoint)aPoint size:(CGSize)aSize type:(CPString)type subsection:(float)subsection iteration:(int)i outputPortViewControllerRef:(OutputPortViewController)aViewController
{
    boxSize = aSize;
    outputSection = subsection;

    var pointX = aPoint.x + boxSize.height,
        pointY = aPoint.y + outputSection * (i + 1) - (outputSection / 2) - DEFAULT_SIZE;
    frame = CGRectMake(pointX, pointY, DEFAULT_SIZE, DEFAULT_SIZE);
    outputStart = CGPointMake(pointX + DEFAULT_SIZE, pointY + (DEFAULT_SIZE / 2));

    self = [super initWithFrame:frame];

    if (self)
    {
        output = [[CPBox alloc] initWithFrame:frame];
        outputPortViewController = aViewController;

        [self changeBoxAttributes:0.75 cornerRadius:1.0 fillColor:[CPColor colorWithHexString:"003366"] boxType:CPBoxOldStyle];

        [self addSubview:output];
        [self setBounds:frame];
    }
    return self;
}

//-------------- LOCAL METHODS ------------------- //
- (void)arrangeOutputPosition:(CGPoint)aPoint iteration:(int)i
{
    var pointX = aPoint.x + boxSize.height,
        pointY = aPoint.y + outputSection * (i + 1) - (outputSection / 2) - DEFAULT_SIZE;
    frame = CGRectMake(pointX, pointY, DEFAULT_SIZE, DEFAULT_SIZE);
    outputStart = CGPointMake(pointX + DEFAULT_SIZE, pointY + (DEFAULT_SIZE / 2));

    [self setFrameOrigin:frame.origin];
}



- (void)changeBoxAttributes:(float)borderWidth cornerRadius:(float)cornerRadius fillColor:(CPColor)aColor boxType:(CPBoxType)type
{
        [output setBorderWidth:borderWidth];
        [output setCornerRadius:cornerRadius];
        [output setFillColor:aColor];
        [output setBoxType:type];
}


//////////////////////////////////////////////////////
// ---------------ACTION METHODS ------------------ //
//////////////////////////////////////////////////////


- (void)mouseDown:(CPEvent)anEvent
{
    [[CPNotificationCenter defaultCenter] postNotificationName:@"AddLinkToViewNotification" object:outputPortViewController userInfo:[[CPDictionary alloc] initWithObjects:[anEvent] forKeys:[@"event"]]];
    [self setNeedsDisplay:YES];
}

- (void)mouseDragged:(CPEvent)anEvent
{
    [[CPNotificationCenter defaultCenter] postNotificationName:@"LinkIsBeingDraggedNotification" object:outputPortViewController userInfo:[[CPDictionary alloc] initWithObjects:[anEvent] forKeys:[@"event"]]];
    [self setNeedsDisplay:YES];
}

- (void)mouseUp:(CPEvent)anEvent
{
    [[CPNotificationCenter defaultCenter] postNotificationName:@"ReleaseLinkNotification" object:outputPortViewController userInfo:[[CPDictionary alloc] initWithObjects:[anEvent] forKeys:[@"event"]]];
    [self setNeedsDisplay:YES];
}

//NOTE: must put more properties into userInof for Entered and Exited to display output port info
- (void)mouseEntered:(CPEvent)anEvent
{
    [[CPNotificationCenter defaultCenter] postNotificationName:@"MouseEnteredOutputNotification" object:outputPortViewController userInfo:[[CPDictionary alloc] initWithObjects:[anEvent] forKeys:[@"event"]]];
    [self changeBoxAttributes:0.75 cornerRadius:1.0 fillColor:[CPColor colorWithHexString:"FF9933"] boxType:CPBoxOldStyle];
}

- (void)mouseExited:(CPEvent)anEvent
{
    [[CPNotificationCenter defaultCenter] postNotificationName:@"MouseExitedOutputNotification" object:outputPortViewController userInfo:[[CPDictionary alloc] initWithObjects:[anEvent] forKeys:[@"event"]]];
    [self changeBoxAttributes:0.75 cornerRadius:1.0 fillColor:[CPColor colorWithHexString:"003366"] boxType:CPBoxOldStyle];

}

// ------------------------------------------------- //

@end

