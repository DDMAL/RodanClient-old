@import <Foundation/CPObject.j>
@import "../Controllers/ConnectionViewController.j"

JobsTableDragAndDropTableViewDataType = @"JobsTableDragAndDropTableViewDataType";


@implementation DesignerView : CPView
{


    //views for hovering over I/O ports w/ animations
    @outlet     CPView                  infoOutputPortView              @accessors;
    @outlet     CPView                  infoInputPortView               @accessors;

                CPString                infoOutputTypeText;
                CPString                infoInputTypeText;

                CPViewAnimation         inputViewAnimation;
                CPViewAnimation         outputViewAnimation;

                CPEvent                 mouseDownEvent;

                CGRect                  frame;

                //dragging helper variables
                BOOL                    isInView;

    // to draw connections
    @outlet     CPArrayController       connections                     @accessors;


}

- (id)initWithFrame:(CGRect)aFrame
{
    self = [super initWithFrame:aFrame];
    if (self)
    {
        [self setBackgroundColor:[CPColor colorWithHexString:"E8EBF0"]];
        [self registerForDraggedTypes:[CPArray arrayWithObjects:JobsTableDragAndDropTableViewDataType]];

        frame = aFrame;

        //Hover output / input view (inspector)
        outputPortView = [[CPView alloc] initWithFrame:CGRectMake(0, 0, 175, 175)];
        [outputPortView setBackgroundColor:[CPColor colorWithHexString:"FFFFCC"]];
        [self addSubview:outputPortView];
        [outputPortView setHidden:YES];

        outputTypeText = [[CPTextField alloc] initWithFrame:CGRectMake(10, 10, 170, 20)];
        [outputTypeText setStringValue:@"Output Type:"];
        [outputTypeText setHighlighted:YES];
        [outputPortView addSubview:outputTypeText];


        inputPortView = [[CPView alloc] initWithFrame:CGRectMake(0, 0, 175, 175)];
        [inputPortView setBackgroundColor:[CPColor colorWithHexString:"FFFFCC"]];
        [inputTypeText setHighlighted:YES];
        [self addSubview:inputPortView];
        [inputPortView setHidden:YES];

        inputTypeText = [[CPTextField alloc] initWithFrame:CGRectMake(10, 10, 170, 20)];
        [inputTypeText setStringValue:@"Input Type:"];

        [inputPortView addSubview:inputTypeText];

        [self setNeedsDisplay:YES];
    }

    return self;
}

//DRAWING LINKS (LINES)
- (void)drawRect:(CGRect)aRect
{
    var i,
        connectionContentArray = [connections contentArray],
        loopCount = [connectionContentArray count];

    for (i = 0; i < loopCount; i++)
    {

        //draw all links in the link array
        if (connectionContentArray[i] != null)
        {
            connectionContentArray[i].pathAToB = [[CPBezierPath alloc] init];

            var context = [[CPGraphicsContext currentContext] graphicsPort],
                shadowColor = [CPColor colorWithCalibratedWhite:1 alpha:1];

            CGContextSetFillColor(context, [CPColor colorWithCalibratedWhite:0.9 alpha:1.0]);

            CGContextSetShadowWithColor(context, CGSizeMake(1, 1), 0, shadowColor);
            CGContextSetStrokeColor(context, [CPColor blackColor]);

            [connectionContentArray[i].pathAToB moveToPoint:connectionContentArray[i].startPoint];
            [connectionContentArray[i].pathAToB setLineWidth:2.0];

            [connectionContentArray[i].pathAToB curveToPoint:connectionContentArray[i].endPoint controlPoint1:connectionContentArray[i].controlPoint1 controlPoint2:connectionContentArray[i].controlPoint2];


            [connectionContentArray[i].pathAToB stroke];
            [self setNeedsDisplay:YES];
        }
    };

}




- (void)mouseDown:(CPEvent)anEvent
{
    console.log("DOWN - WorkflowDesigner");
    mouseDownEvent = anEvent;
}

- (void)mouseUp:(CPEvent)anEvent
{
    [[CPNotificationCenter defaultCenter] postNotificationName:@"RefreshScrollView" object:nil];
}

- (void)performDragOperation:(CPDraggingInfo)aSender
{
    [[CPNotificationCenter defaultCenter] postNotificationName:@"DesignerViewPerformedDragOperationNotification" object:aSender];
}

- (void)draggingEntered:(CPDraggingInfo)aSender
{
    [[CPNotificationCenter defaultCenter] postNotificationName:@"DesignerViewDraggingEnteredNotification" object:aSender];
}

- (void)draggingExited:(CPDraggingInfo)aSender
{
    [[CPNotificationCenter defaultCenter] postNotificationName:@"DesignerViewDraggingExitedNotification" object:aSender];
}

- (void)draggingUpdated:(CPDraggingInfo)aSender
{
    [[CPNotificationCenter defaultCenter] postNotificationName:@"DesignerViewDraggingUpdatedNotification" object:aSender];
}

@end


