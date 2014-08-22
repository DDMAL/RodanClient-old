@import <Foundation/CPObject.j>

@import "../Views/WorkflowJobView.j"
@import "../Views/OutputPortView.j"
@import "../Views/ResourceListView.j"
@import "ResourceListViewController.j"
@import "ConnectionViewController.j"
@import "JobsTableController.j"
@import "DeleteCacheController.j"

//models/controllers on server end
@import <RodanKit/WorkflowController.j>
@import <RodanKit/WorkflowJob.j>
@import <RodanKit/Workflow.j>
@import <RodanKit/Connection.j>
@import <RodanKit/ConnectionController.j>
@import <RodanKit/Job.j>
@import <RodanKit/JobController.j>


JobsTableDragAndDropTableViewDataType = @"JobsTableDragAndDropTableViewDataType";

@global RodanDidLoadWorkflowNotification
@global RodanModelCreatedNotification


@implementation DesignerViewController : CPObject
{

                //associated view
    @outlet     DesignerView              designerView                @accessors;

                //view array controllers
    @outlet     CPArrayController         workflowJobs                @accessors;
    @outlet     CPArrayController         connections                 @accessors;
    @outlet     CPArrayController         resourceLists               @accessors;

                CPArray                   connectionsContentArray     @accessors;
                CPArray                   workflowJobsContentArray    @accessors;
                CPArray                   resourceListsContentArray   @accessors;

                WorkflowJobViewController currentHoverInputWorkflowJob; //pos. 0 = workflowJob, pos. 1 = inputNumber (for current hover)
                InputPortViewController   currentHoverInputPort;

                CPString                  outputTypeText;
                CPString                  inputTypeText;

                //dragging helper variables
                BOOL                      isInView;

                WorkflowJobViewController draggingWorkflowJob;
                ConnectionViewController  draggingConnection;

                //variables to reference graphical <-> server objects
                WorkflowJobViewController creatingWorkflowJob;
                CPDictionary              creatingWorkflowJobIOTypes;
                CPInteger                 createInputPortsCounter;
                CPInteger                 createOutputPortsCounter;
                ConnectionViewController  connectionModelReference;

                BOOL                      isCurrentSelection;

                DeleteCacheController     deleteCacheController       @accessors;

    /////////////////////////////////////////////////////////////////////////////
    // ------------------------ SERVER PROPERTIES ---------------------------- //
    /////////////////////////////////////////////////////////////////////////////


    //IMPORTANT: needs review, to connect to server objects without creating multiple instances

    //model controllers to fetch (load) the models from server side - connected via .xib file
    @outlet     WorkflowController        workflowController          @accessors;
    @outlet     WorkflowJobController     workflowJobController       @accessors;
    @outlet     OutputPortController      outputPortController        @accessors;
    @outlet     InputPortController       inputPortController         @accessors;
    @outlet     ConnectionController      connectionController        @accessors;
    @outlet     JobController             jobController               @accessors;

    //server model controller properties - connected via .xib file
    @outlet     Workflow                  currentWorkflow             @accessors;
    @outlet     CPArrayController         workflowArrayController     @accessors;

    @outlet     CPArrayController         jobArrayController;

    // @outlet     CPArrayController         connectionArrayController   @accessors;

}

