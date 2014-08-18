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


JobsTableDragAndDropTableViewDataType = @"JobsTableDragAndDropTableViewDataType";

@global RodanDidLoadWorkflowNotification
@global RodanModelCreatedNotification


@implementation DesignerViewController : CPObject
{
                //associated view
                DesignerView            designerView                @accessors;

                //view array controllers
    @outlet     CPArrayController       workflowJob                 @accessors;
    @outlet     CPArrayController       connections                 @accessors;
    @outlet     CPArrayController       resourceLists               @accessors;

                CPArray                 connectionsContentArray     @accessors;
                CPArray                 workflowJobsContentArray    @accessors;
                CPArray                 resourceListsContentArray   @accessors;

                WorkflowJobViewController currentHoverInputWorkflowJob; //pos. 0 = workflowJob, pos. 1 = inputNumber (for current hover)
                InputPortViewController   currentHoverInputPort;

                CPEvent                 mouseDownEvent;

                CPString                outputTypeText;
                CPString                inputTypeText;

                //dragging helper variables
                BOOL                    isInView;
                CPInteger               currentDraggingIndex;

                WorkflowJobViewController draggingWorkflowJob;



                //variables to reference graphical <-> server objects
                CPInteger               creatingWorkflowJobIndex;
                CPDictionary            creatingWorkflowJobIOTypes;
                CPInteger               createInputPortsCounter;
                CPInteger               createOutputPortsCounter;
                ConnectionViewController    connectionModelReference;

                BOOL                    isCurrentSelection;

                DeleteCacheController   deleteCacheController       @accessors;

    /////////////////////////////////////////////////////////////////////////////
    // ------------------------ SERVER PROPERTIES ---------------------------- //
    /////////////////////////////////////////////////////////////////////////////

    //model controllers to fetch (load) the models from server side - connected via .xib file
    @outlet     WorkflowController      workflowController          @accessors;
    @outlet     WorkflowJobController   workflowJobController       @accessors;
    @outlet     OutputPortController    outputPortController        @accessors;
    @outlet     InputPortController     inputPortController         @accessors;
    @outlet     ConnectionController    connectionController        @accessors;
    @outlet     JobController           jobController               @accessors;

    //server model controller properties - connected via .xib file
    @outlet     Workflow                currentWorkflow             @accessors;
    @outlet     CPArrayController       workflowArrayController     @accessors;

    @outlet     CPArrayController       jobArrayController          @accessors;

    @outlet     CPArrayController       connectionArrayController   @accessors;

}

- (id)init
{
    self = [super init];

    if (self)
    {

        // designerView = [[DesignerView alloc] init];

        workflowJobs = [[CPArrayController alloc] init];
        connections = [[CPArrayController alloc] init];
        resourceLists = [[CPArrayController alloc] init];

        connectionsContentArray = [connections contentArray];
        workflowJobsContentArray = [workflowJobs contentArray];
        resourceListsContentArray = [resourceLists contentArray];

        isCurrentSelection = NO;
        creatingWorkflowJobIndex = -1;
        creatingWorkflowJobIOTypes = [[CPDictionary alloc] init];

        deleteCacheController = [[DeleteCacheController alloc] init];

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
        currentMouseLocation = [designerView convertPoint:[anEvent locationInWindow] fromView:nil],

        outputPortViewController = [aNotification object],
        outputWorkflowJob = [outputPortViewController workflowJobViewController],
        outputResourceList = [outputPortViewController resourceListViewController],
        outputRoot = (outputWorkflowJob) ? outputWorkflowJob : outputResourceList,



        newConnection = [[ConnectionViewController alloc] initWithName:""
                                                 outputWorkflowJob:outputRoot
                                                 inputWorkflowJob:nil
                                                        outputRef:outputPortViewController
                                                         inputRef:nil
                                                  resourceListRef:nil];

    [[designerView infoOutputPortView] setHidden:YES]; //hide Oportview from designerVIew

    [connections addObject:newConnection];

    [newConnection makeConnectPointAtCurrentPoint:currentMouseLocation controlPoint1:0.0 controlPoint2:0.0 endPoint:currentMouseLocation];

    [outputPortViewController setConnection:newConnection];

    console.info("Added Link");
}


- (void)receiveReleaseLink:(CPNotification)aNotification
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

        [self createConnectionModelFromInputPort:[currentHoverInputPort inputPort] inputWorkflowJob:[currentHoverInputPort workflowJobViewController] outputPort:[outputPortViewController outputPort] outputWorkflowJob:[outputPortViewController workflowJobViewController] connectionRef:connection];

        console.log("Created Link");
    }

    else
    {
        // -------- REMOVE LINK -------- //

        [connections removeObject:connection];
        connection = nil;
        console.log("Removed Link");
    }
    [designerView display];
}


- (void)receiveDragLink:(CPNotification)aNotification
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
    [connection makeConnectPointAtCurrentPoint:startPoint
                                 controlPoint1:startPoint
                                 controlPoint2:startPoint
                                      endPoint:currentMouseLocation];

    //refresh and display views
    [designerView display];
    [[CPNotificationCenter defaultCenter] postNotificationName:@"RefreshScrollView" object:nil];


}

