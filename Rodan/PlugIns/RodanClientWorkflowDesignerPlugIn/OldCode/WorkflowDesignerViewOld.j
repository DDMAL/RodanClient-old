@import <Foundation/CPObject.j>

@import "WorkflowJobView.j"
@import "Link.j"
@import "OutputPortView.j"
@import "ResourceList.j"
@import <RodanKit/WorkflowController.j>
@import <RodanKit/WorkflowJob.j> //to create JSON workflowJob model
@import <RodanKit/Workflow.j>
@import <RodanKit/Connection.j>

@import "DeleteCache.j"

@import "JobsTableController.j"

JobsTableDragAndDropTableViewDataType = @"JobsTableDragAndDropTableViewDataType";

@global RodanDidLoadWorkflowNotification
@global RodanModelCreatedNotification


@implementation WorkflowDesignerViewOld : CPView
{
    //graphical objects
    @outlet     CPArrayController       workflowJobs                @accessors;
    @outlet     CPArrayController       links                       @accessors;
    @outlet     CPArrayController       resourceLists               @accessors;

                CPArray                 linksContentArray           @accessors;
                CPArray                 workflowJobsContentArray    @accessors;
                CPArray                 resourceListsContentArray   @accessors;

    //views for hovering over I/O ports w/ animations
    @outlet     CPView                  outputPortView              @accessors;
    @outlet     CPView                  inputPortView               @accessors;

                CPViewAnimation         inputViewAnimation;
                CPViewAnimation         outputViewAnimation;

                CPArray                 currentInputHover; //array, pos. 0 = workflowJob, pos. 1 = inputNumber

                CPEvent                 mouseDownEvent;

                CPString                outputTypeText;
                CPString                inputTypeText;

                CGRect                  frame;

                //dragging helper variables
                BOOL                    isInView;
                CPInteger               currentDraggingIndex;


                //variables to reference graphical <-> server objects
                CPInteger               creatingWorkflowJobIndex;
                CPDictionary            creatingWorkflowJobIOTypes;
                CPInteger               createInputPortsCounter;
                CPInteger               createOutputPortsCounter;
                CPInteger               connectionModelReference;

    @outlet     CPArrayController       jobArrayController;
    @outlet     CPArrayController       connectionArrayController;

                WorklfowController      workflowController;
    @outlet     Workflow                currentWorkflow;
                BOOL                    isCurrentSelection;

                DeleteCache             cacheToDelete               @accessors;

    @outlet     WorkflowJobController   workflowJobController       @accessors;
    @outlet     OutputPortController    outputPortController        @accessors;
    @outlet     InputPortController     inputPortController         @accessors;
    @outlet     ConnectionController    connectionController        @accessors;


}

