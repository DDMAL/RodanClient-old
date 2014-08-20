@import <Foundation/CPObject.j>
@import <AppKit/CPWindowController.j>

@import "InputPortView.j"
@import "OutputPortView.j"
@import <RodanKit/RodanKit.j>
@import <RodanKit/WorkflowJob.j>

var PORT_SIZE = 8.5,
    LENGTH = 40.0,
    WIDTH = 100.0;

@implementation WorkflowJobViewOld : CPView
{
    CPBox                   workflowJob                     @accessors;
    CPUInteger              outputPortNumber                @accessors;
    CPUInteger              inputPortNumber                 @accessors;

    CPArray                 inputPorts                      @accessors;
    CPArray                 outputPorts                     @accessors;

    CPBundle                theBundle;
    CPUInteger              refNumber                       @accessors;
    CPString                type                            @accessors;

    CGPoint                 dragLocation;
    CPEvent                 mouseDownEvent;

    CPDictionary            info                            @accessors;
    BOOL                    firstResponder                  @accessors;

    WorkflowJob             wkJob                           @accessors;

    CPButton                attributesButton                @accessors;
}

- (id)initWithPoint:(CGPoint)aPoint job:(CPObject)aJob refNumber:(CPUInteger)aNumber
{
    var inputPortTypes = [aJob inputPortTypes],
        outputPortTypes = [aJob outputPortTypes],

        totalOutputNum = 0,
        totalInputNum = 0,
        maxPortMeasurement = 0,
        aSize,

        jobType = aJob.jobType;

    firstResponder = NO;

        //NOTE: using minimum for defuault instance
    for (var i = 0; i < [inputPortTypes count]; i++)
        totalInputNum += inputPortTypes[i].minimum;

    for (i = 0; i < [outputPortTypes count]; i++)
      totalOutputNum += outputPortTypes[i].minimum;

    console.log(aJob);

    outputPortNumber = totalOutputNum;
    inputPortNumber = totalInputNum;

    if (totalOutputNum > totalInputNum)
        maxPortMeasurement = totalOutputNum;
    else
        maxPortMeasurement = totalInputNum;

    if (maxPortMeasurement == 0 || maxPortMeasurement == 1)
        aSize = CGSizeMake(LENGTH + 20, WIDTH);
    else
        aSize = CGSizeMake(maxPortMeasurement * LENGTH, WIDTH);

    var aRect = CGRectMake(aPoint.x, aPoint.y, aSize.height, aSize.width),
        viewRect = CGRectMake(aPoint.x - PORT_SIZE, aPoint.y, aSize.height + PORT_SIZE * 2, aSize.width);

    self = [super initWithFrame:aRect];

    if (self)
    {
        workflowJob = [[CPBox alloc] initWithFrame:aRect];
        refNumber = aNumber;

        theBundle = [CPBundle bundleWithPath:@"PlugIns/RodanClientWorkflowDesignerPlugIn/"];

        type = jobType;
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



        // -------------- I/O implementation ------------------- //
        var subsection,
            resourceType;

        //init outputPortsController --
        subsection = (aSize.width / totalOutputNum);
        outputPorts = [[CPArray alloc] init];

        var counter = 0,
            outputLoop = [outputPortTypes count],
            inputLoop = [inputPortTypes count];

        for (var i = 0; i < outputLoop; i++)
        {
            for (var k = 0; k < [outputPortTypes[i].minimum]; k++)
            {
                resourceType = [outputPortTypes[i].resourceType];
                outputPorts[counter] = [[OutputPortView alloc] init:aPoint
                                                               size:aSize
                                                               type:resourceType
                                                         subsection:subsection
                                                          iteration:counter
                                                      workflowJobID:refNumber
                                                     resourceListID:-1];
                counter++;
            };
        };


        //init inputPortsController --
        inputPorts = [[CPArray alloc] init];
        subsection = (aSize.width / totalInputNum);

        counter = 0;
        for (i = 0; i < inputLoop; i++)
        {
            for (k = 0; k < [inputPortTypes[i].minimum]; k++)
            {
                resourceType = [inputPortTypes[i].resourceType];
                inputPorts[counter] = [[InputPortView alloc] init:aPoint size:aSize type:resourceType subsection:subsection iteration:counter workflowJobID:refNumber];
                counter++;
            };
        };

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
    [[CPNotificationCenter defaultCenter] postNotificationName:@"WorkflowJobViewIsBeingDraggedNotification" object:nil userInfo:[[CPDictionary alloc] initWithObjects:[refNumber, anEvent] forKeys:[@"workflow_number",@"event"]]];
}

- (void)mouseDown:(CPEvent)anEvent
{
    console.log("DOWN -  WorkflowJob");

    dragLocation = [anEvent locationInWindow];
    mouseDownEvent = anEvent;
    [[CPNotificationCenter defaultCenter] postNotificationName:@"WorkflowJobIsBeingSelectedNotification" object:nil userInfo:[[CPDictionary alloc] initWithObjects:[refNumber] forKeys:[@"workflow_number"]]];

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
        [[CPNotificationCenter defaultCenter] postNotificationName:@"WorkflowJobIsBeingDeletedNotification" object:nil userInfo:[[CPDictionary alloc] initWithObjects:[refNumber] forKeys:[@"workflow_number"]]];
    }
}
// ------------------------------------------------------------ //


@end




// @implementation CPView (logClickCount)

// - (void)mouseDown:(CPEvent)anEvent
// {
// // `.log(_cmd + " clickCount=" + [anEvent clickCount]);
// console.log(self);
//     if ([self mouseDownCanMoveWindow])
//         [super mouseDown:anEvent];
// }
// @end