@import <Foundation/CPObject.j>

//import models
@import <RodanKit/OutputPort.j>

//output default size
var DEFAULT_SIZE = 10.0;

@implementation OutputPortView : CPView
{
    //info properties
    BOOL        isUsed          @accessors;
    CPString    outputPortType  @accessors;
    CPBox       output          @accessors;

    //box properties
    CGSize      boxSize         @accessors;
    float       outputSection   @accessors;


    int         outputID        @accessors;
    CPUInteger  workflowJobID   @accessors;
    CPUInteger  resourceListID  @accessors;
    CGPoint     outputStart     @accessors;
    CGRect      frame           @accessors;

    CPUInteger  linkRef         @accessors;

    OutputPort  oPort           @accessors;

}

- (id)init:(CGPoint)aPoint size:(CGSize)aSize type:(CPString)type subsection:(float)subsection iteration:(int)i workflowJobID:(CPUInteger)aWorkflowJobID resourceListID:(CPUInteger)aListRef
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
        isUsed = false;
        outputPortType = type;
        outputID = i;
        workflowJobID = aWorkflowJobID;
        resourceListID = aListRef;

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
// ---------------ACTION METHODS ------------------ //

- (void)mouseDown:(CPEvent)anEvent
{
    [[CPNotificationCenter defaultCenter] postNotificationName:@"AddLinkToViewNotification" object:nil userInfo:[[CPDictionary alloc] initWithObjects:[workflowJobID, outputID, anEvent, resourceListID] forKeys:[@"workflow_number", @"output_number", @"event", @"resource_list_number"]]];
    [self setNeedsDisplay:YES];
}

- (void)mouseDragged:(CPEvent)anEvent
{
    [[CPNotificationCenter defaultCenter] postNotificationName:@"LinkIsBeingDraggedNotification" object:nil userInfo:[[CPDictionary alloc] initWithObjects:[workflowJobID, outputID, anEvent, resourceListID, linkRef, isUsed] forKeys:[@"workflow_number", @"output_number", @"event", @"resource_list_number", @"link_ref", @"is_used"]]];
    [self setNeedsDisplay:YES];
}

- (void)mouseUp:(CPEvent)anEvent
{
    [[CPNotificationCenter defaultCenter] postNotificationName:@"ReleaseLinkNotification" object:nil userInfo:[[CPDictionary alloc] initWithObjects:[workflowJobID, outputID, anEvent, resourceListID] forKeys:[@"workflow_number", @"output_number", @"event", @"resource_list_number"]]];
    [self setNeedsDisplay:YES];
}

//NOTE: must put more properties into userInof for Entered and Exited to display output port info
- (void)mouseEntered:(CPEvent)anEvent
{
    [[CPNotificationCenter defaultCenter] postNotificationName:@"MouseEnteredOutputNotification" object:nil userInfo:[[CPDictionary alloc] initWithObjects:[workflowJobID, outputID, anEvent, outputPortType] forKeys:[@"workflow_number", @"output_number", @"event", @"output_type"]]];
    [self changeBoxAttributes:0.75 cornerRadius:1.0 fillColor:[CPColor colorWithHexString:"FF9933"] boxType:CPBoxOldStyle];
}

- (void)mouseExited:(CPEvent)anEvent
{
    [[CPNotificationCenter defaultCenter] postNotificationName:@"MouseExitedOutputNotification" object:nil userInfo:[[CPDictionary alloc] initWithObjects:[workflowJobID, outputID, anEvent] forKeys:[@"workflow_number", @"output_number", @"event"]]];
    [self changeBoxAttributes:0.75 cornerRadius:1.0 fillColor:[CPColor colorWithHexString:"003366"] boxType:CPBoxOldStyle];

}

// ------------------------------------------------- //

@end