- (id)initDesignerWithFrame:(CGRect)aFrame
{
    self = [super initWithFrame:aFrame];
    if (self)
    {
        workflowController = [[CPApplication sharedApplication] delegate].workflowController;
        currentWorkflow = workflowController.currentWorkflow;

        [self setBackgroundColor:[CPColor colorWithHexString:"E8EBF0"]];
        [self registerForDraggedTypes:[CPArray arrayWithObjects:JobsTableDragAndDropTableViewDataType]];

        workflowJobs = [[CPArrayController alloc] init];
        links = [[CPArrayController alloc] init];
        resourceLists = [[CPArrayController alloc] init];

        linksContentArray = [links contentArray];
        workflowJobsContentArray = [workflowJobs contentArray];
        resourceListsContentArray = [resourceLists contentArray];


        frame = aFrame;
        isCurrentSelection = NO;
        currentDraggingIndex = -1;
        creatingWorkflowJobIndex = -1;
        creatingWorkflowJobIOTypes = [[CPDictionary alloc] init];

        connectionArrayController = [[CPArrayController alloc] init];

        cacheToDelete = [[DeleteCache alloc] init];

        jobArrayController = [[CPArray alloc] init];
        jobArrayController = [[CPApplication sharedApplication] delegate].jobController.jobArrayController;

        currentInputHover = [[CPArray alloc] init];
        currentInputHover[0] = -1;
        currentInputHover[1] = -1;



        //key down events for view
        // [[self window] makeFirstResponder:self];

    // ---------------------------------------------------------- //
    // -------- REGISTER NOTIFICATIONS  ------------------------- //

    [[CPNotificationCenter defaultCenter] addObserver:self
                                          selector:@selector(receiveAddLink:)
                                          name:@"AddLinkToViewNotification"
                                          object:nil];

    [[CPNotificationCenter defaultCenter] addObserver:self
                                          selector:@selector(receiveReleaseLink:)
                                          name:@"ReleaseLinkNotification"
                                          object:nil];

    [[CPNotificationCenter defaultCenter] addObserver:self
                                          selector:@selector(receiveDragLink:)
                                          name:@"LinkIsBeingDraggedNotification"
                                          object:nil];

    [[CPNotificationCenter defaultCenter] addObserver:self
                                          selector:@selector(receiveCurrentMouseHover:)
                                          name:@"MouseHoverInViewNotification"
                                          object:nil];


    [[CPNotificationCenter defaultCenter] addObserver:self
                                          selector:@selector(receiveOutputEntered:)
                                          name:@"MouseEnteredOutputNotification"
                                          object:nil];


    [[CPNotificationCenter defaultCenter] addObserver:self
                                          selector:@selector(receiveOutputExited:)
                                          name:@"MouseExitedOutputNotification"
                                          object:nil];

    [[CPNotificationCenter defaultCenter] addObserver:self
                                          selector:@selector(receiveInputEntered:)
                                          name:@"MouseEnteredInputNotification"
                                          object:nil];

    [[CPNotificationCenter defaultCenter] addObserver:self
                                          selector:@selector(receiveInputExited:)
                                          name:@"MouseExitedInputNotification"
                                          object:nil];

    [[CPNotificationCenter defaultCenter] addObserver:self
                                          selector:@selector(receiveWorkflowJobDrag:)
                                          name:@"WorkflowJobViewIsBeingDraggedNotification"
                                          object:nil];

    [[CPNotificationCenter defaultCenter] addObserver:self
                                          selector:@selector(receiveResourceListDrag:)
                                          name:@"ResourceListViewIsBeingDraggedNotification"
                                          object:nil];

    [[CPNotificationCenter defaultCenter] addObserver:self
                                          selector:@selector(receiveDidLoadCurrentWorkflow:)
                                          name:@"RodanDidLoadWorkflowNotification"
                                          object:nil];

    [[CPNotificationCenter defaultCenter] addObserver:self
                                          selector:@selector(receiveDidSelectWorkflowJob:)
                                          name:@"WorkflowJobIsBeingSelectedNotification"
                                          object:nil];

    [[CPNotificationCenter defaultCenter] addObserver:self
                                          selector:@selector(receiveDeleteWorkflow:)
                                          name:@"WorkflowJobIsBeingDeletedNotification"
                                          object:nil];

    [[CPNotificationCenter defaultCenter] addObserver:self
                                          selector:@selector(receiveDeleteResourceList:)
                                          name:@"ResourceListIsBeingDeletedNotification"
                                          object:nil];

    [[CPNotificationCenter defaultCenter] addObserver:self
                                          selector:@selector(receiveNewResourceList:)
                                          name:@"ResourceListIsBeingCreatedNotification"
                                          object:nil];

    [[CPNotificationCenter defaultCenter] addObserver:self
                                          selector:@selector(receiveModelWasCreatedNotification:)
                                          name:RodanModelCreatedNotification
                                          object:nil];

    // ------------------ NOTIFICATIONS END ----------------------------- //
    // ------------------------------------------------------------------- //

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

    // [newResourceListButton setAction:@selector(newResourceListAction:)];
    // [newResourceListButton setTarget:self];

    [self setNeedsDisplay:YES];

    // [self display];
    }

    return self;
}

//DRAWING LINKS (LINES)
- (void)drawRect:(CGRect)aRect
{
    var i,
        loopCount = [[links contentArray] count];

    for (i = 0; i < loopCount; i++)
    {

        //draw all links in the link array
        if (linksContentArray[i] != null)
        {
            linksContentArray[i].pathAToB = [[CPBezierPath alloc] init];

            var context = [[CPGraphicsContext currentContext] graphicsPort],
                shadowColor = [CPColor colorWithCalibratedWhite:1 alpha:1];

            CGContextSetFillColor(context, [CPColor colorWithCalibratedWhite:0.9 alpha:1.0]);

            CGContextSetShadowWithColor(context, CGSizeMake(1, 1), 0, shadowColor);
            CGContextSetStrokeColor(context, [CPColor blackColor]);

            [linksContentArray[i].pathAToB moveToPoint:linksContentArray[i].currentPoint];
            [linksContentArray[i].pathAToB setLineWidth:2.0];

            [linksContentArray[i].pathAToB curveToPoint:linksContentArray[i].endPoint controlPoint1:linksContentArray[i].controlPoint1 controlPoint2:linksContentArray[i].controlPoint2];


            [linksContentArray[i].pathAToB stroke];
            [self setNeedsDisplay:YES];
        }
    };

}

// ---------------------------------------------------------- //
// -------------------- DRAGGING METHODS -------------------- //
// -----------------------------------------------------------//
- (void)mouseDragged:(CPEvent)anEvent
{
    console.log("DRAG - WorkflowDesigner");
}