- (id)init
{
    if (self = [super init])
    {
        //not will support expanding frame size in later method (TO DO:)
        designerView = [[DesignerView alloc] init];
        [designerView setDesignerViewController:self];

        connections = [[CPArrayController alloc] init];
        resourceLists = [[CPArrayController alloc] init];
        workflowJobs = [[CPArrayController alloc] init];

        connectionsContentArray = [connections contentArray];
        workflowJobsContentArray = [workflowJobs contentArray];
        resourceListsContentArray = [resourceLists contentArray];

        isCurrentSelection = NO;
        creatingWorkflowJobIOTypes = [[CPDictionary alloc] init];

        deleteCacheController = [[DeleteCacheController alloc] init];

        isInView = NO;

    [[CPNotificationCenter defaultCenter] addObserver:self
                                          selector:@selector(receiveAddConnection:)
                                          name:@"AddLinkToViewNotification"
                                          object:nil];

    [[CPNotificationCenter defaultCenter] addObserver:self
                                          selector:@selector(receiveReleaseConnection:)
                                          name:@"ReleaseLinkNotification"
                                          object:nil];

    [[CPNotificationCenter defaultCenter] addObserver:self
                                          selector:@selector(receiveDragConnection:)
                                          name:@"LinkIsBeingDraggedNotification"
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
                                          selector:@selector(receiveDeleteWorkflowJob:)
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

    }
    return self;
}


// ---------------------------------------------------------- //
// -------------------- DRAGGING METHODS -------------------- //
// -----------------------------------------------------------//

- (void)hasPerformedDraggingOperation:(CPDraggingInfo)aSender
{
    var pboard = [aSender draggingPasteboard],
        content = [jobArrayController arrangedObjects],
        sourceIndexes = [pboard dataForType:JobsTableDragAndDropTableViewDataType],
        job = [content objectAtIndex:[sourceIndexes firstIndex]],

        location = [designerView convertPoint:[aSender draggingLocation] fromView:nil],

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

        creatingWorkflowJob = draggingWorkflowJob; //to later create I/O ports for workflowJob (asynchronous)
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

    draggingWorkflowJob = nil;
    [designerView display];
}



- (void)draggingHasEntered:(CPDraggingInfo)aSender
{
    console.log("Dragging Entered");
    isInView = YES;

    //create view object
    var pboard = [aSender draggingPasteboard],
        content = [jobArrayController arrangedObjects],
        sourceIndexes = [pboard dataForType:JobsTableDragAndDropTableViewDataType],
        aJob = [content objectAtIndex:[sourceIndexes firstIndex]],

        location = [designerView convertPoint:[aSender draggingLocation] fromView:nil],

        inputPortTypes = [aJob inputPortTypes],
        outputPortTypes = [aJob outputPortTypes];

    if (aJob !== nil)
    {
        //create view controllers & views
        var workflowJobViewController = [[WorkflowJobViewController alloc] initWithJob:aJob];
        [workflowJobViewController createAssociatedViewsAtPoint:location];

        [workflowJobs addObject:workflowJobViewController];

        var outputContentArray = [[workflowJobViewController outputPorts] contentArray],
            outputLoop = [outputContentArray count],
            inputContentArray = [[workflowJobViewController inputPorts] contentArray],
            inputLoop = [inputContentArray count];

        for (var j = 0; j < outputLoop; j++)
            [designerView addSubview:[outputContentArray[j] outputPortView]];

        for (var k = 0; k < inputLoop; k++)
            [designerView addSubview:[inputContentArray[k] inputPortView]];

        [designerView addSubview:[workflowJobViewController workflowJobView]];
        draggingWorkflowJob = workflowJobViewController;
    }
}

- (void)draggingHasExited:(CPDraggingInfo)aSender
{
    console.log("Dragging Exited");
    isInView = NO;

    //remove workflowJob if dragging has entered
    [self removeWorkflowJob];

}

- (void)draggingHasUpdated:(CPDraggingInfo)aSender
{
    console.log("Dragging Updated");
    var currentMouseLocation = [designerView convertPoint:[aSender draggingLocation] fromView:nil];

    [self workflowJobDrag:draggingWorkflowJob mouseLocation:currentMouseLocation];
    [designerView display];
}
// ---------------------------------------------------------------------- //
// -------------------------- END DRAGGING METHODS ----------------------- //
// ---------------------------------------------------------------------- //
// -------------------------------------------------------------------- //
// ----------------------- NOTIFICATION METHODS ----------------------- //
// -------------------------------------------------------------------- //

- (void)receiveDidLoadCurrentWorkflow:(CPNotification)aNotification
{
    currentWorkflow = [aNotification object];
    isCurrentSelection = YES;
}

- (void)receiveAddConnection:(CPNotification)aNotification
{

    var info = [aNotification userInfo],
        anEvent = [info objectForKey:"event"],
        currentMouseLocation = [designerView convertPoint:[anEvent locationInWindow] fromView:nil],

        outputPortViewController = [aNotification object],
        outputWorkflowJob = [outputPortViewController workflowJobViewController],
        outputResourceList = [outputPortViewController resourceListViewController],

        newConnection = [[ConnectionViewController alloc] initWithName:""
                                                 outputWorkflowJob:outputWorkflowJob
                                                 inputWorkflowJob:nil
                                                        outputRef:outputPortViewController
                                                         inputRef:nil
                                                  resourceListRef:outputResourceList];

    [[designerView infoOutputPortView] setHidden:YES]; //hide Oportview from designerView

    [connections addObject:newConnection];

    [newConnection makeConnectPointAtCurrentPoint:currentMouseLocation
                                    controlPoint1:0.0
                                    controlPoint2:0.0
                                    endPoint:currentMouseLocation];


    draggingConnection = newConnection;

    console.info("Added Link");
}


- (void)receiveReleaseConnection:(CPNotification)aNotification
{

    var info = [aNotification userInfo],
        anEvent = [info objectForKey:"event"],
        currentMouseLocation = [designerView convertPoint:[anEvent locationInWindow] fromView:nil],

        outputPortViewController = [aNotification object],

        connection = [outputPortViewController connection];


    if ([self _isInInputLocation:currentMouseLocation])
    {
        // -------- CREATE LINK -------- //

        [connection setInputWorkflowJob:currentHoverInputWorkflowJob];
        [connection setInputReference:currentHoverInputPort];
        [connection setIsUsed:YES];

        //NOTE: Can change control points to form bezier curve based on graphics avoidance algorithm - TO DO:
        var startPoint = [[outputPortViewController outputPortView] outputStart];
        [connection makeConnectPointAtCurrentPoint:startPoint
                                     controlPoint1:startPoint
                                     controlPoint2:startPoint
                                     endPoint:[[currentHoverInputPort inputPortView] inputEnd]];

        [outputPortViewController setIsUsed:YES];

        [currentHoverInputPort setConnection:connection];
        [currentHoverInputPort setIsUsed:YES];


        //if resourceLIstConnection - do not make connection - TO DO: post resource assignment inputPort
        if (![outputPortViewController resourceListViewController])
        {
          [self createConnectionModelFromInputPort:[currentHoverInputPort inputPort]
                                inputWorkflowJob:[[currentHoverInputPort workflowJobViewController] workflowJob]
                                outputPort:[outputPortViewController outputPort]
                                outputWorkflowJob:[[outputPortViewController workflowJobViewController] workflowJob]
                                connectionRef:connection];
        }

        console.log("Created Link");
    }

    else
    {
        // -------- REMOVE LINK -------- //

        [connections removeObject:connection];
        connection = nil;
        console.log("Removed Link");
    }
    draggingConnection = nil;
    [designerView display];
}

- (void)receiveDragConnection:(CPNotification)aNotification
{
    var info = [aNotification userInfo],
        anEvent = [info objectForKey:"event"],
        currentMouseLocation = [designerView convertPoint:[anEvent locationInWindow] fromView:nil],
        outputPortViewController = [aNotification object],
        connection = [outputPortViewController connection],
        isUsed = [outputPortViewController isUsed];

    if (isUsed) //if outputPort already has a link, delete previous link
        [self deleteConnection:connection];

    [[designerView infoOutputPortView] setHidden:YES];

    //make graphical connection    NOTE: Can change control points to form bezier curve based on graphics avoidance algorithm - TO DO:
    var startPoint = [[outputPortViewController outputPortView] outputStart];
    [draggingConnection makeConnectPointAtCurrentPoint:startPoint
                                         controlPoint1:startPoint
                                         controlPoint2:startPoint
                                              endPoint:currentMouseLocation];

    [outputPortViewController setConnection:draggingConnection];

    //refresh and display views
    [designerView display];
    [designerView setNeedsDisplay:YES];
    [[CPNotificationCenter defaultCenter] postNotificationName:@"RefreshScrollView" object:nil];
}

- (void)receiveWorkflowJobDrag:(CPNotification)aNotification
{
    //adjust workflow job position
    var info = [aNotification userInfo],
        anEvent = [info objectForKey:"event"],
        currentMouseLocation = [designerView convertPoint:[anEvent locationInWindow] fromView:nil],
        workflowJobViewController = [aNotification object];

    [self workflowJobDrag:workflowJobViewController mouseLocation:currentMouseLocation];

    [designerView display];
}

- (void)workflowJobDrag:(WorkflowJobViewController)aWorkflowJobViewController mouseLocation:(CGPoint)currentMouseLocation
{
    var xProposedMouseDraggedBound = currentMouseLocation.x,
        yProposedMouseDraggedBound = currentMouseLocation.y,

        workflowJobView = [aWorkflowJobViewController workflowJobView];

    //test to see if mouse is within bounds of rect
    if (CGRectContainsPoint(designerView.frame, currentMouseLocation))
        [workflowJobView setCenter:currentMouseLocation];
    else
    {
        if (CGRectContainsPoint(designerView.frame, CGPointMake(xProposedMouseDraggedBound, 1)))
            [workflowJobView setCenter:CGPointMake(xProposedMouseDraggedBound, [workflowJobView center].y)];

        if (CGRectContainsPoint(designerView.frame, CGPointMake(1, yProposedMouseDraggedBound)))
            [workflowJobView setCenter:CGPointMake([workflowJobView center].x, yProposedMouseDraggedBound)];
    }

    //adjust output ports position
    var origin = [workflowJobView frameOrigin],
        outputContentArray = [[aWorkflowJobViewController outputPorts] contentArray],
        outputLoop = [outputContentArray count];

    for (var i = 0; i < outputLoop; i++)
    {
        [[outputContentArray[i] outputPortView] arrangeOutputPosition:origin iteration:i];
        var outputConnection = [outputContentArray[i] connection],
            newOPoint = [[outputContentArray[i] outputPortView] outputStart];

        if (outputConnection != nil)
        {
            outputConnection.startPoint = newOPoint;
            outputConnection.controlPoint1 = newOPoint;
            outputConnection.controlPoint2 = newOPoint;
        }
    };

    //adjust input ports position
    var inputContentArray = [[aWorkflowJobViewController inputPorts] contentArray],
        inputLoop = [inputContentArray count];

    for (var i = 0; i < inputLoop; i++)
    {
        [[inputContentArray[i] inputPortView] arrangeInputPosition:origin iteration:i];

        var inputConnection = [inputContentArray[i] connection],
            newIPoint = [[inputContentArray[i] inputPortView] inputEnd];

        if (inputConnection != nil)
        {
            inputConnection.endPoint = newIPoint;
            inputConnection.controlPoint1 = newIPoint;
            inputConnection.controlPoint2 = newIPoint;
        }
    };
}

- (void)receiveDidSelectWorkflowJob:(CPNotification)aNotification
{
    var workflowJobViewController = [aNotification object];

    draggingWorkflowJob = workflowJobViewController;
}

- (void)receiveDeleteWorkflowJob:(CPNotification)aNotification
{
    var workflowJobViewController = [aNotification object];

    draggingWorkflowJob = workflowJobViewController;
    var workflowJob = [workflowJobViewController workflowJob],

    //delete workflow and I/O ports on server
        outputContentArray = [[workflowJobViewController outputPorts] contentArray],
        outputLoop = [outputContentArray count],
        inputContentArray = [[workflowJobViewController inputPorts] contentArray],
        inputLoop = [inputContentArray count],
        connection;

    for (var i = 0; i < outputLoop; i++)
    {
        connection = [outputContentArray[i] connection];
        if (connection)
            [self deleteConnection:connection];
        [[outputContentArray[i] outputPort] ensureDeleted];
    }

    for (var j = 0; j < inputLoop; j++)
    {
        connection = [inputContentArray[j] connection];
        if (connection)
            [self deleteConnection:connection];
        [[inputContentArray[j] inputPort] ensureDeleted];
    }

    [workflowJob ensureDeleted];
    [workflowJobs removeObject:workflowJobViewController];
    [self removeWorkflowJob];

    console.log("WorkflowJob Deleted");
}

- (void)receiveDeleteResourceList:(CPNotification)aNotification
{
    var resourceListViewController = [aNotification object];

    [self removeResourceList:resourceListViewController];

    console.log("ResourceList Deleted");
}

- (void)receiveResourceListDrag:(CPNotification)aNotification
{
    var info = [aNotification userInfo],
        anEvent = [info objectForKey:"event"],
        currentMouseLocation = [designerView convertPoint:[anEvent locationInWindow] fromView:nil],
        resourceListViewController = [aNotification object],
        resourceView = [resourceListViewController resourceListView];

    [resourceView setCenter:currentMouseLocation];

    //adjust output ports position
    var origin = [resourceView frameOrigin],
        outputLoop = [resourceListViewController outputNum],
        outputContentArray = [[resourceListViewController outputPorts] contentArray];

    for (var i = 0; i < outputLoop; i++)
    {
        var outputConnection = [resourceListViewController connection];

        [[outputContentArray[i] outputPortView] arrangeOutputPosition:origin iteration:i];
        if (outputConnection != nil)
            [outputConnection setStartPoint:[[outputContentArray[i] outputPortView] outputStart]];
    };
    [designerView display];
}

- (void)receiveOutputEntered:(CPNotification)aNotification
{
    //display information from output in new view
    var info = [aNotification userInfo],
        anEvent = [info objectForKey:"event"],
        mouseLocation = [designerView convertPoint:[anEvent locationInWindow] fromView:nil],
        outputPortViewController = [aNotification object],

        outputType = [outputPortViewController outputPortType];

    [[designerView infoOutputPortView] setHidden:NO];
    [[designerView infoOutputPortView] setFrameOrigin:CGPointMake(mouseLocation.x, mouseLocation.y)];
    [[designerView infoOutputTypeText] setStringValue:"Output Type: " + outputType];

    //get connection info + add to view
    //get outputInfo and display to view

}

- (void)receiveOutputExited:(CPNotification)aNotification
{
    //exit displayed information from output
    [[designerView infoOutputPortView] setHidden:YES];
}

- (void)receiveInputEntered:(CPNotification)aNotification
{
      //display information from output in new view
    var info = [aNotification userInfo],
        anEvent = [info objectForKey:"event"],
        mouseLocation = [designerView convertPoint:[anEvent locationInWindow] fromView:nil],
        inputPortViewController = [aNotification object],

        inputType = [inputPortViewController inputPortType];

    [[designerView infoInputPortView] setHidden:NO];
    [[designerView infoInputPortView] setFrameOrigin:CGPointMake(mouseLocation.x - 175.0, mouseLocation.y)];
    [[designerView infoInputTypeText] setStringValue:"Input Type: " + inputType];

    //get connection info + add to view
    //get outputInfo and display to view

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
    [[designerView infoInputPortView] setHidden:YES];
}

- (void)receiveNewResourceList:(CPNotification)aNotification
{
  //NOTE: can change outputNumber and outputPortTypes when functionality comes
    var newList = [[ResourceListViewController alloc] initWithOutputNumber:1 outputPortTypes:["@Binarization"]];

    [newList createAssociatedViewsAtPoint:CGPointMake(200.0, 200.0)];

    [resourceLists addObject:newList];
    [designerView addSubview:[newList resourceListView]];
    [designerView addSubview:[[[newList outputPorts] contentArray][0] outputPortView]];


    //NOTE: need to add funcationality to support varied sized resourceLists for multiple outputPorts (similar implementation as workflowJobView)
      console.info("New Resource List");
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
            [creatingWorkflowJob setWorkflowJob:createdObject];
            // console.log(createdObject);
            break;

        case Connection:
            [connectionModelReference setConnection:createdObject];
            [deleteCacheController shouldDeleteConnection:createdObject];
            // console.log(createdObject);
            break;

        case InputPort:
            [[[creatingWorkflowJob inputPorts] contentArray][createInputPortsCounter] setInputPort:createdObject];
            createInputPortsCounter++;
            // console.log(createdObject);
            break;

        case OutputPort:
            [[[creatingWorkflowJob outputPorts] contentArray][createOutputPortsCounter] setOutputPort:createdObject];
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
        outputLoop = [outputPortTypes count],
        minimumOutputPorts = 0;

    createOutputPortsCounter = 0;

    // create output ports (minimum required) for workflowJob
    for (var i = 0; i < outputLoop; i++)
    {
        minimumOutputPorts = outputPortTypes[i].minimum;

        for (var j = 0; j < minimumOutputPorts; j++)
        {
            var oPortObject = {
                            "uuid": "",
                            "workflow_job":[workflowJobObject pk],
                            "output_port_type":outputPortTypes[i].url,
                            "label":counter
                            },

                outputPortObject = [[OutputPort alloc] initWithJson:oPortObject];

            [outputPortObject ensureCreated];
            counter++;
        }
    };
}


- (void)createInputPortsForWorkflowJob:(WorkflowJob)workflowJobObject
{
    var counter = 0,
        inputPortTypes = [creatingWorkflowJobIOTypes objectForKey:@"input_port_types"],
        inputLoop = [inputPortTypes count],
        minimumInputPorts = 0;

    createInputPortsCounter = 0;

    //create input ports (minimum required) for workflowJob
    for (var i = 0; i < inputLoop; i++)
    {
        minimumInputPorts = inputPortTypes[i].minimum;

        for (var j = 0; j < minimumInputPorts; j++)
        {
            var iPortObject = {
                            "workflow_job":[workflowJobObject pk],
                            "input_port_type":inputPortTypes[i].url,
                            "label":counter
                            },

                inputPortObject = [[InputPort alloc] initWithJson:iPortObject];

            [inputPortObject ensureCreated];
            counter++;
        }
    };
}

//helper method to delete graphical workflow
- (void)removeWorkflowJob
{
    [[draggingWorkflowJob workflowJobView] removeFromSuperview];

    //remove I/O ports from superivew
    var outputLoop = [draggingWorkflowJob outputPortNumber],
        outputContentArray = [[draggingWorkflowJob outputPorts] contentArray],
        inputLoop = [draggingWorkflowJob inputPortNumber],
        inputContentArray = [[draggingWorkflowJob inputPorts] contentArray];

    for (var j = 0; j < outputLoop; j++)
    {
        var outputView = [outputContentArray[j] outputPortView];
        [outputView removeFromSuperview];
        outputView = nil;
        outputContentArray[j] = nil;
    };

    for (var k = 0; k < inputLoop; k++)
    {
        var inputView = [inputContentArray[k] inputPortView];
        [inputView removeFromSuperview];
        inputView = nil;
        inputContentArray[k] = nil;
    };
    draggingWorkflowJob = nil;
}

- (void)createConnectionModelFromInputPort:(InputPort)anInputPort inputWorkflowJob:(WorkflowJob)iWorkflowJob outputPort:(OutputPort)anOutputPort outputWorkflowJob:(WorkflowJob)oWorkflowJob connectionRef:(ConnectionViewController)connectionRef
{
    //create connection model on server
    var connection = {"input_port":[anInputPort pk],
                      "input_workflow_job":[iWorkflowJob pk],
                      "output_port":[anOutputPort pk],
                      "output_workflow_job":[oWorkflowJob pk],
                      "workflow":[currentWorkflow pk]},

        connectionObject = [[Connection alloc] initWithJson:connection];

    //reference to connection currently being made
    connectionModelReference = connectionRef;
    [connectionObject ensureCreated];
}

- (void)deleteConnection:(ConnectionViewController)aConnection
{
    [[aConnection outputReference] setIsUsed:false];
    [[aConnection inputReference] setIsUsed:false];

    [[aConnection outputReference] setConnection:nil];
    [[aConnection inputReference] setConnection:nil];

    //delete server connection model
    if ([[aConnection connection] pk] != nil)
        [[aConnection connection] ensureDeleted]; //delete connection model

    else //add to deletecache and wait for notification
        [deleteCacheController.connectionsToDelete addObject:[aConnection connection]];

    // [connectionArrayController deleteConnection:[aConnection connection]]; //remove from server array controller
    [connections removeObject:aConnection];

    aConnection = nil;

    [[CPNotificationCenter defaultCenter] postNotificationName:@"RefreshScrollView" object:nil];
    [designerView setNeedsDisplay:YES];

    console.info("Connection Deleted");
}

- (BOOL)_isInInputLocation:(CGPoint)mouseLocation
{
    var workflowJobCount = [workflowJobsContentArray count],
        inputPortNumber = 0;

    for (var i = 0; i < workflowJobCount; i++)
    {
        if (!workflowJobsContentArray[i])
            continue;

        inputPortNumber = [workflowJobsContentArray[i] inputPortNumber];
        var inputsContentArray = [[workflowJobsContentArray[i] inputPorts] contentArray];


        for (var j = 0; j < inputPortNumber; j++)
        {
            var inputPortView = [inputsContentArray[j] inputPortView],
                aFrame = [inputPortView frame];

            //leniance on accuracy of user
            aFrame.size.height = 20.0;
            aFrame.size.width = 20.0;

            var bool1 = CGRectContainsPoint(aFrame, mouseLocation),
                bool2 = ([inputsContentArray[j] isUsed] == false);

            if (bool1 && bool2)
            {
                currentHoverInputWorkflowJob = workflowJobsContentArray[i];
                currentHoverInputPort = inputsContentArray[j];
                return true;
            }

        };
    };
    return false;
}

- (void)removeResourceList:(ResourceListViewController)aResourceListViewController
{
    [[aResourceListViewController resourceListView] removeFromSuperview];

    //remove Output ports from superview
    var resourceLoop = [aResourceListViewController outputNum],
        outputContentArray = [[aResourceListViewController outputPorts] contentArray];

    for (var i = 0; i < resourceLoop; i++)
    {
        var outputView = [outputContentArray[i] outputPortView],
            connection = [outputContentArray[i] connection];

        [self deleteConnection:connection];
        [outputView removeFromSuperview];
        outputView = nil;
        outputContentArray[i] = nil;
    };

    [resourceLists removeObject:aResourceListViewController];
    aResourceListViewController = nil;

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


