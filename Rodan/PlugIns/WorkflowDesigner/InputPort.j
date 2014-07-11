@import <Foundation/CPObject.j>

@implementation InputPort : CPView
{
    BOOL        isUsed          @accessors;
    CPString    inputType       @accessors;
    CPBox       input           @accessors;
    int         jobID           @accessors;
    CPUInteger  workflowJobID   @accessors;
    CGPoint     inputEnd        @accessors;

    int         linkIndex       @accessors;

}

- (id)init:(CGPoint)aPoint length:(float)theLength width:(float)theWidth type:(CPString)type subsection:(float)subsection iteration:(int)i jobID:(int)aJobID workflowJobID:(CPUInteger)aWorkflowJobID
{
    var length = 8.5,
        width = 8.5,
        pointX = aPoint.x - length,
        pointY = aPoint.y + subsection*i - (subsection / 2) - length;

    var aRect = CGRectMake(pointX, pointY, length, width);
    self = [super initWithFrame:aRect];

    inputEnd = CGPointMake(pointX, pointY + (length /2));


    if (self) 
    {

        input = [[CPBox alloc] initWithFrame:aRect];
        isUsed = false;
        inputType = type;
        jobID = aJobID;
        workflowJobID = aWorkflowJobID;

        [self changeBoxAttributes:0.75 cornerRadius:1.0 fillColor:[CPColor colorWithHexString:"FF4D4D"] boxType:CPBoxOldStyle];

        [self addSubview:input];
        [self setBounds:aRect];
    }
    // [self setNeedsDisplay:true];
    return self;
}


- (void)changeBoxAttributes:(float)borderWidth cornerRadius:(float)cornerRadius fillColor:(CPColor)aColor boxType:(CPBoxType)type 
{
        [input setBorderWidth:borderWidth];
        [input setCornerRadius:cornerRadius];
        [input setFillColor:aColor];
        [input setBoxType:type];

}

//NOTE: must put more properties into userInof for Entered and Exited to display input port info
- (void)mouseEntered:(CPEvent)anEvent
{
    [[CPNotificationCenter defaultCenter] postNotificationName:@"EnteredInput" object:nil userInfo:[[CPDictionary alloc] initWithObjects:[workflowJobID, jobID] forKeys:[@"workflow_number", @"input_number"]]];
    [self changeBoxAttributes:0.75 cornerRadius:1.0 fillColor:[CPColor colorWithHexString:"FF9933"] boxType:CPBoxOldStyle];   
}

- (void)mouseExited:(CPEvent)anEvent
{
    [[CPNotificationCenter defaultCenter] postNotificationName:@"ExitedInput" object:nil userInfo:[[CPDictionary alloc] initWithObjects:[workflowJobID, jobID] forKeys:[@"workflow_number", @"input_number"]]];
    [self changeBoxAttributes:0.75 cornerRadius:1.0 fillColor:[CPColor colorWithHexString:"003366"] boxType:CPBoxOldStyle];

}

@end