- (void)receiveWorkflowJobDrag:(CPNotification)aNotification
{
    //adjust workflow job position
    var info = [aNotification userInfo],
        anEvent = [info objectForKey:"event"],
        currentMouseLocation = [self convertPoint:[anEvent locationInWindow] fromView:nil],
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
        outputLoop = [outputContentArray count],
        i;

    for (i = 0; i < outputLoop; i++)
    {
        [[outputContentArray[i] outputPortView] arrangeOutputPosition:origin iteration:i];
        var outputConnection = [outputContentArray[i] connection],
            newOPoint = [[outputContentArray[i] outputPortView] outputStart];

        if (outputConnection != null)
        {
            outputConnection.startPoint = newOPoint;
            outputConnection.controlPoint1 = newOPoint;
            outputConnection.controlPoint2 = newOPoint;
        }
    };

    //adjust input ports position
    var inputContentArray = [[aWorkflowJobViewController inputPorts] contentArray],
        inputLoop = [inputContentArray count];

    for (i = 0; i < inputLoop; i++)
    {
        [[inputContentArray[i] inputPortView] arrangeInputPosition:origin iteration:i];

        var inputConnection = [inputContentArray[i] connection],
            newIPoint = [[inputContentArray[i] inputPortView] inputEnd];

        if (inputConnection != null)
        {
            inputConnection.endPoint = newIPoint;
            inputConnection.controlPoint1 = newIpoint;
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
    var workflowJob = [workflowJobViewController workflowJob];

    //delete workflow and I/O ports on server
    var j,
        outputLoop = [workflowJobViewController outputPortNumber],
        outputContentArray = [[workflowJobViewController outputPorts] contentArray],
        inputLoop = [workflowJobViewController inputPortNumber],
        inputContentArray = [[workflowJobViewController inputPorts] contentArray];

    [outputContentArray makeObjectsPerformSelector:@selector(ensureDeleted)];
    [inputContentArray makeObjectsPerformSelector:@selector(ensureDeleted)];

    [self removeWorkflowJob];
    [workflowJob ensureDeleted];

    console.log("WorkflowJob Deleted");
}

- (void)receiveDeleteResourceList:(CPNotification)aNotification
{
    var resourceListViewController = [aNotification object];

    [self removeResourceList:ResourceListViewController];

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
        outputContentArray = [[resourceListViewController outputPorts] contentArray],
        i;
    for (i = 0; i < outputLoop; i++)
    {
        var outputConnection = [resourceListViewController connection];

        [[outputContentArray[i] outputPortView] arrangeOutputPosition:origin iteration:i];
        if (outputConnection != null)
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

        inputType = [outputPortViewController inputPortType];

    [[designerView infoOutputPortView] setHidden:NO];
    [[designerView infoOutputPortView] setFrameOrigin:CGPointMake(mouseLocation.x - 175.0, mouseLocation.y)];
    [[designerView infoOutputTypeText] setStringValue:"Input Type: " + inputType];

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
    var newList = [[ResourceListViewController alloc] initWithOutputNumber:1 outputPortTypes:["@Binarization"]],
        newListView = [[ResourceListView alloc] initWithPoint:CGPointMake(200.0, 200.0) outputNum:1 resourceListViewController:newList];

    [newList setResourceListView:newListView];

    [resourceLists addObject:newList];
    [designerView addSubview:newListView;

    var j,
        resourceLoop = [newList outputNum];
        // outputPortView = [[OutputPortView alloc] init]

    //NOTE: need to add funcationality to support varied sized resourceLists for multiple outputPorts (similar implementation as workflowJobView)



    for (j = 0; j < resourceLoop; j++)
        [designerView addSubview:newListView];

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
            [workflowJobsContentArray[creatingWorkflowJobIndex] setWkJob:createdObject];
            // console.log(createdObject);
            break;

        case Connection:
            [connectionsContentArray[connectionModelReference] setConnection:createdObject];
            [deleteCacheController shouldDeleteConnection:createdObject];
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
    [[draggingWorkflowJob workflowJobView] removeFromSuperview];

    //remove I/O ports from superivew
    var j, k,
        outputLoop = [draggingWorkflowJob outputPortNumber],
        outputContentArray = [[draggingWorkflowJob outputPorts] contentArray],
        inputLoop = [draggingWorkflowJob inputPortNumber],
        inputContentArray = [[draggingWorkflowJob inputPorts] contentArray];

    for (j = 0; j < outputLoop; j++)
    {
        var outputView = [outputContentArray[j] outputPortView];
        [outputView removeFromSuperview];
        outputView = null;
        outputContentArray[j] = null;
    };

    for (k = 0; k < inputLoop; k++)
    {
        var inputView = [inputContentArray[k] inputPortView];
        [inputView removeFromSuperview];
        inputView = null;
        inputContentArray[k] = null;
    };

    draggingWorkflowJob = null;
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
    [[aConnection outputWorkflowJob] setIsUsed:false];
    [[aConnection inputWorkflowJob] setIsUsed:false];

    //delete server connection model
    if ([[aConnection connection] pk] != null)
        [[aConnection connection] ensureDeleted]; //delete connection model

    else //add to deletecache and wait for notification
        [deleteCacheController.connectionsToDelete addObject:[aConnection connection]];

    [connectionArrayController deleteConnection:[aConnection connection]]; //remove from server array controller
    [aConnection = null];

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
        for (j = 0; j < [workflowJobsContentArray[i] inputPortNumber]; j++)
        {
            var inputsContentArray = [[workflowJobsContentArray[i] inputPorts] contentArray],
                inputPortView = [inputsContentArray[j] inputPortView],
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
    var i,
        resourceLoop = [aResourceListViewController outputNum],
        outputContentArray = [[aResourceListViewController outputPorts] contentArray];

    for (var i = 0; i < resourceLoop; i++)
    {
        var resourceView = [outputContentArray[i] resourceListView];
        [resourceView removeFromSuperview];
        resourceView = null;
        outputContentArray[i] = null;
    };

    aResourceListViewController = null;
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


