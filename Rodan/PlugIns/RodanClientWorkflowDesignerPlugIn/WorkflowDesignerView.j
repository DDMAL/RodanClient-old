@import <Foundation/CPObject.j>

@import "WorkflowJobView.j"
@import "Link.j"
@import "OutputPortView.j"
@import "ResourceList.j"
@import <RodanKit/Controllers/WorkflowController.j>
@import <RodanKit/Models/WorkflowJob.j> //to create JSON workflowJob model
@import <RodanKit/Models/Workflow.j>
@import <RodanKit/Models/Connection.j>

@import "DeleteCache.j"

@import "JobsTableController.j"

JobsTableDragAndDropTableViewDataType = @"JobsTableDragAndDropTableViewDataType";

@global RodanDidLoadWorkflowNotification
@global RodanModelCreatedNotification


@implementation WorkflowDesignerView : CPView
{
                CPArray             points                      @accessors;
                CPArray             workflowJobs                @accessors;
                CPArray             links                       @accessors;
                CPArray             resourceLists               @accessors;

    //views for hovering over I/O ports w/ animations
    @outlet     CPView              outputPortView              @accessors;
    @outlet     CPView              inputPortView               @accessors;

                CPViewAnimation     inputViewAnimation;
                CPViewAnimation     outputViewAnimation;

                CPArray             currentInputHover; //array, pos. 0 = workflowJob, pos. 1 = inputNumber

                CPEvent             mouseDownEvent;

                CPString            outputTypeText;
                CPString            inputTypeText;

                CGRect              frame;

                //dragging helper variables
                BOOL                isInView;
                CPInteger           currentDraggingIndex;

                CPInteger           creatingWorkflowJobIndex;
                CPDictionary        creatingWorkflowJobIOTypes;

    @outlet     CPArrayController   jobArrayController;
    @outlet     CPArrayController   connectionArrayController;

                WorklfowController  workflowController;
    @outlet     Workflow            currentWorkflow;
                BOOL                isCurrentSelection;

                DeleteCache         cacheToDelete              @accessors;


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

        points = [[CPArray alloc] init];
        workflowJobs = [[CPArray alloc] init];
        links = [[CPArray alloc] init];
        resourceLists = [[CPArray alloc] init];
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


        //TEST: temporary resourceList to define workflow
        resourceLists[0] = [[ResourceList alloc] initWithPoint:CGPointMake(400.0, 400.0) size:CGSizeMake(60.0, 60.0) pageNum:2 resourceListRef:0 outputNum:1];
        [resourceLists[0] changeBoxAttributes:2 cornerRadius:5 fillColor:[CPColor colorWithHexString:"333333"] boxType:CPBoxPrimary title:"Resource List A"];
        [self addSubview:resourceLists[0]];
        [self addSubview:resourceLists[0].outputPorts[0]];


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
    var i;
    for (i = 0; i < [links count]; i++)
    {

        //draw all links in the link array
        if (links[i] != null)
        {
            links[i].pathAToB = [[CPBezierPath alloc] init];

            var context = [[CPGraphicsContext currentContext] graphicsPort],
                shadowColor = [CPColor colorWithCalibratedWhite:1 alpha:1];

            CGContextSetFillColor(context, [CPColor colorWithCalibratedWhite:0.9 alpha:1.0]);

            CGContextSetShadowWithColor(context, CGSizeMake(1, 1), 0, shadowColor);
            CGContextSetStrokeColor(context, [CPColor blackColor]);

            [links[i].pathAToB moveToPoint:links[i].currentPoint];
            [links[i].pathAToB setLineWidth:2.0];

            [links[i].pathAToB curveToPoint:links[i].endPoint controlPoint1:links[i].controlPoint1 controlPoint2:links[i].controlPoint2];


            [links[i].pathAToB stroke];
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
        var wkObject =
        {
            "workflow": [currentWorkflow pk],
            "job": [job pk],
            "uuid": "",
            "job_name": [job jobName],
            "job_type": jobType,
            "job_description": [job description],
            "job_settings": [job settings]
        };

        var workflowJobObject = [[WorkflowJob alloc] initWithJson:wkObject];
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
        outputPortTypes = [aJob outputPortTypes];

    if (aJob != null)
    {
        for (var i = 0; i < [workflowJobs count]; i++)
            if (workflowJobs[i] == null)
                break;

        //create views and add to view as subview
        workflowJobs[i] = [[WorkflowJobView alloc] initWithPoint:location job:aJob refNumber:i];
        [workflowJobs[i] changeBoxAttributes:1.0 cornerRadius:15.0 fillColor:[CPColor colorWithHexString:"E6E6E6"] boxType:CPBoxPrimary title:"Border Crop"];


        var j,
            outputLoop = [workflowJobs[i].outputPorts count],
            inputLoop = [workflowJobs[i].inputPorts count];
        for (var j = 0; j < outputLoop; j++)
            [self addSubview:workflowJobs[i].outputPorts[j]];

        for (var k = 0; k < inputLoop; k++)
            [self addSubview:workflowJobs[i].inputPorts[k]];

        [self addSubview:workflowJobs[i]];
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
        workflowNumber = [info objectForKey:"workflow_number"],
        outputNumber = [info objectForKey:"output_number"],
        resourceListNumber = [info objectForKey:"resource_list_number"],
        anEvent = [info objectForKey:"event"],
        k = 0,
        currentMouseLocation = [self convertPoint:[anEvent locationInWindow] fromView:nil];
    [outputPortView setHidden:YES];

    while (links[k] != null)
        k++;

    links[k] = [[Link alloc] initWithName:"" workflowStart:workflowNumber workflowEnd:-1 outputRef:outputNumber inputRef:-1 resourceListRef:resourceListNumber];
    [links[k] makeConnectPointAtCurrentPoint:currentMouseLocation controlPoint1:0.0 controlPoint2:0.0 endPoint:currentMouseLocation];

    if (resourceListNumber == -1) //if not a resourceList
        workflowJobs[workflowNumber].outputPorts[outputNumber].linksIndex = k;
    else
        resourceLists[resourceListNumber].outputPorts[outputNumber].linksIndex = k;

    links[k].outputRef = outputNumber;
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

    var linkLoop = [links count];
    for (k = 0; k < linkLoop; k++)
    {
        if ((links[k] != null) && (links[k].workflowStart == workflowNumber) && (links[k].resourceListRef == resourceListNumber) && (links[k].outputRef == outputNumber))
        {
            // -------- CREATE LINK -------- //
            if ([self _isInInputLocation:currentMouseLocation])
            {
                links[k].workflowEnd = currentInputHover[0];
                links[k].inputRef = currentInputHover[1];
                links[k].isUsed = YES;

                if (workflowNumber != -1) //workflowJob and not resourceList
                {
                    [links[k] makeConnectPointAtCurrentPoint:workflowJobs[workflowNumber].outputPorts[outputNumber].outputStart controlPoint1:workflowJobs[workflowNumber].outputPorts[outputNumber].outputStart controlPoint2:workflowJobs[workflowNumber].outputPorts[outputNumber].outputStart endPoint:workflowJobs[currentInputHover[0]].inputPorts[currentInputHover[1]].inputEnd];
                    workflowJobs[workflowNumber].outputPorts[outputNumber].linkRef = k;
                    workflowJobs[workflowNumber].outputPorts[outputNumber].isUsed = YES;
                    var outPort = workflowJobs[workflowNumber].outputPorts[outputNumber];
                }
                else //resourceList
                {
                    [links[k] makeConnectPointAtCurrentPoint:resourceLists[resourceListNumber].outputPorts[outputNumber].outputStart controlPoint1:resourceLists[resourceListNumber].outputPorts[outputNumber].outputStart controlPoint2:resourceLists[resourceListNumber].outputPorts[outputNumber].outputStart endPoint:workflowJobs[currentInputHover[0]].inputPorts[currentInputHover[1]].inputEnd];
                    resourceLists[resourceListNumber].outputPorts[outputNumber].linkRef = k;
                }

                workflowJobs[currentInputHover[0]].inputPorts[currentInputHover[1]].linkRef = k;
                workflowJobs[currentInputHover[0]].inputPorts[currentInputHover[1]].isUsed = YES;
                var inPort = workflowJobs[currentInputHover[0]].inputPorts[currentInputHover[1]];

                [self createConnectionModelFromInputPort:inPort.iPort inputWorkflowJob:[workflowJobs[currentInputHover[0]] wkJob] outputPort:outPort.oPort outputWorkflowJob:[workflowJobs[workflowNumber] wkJob] linkIndex:k];

                console.log("Create Link");
            }

            // -------- REMOVE LINK -------- //
            else
            {
                links[k] = null;
                console.log([links count]);
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
    var linkLoop = [links count];
    for (k = 0; k < linkLoop; k++)
    {
        if ((links[k] != null) && (links[k].workflowStart == workflowNumber) && (links[k].resourceListRef == resourceListNumber) && (links[k].outputRef == outputNumber))
        {
            if (resourceListNumber == -1)
                [links[k] makeConnectPointAtCurrentPoint:workflowJobs[workflowNumber].outputPorts[outputNumber].outputStart controlPoint1:currentMouseLocation controlPoint2:currentMouseLocation endPoint:currentMouseLocation];
            else
                [links[k] makeConnectPointAtCurrentPoint:resourceLists[resourceListNumber].outputPorts[outputNumber].outputStart controlPoint1:currentMouseLocation controlPoint2:currentMouseLocation endPoint:currentMouseLocation];
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
        [workflowJobs[workflowNumber] setCenter:currentMouseLocation];
    else
    {
        if (CGRectContainsPoint(self.frame, CGPointMake(xProposedMouseDraggedBound, 1)))
            [workflowJobs[workflowNumber] setCenter:CGPointMake(xProposedMouseDraggedBound, [workflowJobs[workflowNumber] center].y)];

        if (CGRectContainsPoint(self.frame, CGPointMake(1, yProposedMouseDraggedBound)))
            [workflowJobs[workflowNumber] setCenter:CGPointMake([workflowJobs[workflowNumber] center].x, yProposedMouseDraggedBound)];
    }

    //adjust output ports position
    var origin = [workflowJobs[workflowNumber] frameOrigin],
        i,
        outputLoop = [[workflowJobs[workflowNumber] outputPorts] count];

    for (i = 0; i < outputLoop; i++)
    {
        var outputLink = workflowJobs[workflowNumber].outputPorts[i].linkRef;

        [workflowJobs[workflowNumber].outputPorts[i] arrangeOutputPosition:origin iteration:i];
        if (links[outputLink] != null)
        {
            links[workflowJobs[workflowNumber].outputPorts[i].linkRef].currentPoint = workflowJobs[workflowNumber].outputPorts[i].outputStart;
            links[workflowJobs[workflowNumber].outputPorts[i].linkRef].controlPoint1 = workflowJobs[workflowNumber].outputPorts[i].outputStart;
            links[workflowJobs[workflowNumber].outputPorts[i].linkRef].controlpoint2 = workflowJobs[workflowNumber].outputPorts[i].outputStart;
        }
    };

    //adjust input ports position
    var inputLoop = [[workflowJobs[workflowNumber] inputPorts] count];
    for (i = 0; i < inputLoop; i++)
    {
        var inputLink = workflowJobs[workflowNumber].inputPorts[i].linkRef;

        [workflowJobs[workflowNumber].inputPorts[i] arrangeInputPosition:origin iteration:i];
        if (links[inputLink] != null)
        {
            links[workflowJobs[workflowNumber].inputPorts[i].linkRef].endPoint = workflowJobs[workflowNumber].inputPorts[i].inputEnd;
            links[workflowJobs[workflowNumber].inputPorts[i].linkRef].controlPoint1 = workflowJobs[workflowNumber].inputPorts[i].inputEnd;
            links[workflowJobs[workflowNumber].inputPorts[i].linkRef].controlPoint2 = workflowJobs[workflowNumber].inputPorts[i].inputEnd;
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
    var workflowJob = [workflowJobs[currentDraggingIndex] wkJob];
    console.log(workflowJob);

    //delete workflow and I/O ports on server
    var i, j,
        outputLoop = workflowJobs[currentDraggingIndex].outputPortNumber,
        inputLoop = workflowJobs[currentDraggingIndex].inputPortNumber;
    for (j = 0; j < outputLoop; j++)
        [workflowJobs[currentDraggingIndex].outputPorts[j].oPort ensureDeleted];

    for (j = 0; j < inputLoop; j++)
        [workflowJobs[currentDraggingIndex].inputPorts[j].iPort ensureDeleted];

    [self removeWorkflowJob];
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

    [resourceLists[resourceListRef] setCenter:currentMouseLocation];

    //adjust output ports position
    var origin = [resourceLists[resourceListRef] frameOrigin],
        outputLoop = [resourceLists[resourceListRef] outputNum],
        i;
    for (i = 0; i < outputLoop; i++)
    {
        var outputLink = resourceLists[resourceListRef].outputPorts[i].linkRef;

        [resourceLists[resourceListRef].outputPorts[i] arrangeOutputPosition:origin iteration:i];
        if (links[outputLink] != null)
            links[resourceLists[resourceListRef].outputPorts[i].linkRef].currentPoint = resourceLists[resourceListRef].outputPorts[i].outputStart;
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
    // console.log("Entered Output");

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
    for (i = 0; i < [resourceLists count]; i++)
    {
        if (resourceLists[i] == null)
            break;
    }

    resourceLists[i] = [[ResourceList alloc] initWithPoint:CGPointMake(100.0, 100.0) size:CGSizeMake(60.0, 60.0) pageNum:2 resourceListRef:i outputNum:1];
    [resourceLists[i] changeBoxAttributes:2 cornerRadius:5 fillColor:[CPColor colorWithHexString:"333333"] boxType:CPBoxPrimary title:"Resource List A"];

    [self addSubview:resourceLists[i]];

    var j,
        resourceLoop = [resourceLists[i].outputPorts count];
    for (j = 0; j < resourceLoop; j++)
        [self addSubview:resourceLists[i].outputPorts[j]];
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
            [workflowJobs[creatingWorkflowJobIndex] setWkJob:createdObject];
            break;

        case Connection:
            console.log("HELLO");
            console.log(createdObject);
            console.log([createdObject pk]);
            [cacheToDelete shouldDeleteConnection:createdObject];
            break;

        case InputPort:
            // console.log(createdObject);
            break;
        case OutputPort:
            // console.log(createdObject);
            break;

        case Workflow:
            console.log(createdObject);

        default:
            // console.log("Default");
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
        outputPortTypes = [creatingWorkflowJobIOTypes objectForKey:@"output_port_types"];
    // create output ports (minimum required) for workflowJob
    var i, j,
        outputLoop = [outputPortTypes count];

    for (i = 0; i < outputLoop; i++)
    {
        for (j = 0; j < outputPortTypes[i].minimum; j++)
        {
            var oPortObject = {
                            "uuid": "",
                            "workflow_job":[workflowJobObject pk],
                            "output_port_type":outputPortTypes[i].url,
                            "label":""
            };

            var outputPortObject = [[OutputPort alloc] initWithJson:oPortObject];
            [outputPortObject ensureCreated];
            [workflowJobs[creatingWorkflowJobIndex].outputPorts[counter] setOPort:outputPortObject];
            counter++;
        }
    };
}


- (void)createInputPortsForWorkflowJob:(WorkflowJob)workflowJobObject
{
    var counter = 0,
        inputPortTypes = [creatingWorkflowJobIOTypes objectForKey:@"input_port_types"],
        inputLoop = [inputPortTypes count];
    
    //create input ports (minimum required) for workflowJob
    for (var i = 0; i < inputLoop; i++)
    {
        for (var j = 0; j < inputPortTypes[i].minimum; j++)
        {
            var iPortObject = {
                            "uuid": "",
                            "workflow_job":[workflowJobObject pk],
                            "input_port_type":inputPortTypes[i].url,
                            "label":""
            };

            var inputPortObject = [[InputPort alloc] initWithJson:iPortObject];
            [workflowJobs[creatingWorkflowJobIndex].inputPorts[counter] setIPort:inputPortObject];
            [inputPortObject ensureCreated];
            counter++;
        }
    };
}

//helper method to delete graphical workflow
- (void)removeWorkflowJob
{
    [workflowJobs[currentDraggingIndex] removeFromSuperview];

    //remove I/O ports from superivew
    var j, k,
        outputLoop = workflowJobs[currentDraggingIndex].outputPortNumber,
        inputLoop = workflowJobs[currentDraggingIndex].inputPortNumber;
    for (var j = 0; j < outputLoop; j++)
    {
        [workflowJobs[currentDraggingIndex].outputPorts[j] removeFromSuperview];
        workflowJobs[currentDraggingIndex].outputPorts[j] = null;
    };
    for (var k = 0; k < inputLoop; k++)
    {
        [workflowJobs[currentDraggingIndex].inputPorts[k] removeFromSuperview];
        workflowJobs[currentDraggingIndex].inputPorts[k] = null;
    };

    workflowJobs[currentDraggingIndex] = null;
    currentDraggingIndex = -1;
}

- (void)createConnectionModelFromInputPort:(InputPort)anInputPort inputWorkflowJob:(WorkflowJob)iWorkflowJob outputPort:(OutputPort)anOutputPort outputWorkflowJob:(WorkflowJob)oWorkflowJob linkIndex:(CPInteger)aLinkRef
{
    //create connection model on server
    var connection = {
                    "input_port":[anInputPort pk],
                    "input_workflow_job":[iWorkflowJob pk],
                    "output_port":[anOutputPort pk],
                    "output_workflow_job":[oWorkflowJob pk],
                    "workflow":[currentWorkflow pk],
    };

    var connectionObject = [[Connection alloc] initWithJson:connection];
    [connectionArrayController insertObject:connectionObject atArrangedObjectIndex:aLinkRef];
    console.log(connectionObject);

    [connectionObject ensureCreated];
}

- (void)deleteConnectionModelAtLink:(CPInteger)aLinkRef workflowRef:(CPInteger)aWorkflowNumber
{

    workflowJobs[links[aLinkRef].workflowEnd].inputPorts[links[aLinkRef].inputRef].isUsed = false;
    workflowJobs[aWorkflowNumber].outputPorts[links[aLinkRef].outputRef].isUsed = false;
    links[aLinkRef] = null;

    //delete server connection model
    [connectionArrayController setSelectionIndex:aLinkRef];
    var selectedIndices = [connectionArrayController selectedObjects];

    console.log(selectedIndices[0].pk);
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
        workflowJobCount = [workflowJobs count];

    for (i = 0; i < workflowJobCount; i++)
    {
        for (j = 0; j < workflowJobs[i].inputPortNumber; j++)
        {
            var aFrame = [workflowJobs[i].inputPorts[j] frame];

            //leniance on accuracy of user
            aFrame.size.height = 20.0;
            aFrame.size.width = 20.0;

            if (CPRectContainsPoint(aFrame, mouseLocation) && (workflowJobs[i].inputPorts[j].isUsed == false))
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
    [resourceLists[aPosition] removeFromSuperview];

    //remove O ports from superview
    var i,
        resourceLoop = [resourceLists[aPosition].outputPorts count];
    for (var i = 0; i < resourceLoop; i++)
    {
        [resourceLists[aPosition].outputPorts[i] removeFromSuperview];
        resourceLists[aPosition].outputPorts[i] = null;
    };

    resourceLists[aPosition] = null;
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


