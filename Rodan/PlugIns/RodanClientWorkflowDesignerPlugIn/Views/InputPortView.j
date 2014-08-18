@import <Foundation/CPObject.j>

@import "../Controllers/InputPortViewController.j"

var DEFAULT_SIZE = 10.0;

@implementation InputPortView : CPView
{
    CPBox                       input                       @accessors;
    CGPoint                     inputEnd                    @accessors;

    CGRect                      frame                       @accessors;
    CGSize                      boxSize                     @accessors;
    float                       inputSection                @accessors;

    //associated controller
    InputPortViewController     inputPortViewController     @accessors;
}

- (id)initWithPoint:(CGPoint)aPoint size:(CGSize)aSize subsection:(float)subsection iteration:(int)i inputPortViewControllerRef:(InputPortViewController)aViewController
{

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
        inputPortViewController = aViewController;

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
- (void)mouseEntered:(CPEvent)anEvent
{
    [[CPNotificationCenter defaultCenter] postNotificationName:@"MouseEnteredInputNotification" object:inputPortViewController userInfo:[[CPDictionary alloc] initWithObjects:[anEvent] forKeys:[@"event"]]];
    [self changeBoxAttributes:0.75 cornerRadius:1.0 fillColor:[CPColor colorWithHexString:"FF9933"] boxType:CPBoxOldStyle];
}

- (void)mouseExited:(CPEvent)anEvent
{
    [[CPNotificationCenter defaultCenter] postNotificationName:@"MouseExitedInputNotification" object:inputPortViewController userInfo:[[CPDictionary alloc] initWithObjects:[anEvent] forKeys:[@"event"]]];
    [self changeBoxAttributes:0.75 cornerRadius:1.0 fillColor:[CPColor colorWithHexString:"FF4D4D"] boxType:CPBoxOldStyle];

}

// -----------------------------------------------------//

@end

