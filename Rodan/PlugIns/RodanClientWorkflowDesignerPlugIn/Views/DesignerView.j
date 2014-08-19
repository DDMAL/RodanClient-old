@import <Foundation/CPObject.j>
@import "../Controllers/ConnectionViewController.j"

JobsTableDragAndDropTableViewDataType = @"JobsTableDragAndDropTableViewDataType";


@implementation DesignerView : CPView
{
                DesignerViewController  designerViewController          @accessors;

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
    if (self = [super initWithFrame:aFrame])
    {
        [self setBackgroundColor:[CPColor colorWithHexString:"E8EBF0"]];
        [self registerForDraggedTypes:[CPArray arrayWithObjects:JobsTableDragAndDropTableViewDataType]];

        frame = aFrame;

        //Hover output / input view (inspector)
        infoOutputPortView = [[CPView alloc] initWithFrame:CGRectMake(0, 0, 175, 175)];
        [infoOutputPortView setBackgroundColor:[CPColor colorWithHexString:"FFFFCC"]];
        [self addSubview:infoOutputPortView];
        [infoOutputPortView setHidden:YES];

        infoOutputTypeText = [[CPTextField alloc] initWithFrame:CGRectMake(10, 10, 170, 20)];
        [infoOutputTypeText setStringValue:@"Output Type:"];
        [infoOutputTypeText setHighlighted:YES];
        [infoOutputPortView addSubview:infoOutputTypeText];


        infoInputPortView = [[CPView alloc] initWithFrame:CGRectMake(0, 0, 175, 175)];
        [infoInputPortView setBackgroundColor:[CPColor colorWithHexString:"FFFFCC"]];
        [infoInputTypeText setHighlighted:YES];
        [self addSubview:infoInputPortView];
        [infoInputPortView setHidden:YES];

        infoInputTypeText = [[CPTextField alloc] initWithFrame:CGRectMake(10, 10, 170, 20)];
        [infoInputTypeText setStringValue:@"Input Type:"];

        [infoInputPortView addSubview:infoInputTypeText];

        [self setNeedsDisplay:YES];
    }

    return self;
}

//DRAWING LINKS (LINES)
- (void)drawRect:(CGRect)aRect
{
    var connectionContentArray = [connections contentArray],
        loopCount = [connectionContentArray count];

    for (var i = 0; i < loopCount; i++)
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
    [designerViewController hasPerformedDraggingOperation:aSender];
}

- (void)draggingEntered:(CPDraggingInfo)aSender
{
    [designerViewController draggingHasEntered:aSender];
}

- (void)draggingExited:(CPDraggingInfo)aSender
{
    [designerViewController draggingHasExited:aSender];
}

- (void)draggingUpdated:(CPDraggingInfo)aSender
{
    [designerViewController draggingHasUpdated:aSender];
}

@end