- (void)performDragOperation:(CPDraggingInfo)aSender
{
    var pboard = [aSender draggingPasteboard],
        content = [jobArrayController arrangedObjects],
        sourceIndexes = [pboard dataForType:JobsTableDragAndDropTableViewDataType],
        job = [content objectAtIndex:[sourceIndexes firstIndex]],

        location = [self convertPoint:[aSender draggingLocation] fromView:nil],

        jobType,
        inputPortTypes = [job inputPortTypes],
        outputPortTypes = [job outputPortTypes];

        //populate dictionary to later create I/O ports for corresponding wkJob
    [creatingWorkflowJobIOTypes setObject:inputPortTypes forKey:@"input_port_types"];
    [creatingWorkflowJobIOTypes setObject:outputPortTypes forKey:@"output_port_types"];

    if (job.isInteractive)
        jobType = 1;
    else
        jobType = 0;

    if (isCurrentSelection) //ensure currentWorkflow has been selected
    {
        //create workflowJob on server
        var wkObject = {
                        "workflow": [currentWorkflow pk],
                        "job": [job pk],
                        "uuid": "",
                        "job_name": [job jobName],
                        "job_type": jobType,
                        "job_description": [job description],
                        "job_settings": [job settings]
                        },

            workflowJobObject = [[WorkflowJob alloc] initWithJson:wkObject];
        [workflowJobObject ensureCreated];

        creatingWorkflowJobIndex = currentDraggingIndex; //to later create I/O ports for workflowJob (asynchronous)
    }

    else
    {
        //if no workflow selected, warn user they must select a workflow
        var alert = [CPAlert alertWithMessageText:@"Must select workflow to create workflowJob"
                                    defaultButton:@"Okay"
                                  alternateButton:nil
                                      otherButton:nil
                        informativeTextWithFormat:nil];

        [alert setDelegate:self];
        [alert runModal];

        [self removeWorkflowJob];
    }

    currentDraggingIndex = -1;
    [self display];
}



- (void)draggingEntered:(CPDraggingInfo)aSender
{
    console.log("Dragging Entered");
    isInView = YES;

    //create view object
    var pboard = [aSender draggingPasteboard],
        content = [jobArrayController arrangedObjects],
        sourceIndexes = [pboard dataForType:JobsTableDragAndDropTableViewDataType],
        aJob = [content objectAtIndex:[sourceIndexes firstIndex]],

        location = [self convertPoint:[aSender draggingLocation] fromView:nil];

    var inputPortTypes = [aJob inputPortTypes],
        outputPortTypes = [aJob outputPortTypes],
        i,
        workflowJobCount = [workflowJobsContentArray count];

    if (aJob != null)
    {
        for (var i = 0; i < workflowJobCount; i++)
            if (workflowJobsContentArray[i] == null)
                break;

        //create views and add to view as subview
        workflowJobsContentArray[i] = [[WorkflowJobView alloc] initWithPoint:location job:aJob refNumber:i];
        [workflowJobsContentArray[i] changeBoxAttributes:1.0 cornerRadius:15.0 fillColor:[CPColor colorWithHexString:"E6E6E6"] boxType:CPBoxPrimary title:"Border Crop"];


        var j,
            outputLoop = [workflowJobsContentArray[i].outputPorts count],
            inputLoop = [workflowJobsContentArray[i].inputPorts count];
        for (var j = 0; j < outputLoop; j++)
            [self addSubview:workflowJobsContentArray[i].outputPorts[j]];

        for (var k = 0; k < inputLoop; k++)
            [self addSubview:workflowJobsContentArray[i].inputPorts[k]];

        [self addSubview:workflowJobsContentArray[i]];
        currentDraggingIndex = i;
    }
}

- (void)draggingExited:(CPDraggingInfo)aSender
{
    console.log("Dragging Exited");
    isInView = NO;

    //remove workflowJob if dragging has entered
    [self removeWorkflowJob];

}

- (void)draggingUpdated:(CPDraggingInfo)aSender
{
    console.log("Dragging Updated");
    var currentMouseLocation = [self convertPoint:[aSender draggingLocation] fromView:nil];

    [self workflowJobDrag:currentDraggingIndex mouseLocation:currentMouseLocation];
    [self display];
}
// ---------------------------------------------------------------------- //
// -------------------------- END DRAGGING METHODS ----------------------- //
// ---------------------------------------------------------------------- //


- (void)mouseDown:(CPEvent)anEvent
{
    console.log("DOWN - WorkflowDesigner");
    mouseDownEvent = anEvent;
}

- (void)mouseUp:(CPEvent)anEvent
{
    [[CPNotificationCenter defaultCenter] postNotificationName:@"RefreshScrollView" object:nil];
}

// -------------------------------------------------------------------- //
// ----------------------- NOTIFICATION METHODS ----------------------- //
// -------------------------------------------------------------------- //

- (void)receiveDidLoadCurrentWorkflow:(CPNotification)aNotification
{
    currentWorkflow = workflowController.currentWorkflow;
    isCurrentSelection = YES;
}

