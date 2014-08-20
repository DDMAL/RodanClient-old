@import <Foundation/CPObject.j>
@import <RodanKit/InputPort.j>

var DEFAULT_SIZE = 10.0;

@implementation InputPortViewOld : CPView
{
    //info properties
    BOOL        isUsed          @accessors;
    CPString    inputType       @accessors;
    CPBox       input           @accessors;

    int         inputID         @accessors;
    CPUInteger  workflowJobID   @accessors;
    CGPoint     inputEnd        @accessors;

    CGRect      frame           @accessors;
    CGSize      boxSize         @accessors;
    float       inputSection    @accessors;

    CPUInteger  linkRef         @accessors;

    InputPort   iPort           @accessors;
}

- (id)init:(CGPoint)aPoint size:(CGSize)aSize type:(CPString)type subsection:(float)subsection iteration:(int)i workflowJobID:(CPUInteger)aWorkflowJobID
{
    //TO DO: Must instanstiate Input model on server side

    boxSize = aSize;
    inputSection = subsection;

    var pointX = aPoint.x - DEFAULT_SIZE,
        pointY = aPoint.y + inputSection * (i + 1) - (inputSection / 2) - DEFAULT_SIZE;
    frame = CGRectMake(pointX, pointY, DEFAULT_SIZE, DEFAULT_SIZE);
    inputEnd = CGPointMake(pointX, pointY + (DEFAULT_SIZE / 2));

    self = [super initWithFrame:frame];

    if (self)
    {
        input = [[CPBox alloc] initWithFrame:frame];
        isUsed = false;
        inputType = type;
        inputID = i;
        workflowJobID = aWorkflowJobID;

        [self changeBoxAttributes:0.75 cornerRadius:1.0 fillColor:[CPColor colorWithHexString:"FF4D4D"] boxType:CPBoxOldStyle];

        [self addSubview:input];
        [self setBounds:frame];
    }
    return self;
}

// ----------------- LOCAL METHODS ----------------- //
- (void)arrangeInputPosition:(CGPoint)aPoint iteration:(int)i
{
    var pointX = aPoint.x - DEFAULT_SIZE,
        pointY = aPoint.y + inputSection * (i + 1) - (inputSection / 2) - DEFAULT_SIZE;
    frame = CGRectMake(pointX, pointY, DEFAULT_SIZE, DEFAULT_SIZE);
    inputEnd = CGPointMake(pointX, pointY + (DEFAULT_SIZE / 2));

    [self setFrameOrigin:frame.origin];
}



- (void)changeBoxAttributes:(float)borderWidth cornerRadius:(float)cornerRadius fillColor:(CPColor)aColor boxType:(CPBoxType)type
{
        [input setBorderWidth:borderWidth];
        [input setCornerRadius:cornerRadius];
        [input setFillColor:aColor];
        [input setBoxType:type];

}


// ------------------- ACTION METHODS ----------------- //
//note must add more info to dictionary for input properties when creating link
- (void)mouseEntered:(CPEvent)anEvent
{
    [[CPNotificationCenter defaultCenter] postNotificationName:@"MouseEnteredInputNotification" object:nil userInfo:[[CPDictionary alloc] initWithObjects:[workflowJobID, inputID, anEvent, inputType] forKeys:[@"workflow_number", @"input_number", @"event", @"input_type"]]];
    [self changeBoxAttributes:0.75 cornerRadius:1.0 fillColor:[CPColor colorWithHexString:"FF9933"] boxType:CPBoxOldStyle];
}

- (void)mouseExited:(CPEvent)anEvent
{
    [[CPNotificationCenter defaultCenter] postNotificationName:@"MouseExitedInputNotification" object:nil userInfo:[[CPDictionary alloc] initWithObjects:[workflowJobID, inputID, anEvent] forKeys:[@"workflow_number", @"input_number", @"event"]]];
    [self changeBoxAttributes:0.75 cornerRadius:1.0 fillColor:[CPColor colorWithHexString:"FF4D4D"] boxType:CPBoxOldStyle];

}

// -----------------------------------------------------//

@end

