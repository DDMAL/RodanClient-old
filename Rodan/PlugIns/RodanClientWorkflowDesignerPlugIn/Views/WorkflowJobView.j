@import <Foundation/CPObject.j>
@import "../Controllers/WorkflowJobViewController.j"


var PORT_SIZE = 8.5,
    LENGTH = 40.0,
    WIDTH = 100.0;

@implementation WorkflowJobView : CPView
{
    //associated controller
    WorkflowJobViewController   workflowJobViewController       @accessors;

    CPBox                       workflowJob                     @accessors;
    CGRect                      workflowJobSize                 @accessors;

    CPBundle                    theBundle;

    CGPoint                     dragLocation;
    CPEvent                     mouseDownEvent;

    CPDictionary                info                            @accessors;
    BOOL                        firstResponder                  @accessors;

    CPButton                    attributesButton                @accessors;

}

- (id)initWithPoint:(CGPoint)aPoint withInitialPortNumber:(CPInteger)aPortNumber workflowJobControllerRef:(WorkflowJobViewController)aViewController
{


    if (aPortNumber == 0 || aPortNumber == 1)
        workflowJobSize = CGSizeMake(LENGTH + 20, WIDTH);
    else
        workflowJobSize = CGSizeMake(aPortNumber * LENGTH, WIDTH);

    var aRect = CGRectMake(aPoint.x, aPoint.y, workflowJobSize.height, workflowJobSize.width),
        viewRect = CGRectMake(aPoint.x - PORT_SIZE, aPoint.y, workflowJobSize.height + PORT_SIZE * 2, workflowJobSize.width);

    self = [super initWithFrame:aRect];

    if (self)
    {
        //set reference to associated controller
        workflowJobViewController = aViewController;


        workflowJob = [[CPBox alloc] initWithFrame:aRect];
        refNumber = aNumber;

        [self changeBoxAttributes:1.0 cornerRadius:15.0 fillColor:[CPColor colorWithHexString:"E6E6E6"] boxType:CPBoxPrimary title:"Border Crop"];

        theBundle = [CPBundle bundleWithPath:@"PlugIns/RodanClientWorkflowDesignerPlugIn/Views/"];

        var plusImage = [[CPImage alloc] initWithContentsOfFile:[theBundle pathForResource:@"plus.png"] size:CGSizeMake(7.5, 7.5)];

        // ------ attributes button to access WorkflowJob Settings
        attributesButton = [[CPButton alloc] initWithFrame:CGRectMake(15.0, 2.2, 7.5, 7.5)];
        [attributesButton setBezelStyle:CPTexturedRoundedBezelStyle];

        [attributesButton setImage:plusImage];
        [attributesButton sizeToFit];
        [attributesButton setBordered:NO];

        [attributesButton setAction:@selector(viewAttributes:)];
        [attributesButton setTarget:self];

        // ------------------------------------------------------ //

        [self addSubview:workflowJob];
        [self setBounds:aRect];
        [self addSubview:attributesButton];

    }

    return self;
}


- (void)changeBoxAttributes:(float)borderWidth cornerRadius:(float)cornerRadius fillColor:(CPColor)aColor boxType:(CPBoxType)aType title:(CPString)aTitle
{
        [workflowJob setBorderWidth:borderWidth];
        [workflowJob setCornerRadius:cornerRadius];
        [workflowJob setFillColor:aColor];
        [workflowJob setBoxType:aType];
        [workflowJob setTitle:aTitle];
        [workflowJob setBorderColor:[CPColor colorWithHexString:"999999"]];
        // [workflowJob setTitlePosition:6];
}


// ------------------- ACTION METHODS ------------------------ //
- (void)mouseDragged:(CPEvent)anEvent
{
    console.log("DRAG - WorkflowJob");
    [[CPNotificationCenter defaultCenter] postNotificationName:@"WorkflowJobViewIsBeingDraggedNotification" object:workflowJobViewController userInfo:[[CPDictionary alloc] initWithObjects:[anEvent] forKeys:[@"event"]]];
}

- (void)mouseDown:(CPEvent)anEvent
{
    console.log("DOWN -  WorkflowJob");

    dragLocation = [anEvent locationInWindow];
    mouseDownEvent = anEvent;
    [[CPNotificationCenter defaultCenter] postNotificationName:@"WorkflowJobIsBeingSelectedNotification" object:workflowJobViewController];

    //for key down events
    [[self window] makeFirstResponder:self];

}

- (void)mouseUp:(CPEvent)anEvent
{
    [[CPNotificationCenter defaultCenter] postNotificationName:@"RefreshScrollView" object:nil];
}

- (void)viewAttributes:(id)aSender
{
    // alert("Workflow Job Attributes");
    console.log("Workflow Job Attributes");
}

- (void)mouseEntered:(CPEvent)anEvent
{
    [workflowJob setBorderColor:[CPColor colorWithHexString:"FF9933"]];
    [workflowJob setBorderWidth:1.5];
}

- (void)mouseExited:(CPEvent)anEvent
{
    if (!firstResponder)
    {
        [workflowJob setBorderColor:[CPColor colorWithHexString:"999999"]];
        [workflowJob setBorderWidth:1.0];
    }
}

//key down events - (delete function)
- (BOOL)acceptsFirstResponder
{
    firstResponder = YES;
    return YES;
}

- (BOOL)resignFirstResponder
{
    [workflowJob setBorderColor:[CPColor colorWithHexString:"999999"]];
    [workflowJob setBorderWidth:1.0];

    firstResponder = NO;
    return YES;
}

- (void)keyDown:(CPEvent)anEvent
{
    var key = [[anEvent charactersIgnoringModifiers] characterAtIndex:0];
    if (key == CPDeleteCharacter)
    {
        [[CPNotificationCenter defaultCenter] postNotificationName:@"WorkflowJobIsBeingDeletedNotification" object:workflowJobViewController];
    }
}
// ------------------------------------------------------------ //


@end