- (void)receiveAddLink:(CPNotification)aNotification
{

    var info = [aNotification userInfo],
        anEvent = [info objectForKey:"event"],
        outputPort = [aNotification object],
        currentMouseLocation = [self convertPoint:[anEvent locationInWindow] fromView:nil],
        k = 0;

    [outputPortView setHidden:YES];

    var newLink = [[Link alloc] initWithName:"" workflowStart:workflowNumber workflowEnd:-1 outputRef:outputNumber inputRef:-1 resourceListRef:resourceListNumber];
    [links addObject:newLink];

    [newLink makeConnectPointAtCurrentPoint:currentMouseLocation controlPoint1:0.0 controlPoint2:0.0 endPoint:currentMouseLocation];

    if (resourceListNumber == -1) //if not a resourceList
        workflowJobsContentArray[workflowNumber].outputPorts[outputNumber].linksIndex = k;
    else
        resourceListsContentArray[resourceListNumber].outputPorts[outputNumber].linksIndex = k;

    linksContentArray[k].outputRef = outputNumber;
    console.log("Add Link");
}


- (void)receiveReleaseLink:(CPNotification)aNotification
{

    var info = [aNotification userInfo],
        workflowNumber = [info objectForKey:"workflow_number"],
        resourceListNumber = [info objectForKey:"resource_list_number"],
        outputNumber = [info objectForKey:"output_number"],
        anEvent = [info objectForKey:"event"],
        k,
        currentMouseLocation = [self convertPoint:[anEvent locationInWindow] fromView:nil];

    var linkLoop = [[links contentArray] count];

    for (k = 0; k < linkLoop; k++)
    {
        if ((linksContentArray[k] != null) && (linksContentArray[k].workflowStart == workflowNumber) && (linksContentArray[k].resourceListRef == resourceListNumber) && (linksContentArray[k].outputRef == outputNumber))
        {
            // -------- CREATE LINK -------- //
            if ([self _isInInputLocation:currentMouseLocation])
            {
                linksContentArray[k].workflowEnd = currentInputHover[0];
                linksContentArray[k].inputRef = currentInputHover[1];
                linksContentArray[k].isUsed = YES;

                var outPort;

                if (workflowNumber != -1) //workflowJob and not resourceList
                {
                    [linksContentArray[k] makeConnectPointAtCurrentPoint:workflowJobsContentArray[workflowNumber].outputPorts[outputNumber].outputStart controlPoint1:workflowJobsContentArray[workflowNumber].outputPorts[outputNumber].outputStart controlPoint2:workflowJobsContentArray[workflowNumber].outputPorts[outputNumber].outputStart endPoint:workflowJobsContentArray[currentInputHover[0]].inputPorts[currentInputHover[1]].inputEnd];
                    workflowJobsContentArray[workflowNumber].outputPorts[outputNumber].linkRef = k;
                    workflowJobsContentArray[workflowNumber].outputPorts[outputNumber].isUsed = YES;
                    outPort = workflowJobsContentArray[workflowNumber].outputPorts[outputNumber];
                }
                else //resourceList
                {
                    [linksContentArray[k] makeConnectPointAtCurrentPoint:resourceListsContentArray[resourceListNumber].outputPorts[outputNumber].outputStart controlPoint1:resourceListsContentArray[resourceListNumber].outputPorts[outputNumber].outputStart controlPoint2:resourceListsContentArray[resourceListNumber].outputPorts[outputNumber].outputStart endPoint:workflowJobsContentArray[currentInputHover[0]].inputPorts[currentInputHover[1]].inputEnd];
                    resourceListsContentArray[resourceListNumber].outputPorts[outputNumber].linkRef = k;
                    outPort = resourceListsContentArray[resourceListNumber].outputPorts[outputNumber];
                }

                workflowJobsContentArray[currentInputHover[0]].inputPorts[currentInputHover[1]].linkRef = k;
                workflowJobsContentArray[currentInputHover[0]].inputPorts[currentInputHover[1]].isUsed = YES;
                var inPort = workflowJobsContentArray[currentInputHover[0]].inputPorts[currentInputHover[1]];

                [self createConnectionModelFromInputPort:inPort.iPort inputWorkflowJob:[workflowJobsContentArray[currentInputHover[0]] wkJob] outputPort:outPort.oPort outputWorkflowJob:[workflowJobsContentArray[workflowNumber] wkJob] linkIndex:k];

                console.log("Create Link");
            }

            // -------- REMOVE LINK -------- //
            else
            {
                linksContentArray[k] = null;
                console.log([linksContentArray count]);
                console.log("Remove Link");
            }
            [self display];
            break;
        }
    };
    [self display];
}


- (void)receiveDragLink:(CPNotification)aNotification
{
    var info = [aNotification userInfo],
        workflowNumber = [info objectForKey:"workflow_number"],
        outputNumber = [info objectForKey:"output_number"],
        resourceListNumber = [info objectForKey:"resource_list_number"],
        anEvent = [info objectForKey:"event"],
        linkRef = [info objectForKey:"link_ref"],
        isUsed = [info objectForKey:"is_used"],
        k,
        currentMouseLocation = [self convertPoint:[anEvent locationInWindow] fromView:nil];

    if (isUsed) //if outputPort already has a link, delete previous link
        [self deleteConnectionModelAtLink:linkRef workflowRef:workflowNumber];

    [outputPortView setHidden:YES];
    var linkLoop = [[links contentArray] count];

    for (k = 0; k < linkLoop; k++)
    {
        if ((linksContentArray[k] != null) && (linksContentArray[k].workflowStart == workflowNumber) && (linksContentArray[k].resourceListRef == resourceListNumber) && (linksContentArray[k].outputRef == outputNumber))
        {
            if (resourceListNumber == -1)
                [linksContentArray[k] makeConnectPointAtCurrentPoint:workflowJobsContentArray[workflowNumber].outputPorts[outputNumber].outputStart controlPoint1:currentMouseLocation controlPoint2:currentMouseLocation endPoint:currentMouseLocation];
            else
                [linksContentArray[k] makeConnectPointAtCurrentPoint:resourceListsContentArray[resourceListNumber].outputPorts[outputNumber].outputStart controlPoint1:currentMouseLocation controlPoint2:currentMouseLocation endPoint:currentMouseLocation];
        }
    };
    //refresh and display views
    [self display];
    [[CPNotificationCenter defaultCenter] postNotificationName:@"RefreshScrollView" object:nil];


}

- (void)receiveWorkflowJobDrag:(CPNotification)aNotification
{
    //adjust workflow job position
    var info = [aNotification userInfo],
        workflowNumber = [info objectForKey:"workflow_number"],
        anEvent = [info objectForKey:"event"],
        currentMouseLocation = [self convertPoint:[anEvent locationInWindow] fromView:nil];

    [self workflowJobDrag:workflowNumber mouseLocation:currentMouseLocation];

    [self display];
}

- (void)workflowJobDrag:(CPUInteger)workflowNumber mouseLocation:(CGPoint)currentMouseLocation
{
    var xProposedMouseDraggedBound = currentMouseLocation.x,
        yProposedMouseDraggedBound = currentMouseLocation.y;

    //test to see if mouse is within bounds of rect
    if (CGRectContainsPoint(self.frame, currentMouseLocation))
        [workflowJobsContentArray[workflowNumber] setCenter:currentMouseLocation];
    else
    {
        if (CGRectContainsPoint(self.frame, CGPointMake(xProposedMouseDraggedBound, 1)))
            [workflowJobsContentArray[workflowNumber] setCenter:CGPointMake(xProposedMouseDraggedBound, [workflowJobsContentArray[workflowNumber] center].y)];

        if (CGRectContainsPoint(self.frame, CGPointMake(1, yProposedMouseDraggedBound)))
            [workflowJobsContentArray[workflowNumber] setCenter:CGPointMake([workflowJobsContentArray[workflowNumber] center].x, yProposedMouseDraggedBound)];
    }

    //adjust output ports position
    var origin = [workflowJobsContentArray[workflowNumber] frameOrigin],
        i,
        outputLoop = [[workflowJobsContentArray[workflowNumber] outputPorts] count];

    for (i = 0; i < outputLoop; i++)
    {
        var outputLink = workflowJobsContentArray[workflowNumber].outputPorts[i].linkRef;

        [workflowJobsContentArray[workflowNumber].outputPorts[i] arrangeOutputPosition:origin iteration:i];
        if (linksContentArray[outputLink] != null)
        {
            linksContentArray[workflowJobsContentArray[workflowNumber].outputPorts[i].linkRef].currentPoint = workflowJobsContentArray[workflowNumber].outputPorts[i].outputStart;
            linksContentArray[workflowJobsContentArray[workflowNumber].outputPorts[i].linkRef].controlPoint1 = workflowJobsContentArray[workflowNumber].outputPorts[i].outputStart;
            linksContentArray[workflowJobsContentArray[workflowNumber].outputPorts[i].linkRef].controlpoint2 = workflowJobsContentArray[workflowNumber].outputPorts[i].outputStart;
        }
    };

    //adjust input ports position
    var inputLoop = [[workflowJobsContentArray[workflowNumber] inputPorts] count];
    for (i = 0; i < inputLoop; i++)
    {
        var inputLink = workflowJobsContentArray[workflowNumber].inputPorts[i].linkRef;

        [workflowJobsContentArray[workflowNumber].inputPorts[i] arrangeInputPosition:origin iteration:i];
        if (linksContentArray[inputLink] != null)
        {
            linksContentArray[workflowJobsContentArray[workflowNumber].inputPorts[i].linkRef].endPoint = workflowJobsContentArray[workflowNumber].inputPorts[i].inputEnd;
            linksContentArray[workflowJobsContentArray[workflowNumber].inputPorts[i].linkRef].controlPoint1 = workflowJobsContentArray[workflowNumber].inputPorts[i].inputEnd;
            linksContentArray[workflowJobsContentArray[workflowNumber].inputPorts[i].linkRef].controlPoint2 = workflowJobsContentArray[workflowNumber].inputPorts[i].inputEnd;
        }
    };
}

- (void)receiveDidSelectWorkflowJob:(CPNotification)aNotification
{
    var info = [aNotification userInfo],
        workflowNumber = [info objectForKey:"workflow_number"];

    currentDraggingIndex = workflowNumber;
}

- (void)receiveDeleteWorkflow:(CPNotification)aNotification
{
    var info = [aNotification userInfo],
        workflowNumber = [info objectForKey:"workflow_number"];

    currentDraggingIndex = workflowNumber;
    var workflowJob = [workflowJobsContentArray[currentDraggingIndex] wkJob];

    //delete workflow and I/O ports on server
    var i, j,
        outputLoop = workflowJobsContentArray[currentDraggingIndex].outputPortNumber,
        inputLoop = workflowJobsContentArray[currentDraggingIndex].inputPortNumber;
    for (j = 0; j < outputLoop; j++)
        [workflowJobsContentArray[currentDraggingIndex].outputPorts[j].oPort ensureDeleted];

    for (j = 0; j < inputLoop; j++)
        [workflowJobsContentArray[currentDraggingIndex].inputPorts[j].iPort ensureDeleted];

    [self removeWorkflowJob];
    console.log(workflowJob);
    [workflowJob ensureDeleted];


    console.log("WorkflowJob Deleted");
}

- (void)receiveDeleteResourceList:(CPNotification)aNotification
{
    var info = [aNotification userInfo],
        resourceListNumber = [info objectForKey:"resource_list_number"];

    [self removeResourceList:resourceListNumber];

    console.log("ResourceList Deleted");
}

- (void)receiveResourceListDrag:(CPNotification)aNotification
{
    var info = [aNotification userInfo],
        anEvent = [info objectForKey:"event"],
        currentMouseLocation = [self convertPoint:[anEvent locationInWindow] fromView:nil],
        resourceListRef = [info objectForKey:"resource_list_position"];

    [resourceListsContentArray[resourceListRef] setCenter:currentMouseLocation];

    //adjust output ports position
    var origin = [resourceListsContentArray[resourceListRef] frameOrigin],
        outputLoop = [resourceListsContentArray[resourceListRef] outputNum],
        i;
    for (i = 0; i < outputLoop; i++)
    {
        var outputLink = resourceListsContentArray[resourceListRef].outputPorts[i].linkRef;

        [resourceListsContentArray[resourceListRef].outputPorts[i] arrangeOutputPosition:origin iteration:i];
        if (linksContentArray[outputLink] != null)
            linksContentArray[resourceListsContentArray[resourceListRef].outputPorts[i].linkRef].currentPoint = resourceListsContentArray[resourceListRef].outputPorts[i].outputStart;
    };
    [self display];
}

- (void)receiveOutputEntered:(CPNotification)aNotification
{
    //display information from output in new view
    var info = [aNotification userInfo],
        anEvent = [info objectForKey:"event"],
        mouseLocation = [self convertPoint:[anEvent locationInWindow] fromView:nil],
        workflowNumber = [info objectForKey:"workflow_number"],
        outputNumber = [info objectForKey:"output_number"],
        outputType = [info objectForKey:"output_type"];

    // console.log("Entered Output");

    [outputPortView setHidden:NO];
    [outputPortView setFrameOrigin:CGPointMake(mouseLocation.x, mouseLocation.y)];
    [outputTypeText setStringValue:"Output Type: " + outputType];

    //get link info + add to view
    //get outputInfo and display to view

}

- (void)receiveOutputExited:(CPNotification)aNotification
{
    //exit displayed information from output
    var info = [aNotification userInfo],
        workflowNumber = [info objectForKey:"workflow_number"],
        outputNumber = [info objectForKey:"output_number"];

    // console.log("Exited Output");

    [outputPortView setHidden:YES];

}

- (void)receiveInputEntered:(CPNotification)aNotification
{
     var info = [aNotification userInfo],
         anEvent = [info objectForKey:"event"],
         mouseLocation = [self convertPoint:[anEvent locationInWindow] fromView:nil],
         inputType = [info objectForKey:"input_type"],

         workflowNumber = [info objectForKey:"workflow_number"],
         inputNumber = [info objectForKey:"input_number"];


    [inputPortView setHidden:NO];
    [inputPortView setFrameOrigin:CGPointMake(mouseLocation.x - 175, mouseLocation.y)];
    [inputTypeText setStringValue:"Input Type: " + inputType];

    //animation to fade in NOTE: if using, comment out [inputPortView setHidden:NO]
    // inputViewAnimation = [[CPViewAnimation alloc] initWithViewAnimations:[
    //     [CPDictionary dictionaryWithJSObject:{
    //         CPViewAnimationTargetKey:inputPortView,
    //         CPViewAnimationStartFrameKey:[inputPortView frame],
    //         CPViewAnimationEndFrameKey:[inputPortView frame],
    //         CPViewAnimationEffectKey:CPViewAnimationFadeInEffect
    // }]]];

    // [inputViewAnimation setAnimationCurve:CPAnimationEaseIn];
    // [inputViewAnimation setDuration:1.5];
    // [inputViewAnimation setDelegate:self];
    // [inputViewAnimation startAnimation];

}

- (void)receiveInputExited:(CPNotification)aNotification
{
    // console.log("Input Exited");
    // if ([inputViewAnimation isAnimating])
    // {
    //   [inputViewAnimation stopAnimation];
    // }
        [inputPortView setHidden:YES];
}



// - (void)receiveCurrentMouseHover:(CPNotification)aNotification
// {
//     console.log("Hover");

//     var info = [aNotification userInfo],
//         workflowNumber = [info objectForKey:"workflow_number"],
//         inputNumber = [info objectForKey:"input_number"];

//     currentInputHover[0] = workflowNumber;
//     currentInputHover[1] = inputNumber;

// }

- (void)receiveNewResourceList:(CPNotification)aNotification
{
    console.log("New Resource List");

    var i;
    for (i = 0; i < [resourceListsContentArray count]; i++)
    {
        if (resourceListsContentArray[i] == null)
            break;
    }

    resourceListsContentArray[i] = [[ResourceList alloc] initWithPoint:CGPointMake(100.0, 100.0) size:CGSizeMake(60.0, 60.0) pageNum:2 resourceListRef:i outputNum:1];
    [resourceListsContentArray[i] changeBoxAttributes:2 cornerRadius:5 fillColor:[CPColor colorWithHexString:"333333"] boxType:CPBoxPrimary title:"Resource List A"];

    [self addSubview:resourceListsContentArray[i]];

    var j,
        resourceLoop = [resourceListsContentArray[i].outputPorts count];
    for (j = 0; j < resourceLoop; j++)
        [self addSubview:resourceListsContentArray[i].outputPorts[j]];
}

- (void)receiveModelWasCreatedNotification:(CPNotification)aNotification
{
    var createdObject = [aNotification object];

    //test to see the type of object returned
    switch ([createdObject class])
    {
        case WorkflowJob:
            [self createOutputPortsForWorkflowJob:createdObject];
            [self createInputPortsForWorkflowJob:createdObject];
            [workflowJobsContentArray[creatingWorkflowJobIndex] setWkJob:createdObject];
            // console.log(createdObject);
            break;

        case Connection:
            [linksContentArray[connectionModelReference] setConnection:createdObject];
            [cacheToDelete shouldDeleteConnection:createdObject];
            // console.log(createdObject);
            break;

        case InputPort:
            [workflowJobsContentArray[creatingWorkflowJobIndex].inputPorts[createInputPortsCounter] setIPort:createdObject];
            createInputPortsCounter++;
            // console.log(createdObject);
            break;

        case OutputPort:
            [workflowJobsContentArray[creatingWorkflowJobIndex].outputPorts[createOutputPortsCounter] setOPort:createdObject];
            createOutputPortsCounter++;
            break;

        case Workflow:

        default:
            console.log(createdObject);
            break;
    }
}

// ---------------------------------------------------------------------- //
// -------------------- NOTIFICATION METHODS END ------------------------ //
// ---------------------------------------------------------------------- //

//HELPER LOCAL METHODS
- (void)createOutputPortsForWorkflowJob:(WorkflowJob)workflowJobObject
{
    var counter = 0,
        outputPortTypes = [creatingWorkflowJobIOTypes objectForKey:@"output_port_types"],
        i, j,
        outputLoop = [outputPortTypes count];

    createOutputPortsCounter = 0;

    // create output ports (minimum required) for workflowJob
    for (i = 0; i < outputLoop; i++)
    {
        for (j = 0; j < outputPortTypes[i].minimum; j++)
        {
            var oPortObject = {
                            "uuid": "",
                            "workflow_job":[workflowJobObject pk],
                            "output_port_type":outputPortTypes[i].url,
                            "label":counter
                            },

                outputPortObject = [[OutputPort alloc] initWithJson:oPortObject];

            [outputPortObject ensureCreated];
            // [workflowJobs[creatingWorkflowJobIndex].outputPorts[counter] setOPort:outputPortObject];
            counter++;
        }
    };
}


- (void)createInputPortsForWorkflowJob:(WorkflowJob)workflowJobObject
{
    var counter = 0,
        inputPortTypes = [creatingWorkflowJobIOTypes objectForKey:@"input_port_types"],
        inputLoop = [inputPortTypes count];

    createInputPortsCounter = 0;

    //create input ports (minimum required) for workflowJob
    for (var i = 0; i < inputLoop; i++)
    {
        for (var j = 0; j < inputPortTypes[i].minimum; j++)
        {
            var iPortObject = {
                            "workflow_job":[workflowJobObject pk],
                            "input_port_type":inputPortTypes[i].url,
                            "label":counter
                            },

                inputPortObject = [[InputPort alloc] initWithJson:iPortObject];

            // [workflowJobs[creatingWorkflowJobIndex].inputPorts[counter] setIPort:inputPortObject];
            [inputPortObject ensureCreated];
            counter++;
        }
    };
}

//helper method to delete graphical workflow
- (void)removeWorkflowJob
{
    [workflowJobsContentArray[currentDraggingIndex] removeFromSuperview];

    //remove I/O ports from superivew
    var j, k,
        outputLoop = workflowJobsContentArray[currentDraggingIndex].outputPortNumber,
        inputLoop = workflowJobsContentArray[currentDraggingIndex].inputPortNumber;
    for (var j = 0; j < outputLoop; j++)
    {
        [workflowJobsContentArray[currentDraggingIndex].outputPorts[j] removeFromSuperview];
        workflowJobsContentArray[currentDraggingIndex].outputPorts[j] = null;
    };
    for (var k = 0; k < inputLoop; k++)
    {
        [workflowJobsContentArray[currentDraggingIndex].inputPorts[k] removeFromSuperview];
        workflowJobsContentArray[currentDraggingIndex].inputPorts[k] = null;
    };

    workflowJobsContentArray[currentDraggingIndex] = null;
    currentDraggingIndex = -1;
}

- (void)createConnectionModelFromInputPort:(InputPort)anInputPort inputWorkflowJob:(WorkflowJob)iWorkflowJob outputPort:(OutputPort)anOutputPort outputWorkflowJob:(WorkflowJob)oWorkflowJob linkIndex:(CPInteger)aLinkRef
{
    //create connection model on server
    var connection = {"input_port":[anInputPort pk],
                      "input_workflow_job":[iWorkflowJob pk],
                      "output_port":[anOutputPort pk],
                      "output_workflow_job":[oWorkflowJob pk],
                      "workflow":[currentWorkflow pk]},

        connectionObject = [[Connection alloc] initWithJson:connection];

    connectionModelReference = aLinkRef;
    [connectionArrayController insertObject:connectionObject atArrangedObjectIndex:aLinkRef];
    [connectionObject ensureCreated];
}

- (void)deleteConnectionModelAtLink:(CPInteger)aLinkRef workflowRef:(CPInteger)aWorkflowNumber
{

    workflowJobsContentArray[linksContentArray[aLinkRef].workflowEnd].inputPorts[linksContentArray[aLinkRef].inputRef].isUsed = false;
    workflowJobsContentArray[aWorkflowNumber].outputPorts[linksContentArray[aLinkRef].outputRef].isUsed = false;
    linksContentArray[aLinkRef] = null;

    //delete server connection model
    [connectionArrayController setSelectionIndex:aLinkRef];
    var selectedIndices = [connectionArrayController selectedObjects];

    if ([selectedIndices[0] pk] != null)
        [selectedIndices[0] ensureDeleted]; //delete connection model

    else //add to deletecache and wait for notification
        [cacheToDelete.connectionsToDelete addObject:selectedIndices[0]];

    [connectionArrayController removeObjectAtArrangedObjectIndex:aLinkRef]; //remove from ArrayController

    console.info("Connection Deleted");

}

- (BOOL)_isInInputLocation:(CGPoint)mouseLocation
{
    var i,
        j,
        k,
        workflowJobCount = [workflowJobsContentArray count];

    for (i = 0; i < workflowJobCount; i++)
    {
        for (j = 0; j < workflowJobsContentArray[i].inputPortNumber; j++)
        {
            var aFrame = [workflowJobsContentArray[i].inputPorts[j] frame];

            //leniance on accuracy of user
            aFrame.size.height = 20.0;
            aFrame.size.width = 20.0;

            var bool1 = CGRectContainsPoint(aFrame, mouseLocation),
                bool2 = (workflowJobsContentArray[i].inputPorts[j].isUsed == false);

            if (bool1 && bool2)
            {
                currentInputHover[0] = i;
                currentInputHover[1] = j;
                return true;
            }

        };
    };
    return false;
}

- (void)removeResourceList:(CPUInteger)aPosition
{
    [resourceListsContentArray[aPosition] removeFromSuperview];

    //remove O ports from superview
    var i,
        resourceLoop = [resourceListsContentArray[aPosition].outputPorts count];
    for (var i = 0; i < resourceLoop; i++)
    {
        [resourceListsContentArray[aPosition].outputPorts[i] removeFromSuperview];
        resourceListsContentArray[aPosition].outputPorts[i] = null;
    };

    resourceListsContentArray[aPosition] = null;
}


// -------------------------------------------------------- //
// ------------------- SAVING METHODS --------------------- //

- (void)saveWorkflowJobPositions
{

}

- (void)saveResourceListPositions
{

}

- (void)saveLinkPositions
{

}




@end


