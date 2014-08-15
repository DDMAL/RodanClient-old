@import <Foundation/CPObject.j>

@import "../Views/WorkflowJobView.j"
@import "../Views/OutputPortView.j"
@import "../Views/ResourceListView.j"
@import "ResourceListViewController.j"
@import "ConnectionController.j"
@import "JobsTableController.j"
@import "DeleteCacheController.j"

//models/controllers on server end
@import <RodanKit/WorkflowController.j>
@import <RodanKit/WorkflowJob.j>
@import <RodanKit/Workflow.j>
@import <RodanKit/Connection.j>


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


                //variables to reference graphical <-> server objects
                CPInteger               creatingWorkflowJobIndex;
                CPDictionary            creatingWorkflowJobIOTypes;
                CPInteger               createInputPortsCounter;
                CPInteger               createOutputPortsCounter;
                ConnectionController    connectionModelReference;

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
        currentDraggingIndex = -1;
        creatingWorkflowJobIndex = -1;
        creatingWorkflowJobIOTypes = [[CPDictionary alloc] init];

        deleteCacheController = [[DeleteCacheController alloc] init];

        currentInputHover = [[CPArray alloc] init];
        currentInputHover[0] = -1;
        currentInputHover[1] = -1;

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



        newConnection = [[ConnectionController alloc] initWithName:""
                                                 outputWorkflowJob:outputRoot
                                                 inputWorkflowJob:nil
                                                        outputRef:outputPortViewController
                                                         inputRef:nil
                                                  resourceListRef:nil];

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
        outputWorkflowJob = [outputPortViewController workflowJobViewController],
        outputResourceList = [outputPortViewController resourceListViewController],
        outputRoot = (outputWorkflowJob) ? outputWorkflowJob : outputResourceList,

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
    var linkLoop = [[connections contentArray] count];

    for (k = 0; k < linkLoop; k++)
    {
        if ((connectionsContentArray[k] != null) && (connectionsContentArray[k].workflowStart == workflowNumber) && (connectionsContentArray[k].resourceListRef == resourceListNumber) && (connectionsContentArray[k].outputRef == outputNumber))
        {
            if (resourceListNumber == -1)
                [connectionsContentArray[k] makeConnectPointAtCurrentPoint:workflowJobsContentArray[workflowNumber].outputPorts[outputNumber].outputStart controlPoint1:currentMouseLocation controlPoint2:currentMouseLocation endPoint:currentMouseLocation];
            else
                [connectionsContentArray[k] makeConnectPointAtCurrentPoint:resourceListsContentArray[resourceListNumber].outputPorts[outputNumber].outputStart controlPoint1:currentMouseLocation controlPoint2:currentMouseLocation endPoint:currentMouseLocation];
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
        if (connectionsContentArray[outputLink] != null)
        {
            connectionsContentArray[workflowJobsContentArray[workflowNumber].outputPorts[i].linkRef].currentPoint = workflowJobsContentArray[workflowNumber].outputPorts[i].outputStart;
            connectionsContentArray[workflowJobsContentArray[workflowNumber].outputPorts[i].linkRef].controlPoint1 = workflowJobsContentArray[workflowNumber].outputPorts[i].outputStart;
            connectionsContentArray[workflowJobsContentArray[workflowNumber].outputPorts[i].linkRef].controlpoint2 = workflowJobsContentArray[workflowNumber].outputPorts[i].outputStart;
        }
    };

    //adjust input ports position
    var inputLoop = [[workflowJobsContentArray[workflowNumber] inputPorts] count];
    for (i = 0; i < inputLoop; i++)
    {
        var inputLink = workflowJobsContentArray[workflowNumber].inputPorts[i].linkRef;

        [workflowJobsContentArray[workflowNumber].inputPorts[i] arrangeInputPosition:origin iteration:i];
        if (connectionsContentArray[inputLink] != null)
        {
            connectionsContentArray[workflowJobsContentArray[workflowNumber].inputPorts[i].linkRef].endPoint = workflowJobsContentArray[workflowNumber].inputPorts[i].inputEnd;
            connectionsContentArray[workflowJobsContentArray[workflowNumber].inputPorts[i].linkRef].controlPoint1 = workflowJobsContentArray[workflowNumber].inputPorts[i].inputEnd;
            connectionsContentArray[workflowJobsContentArray[workflowNumber].inputPorts[i].linkRef].controlPoint2 = workflowJobsContentArray[workflowNumber].inputPorts[i].inputEnd;
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
        if (connectionsContentArray[outputLink] != null)
            connectionsContentArray[resourceListsContentArray[resourceListRef].outputPorts[i].linkRef].currentPoint = resourceListsContentArray[resourceListRef].outputPorts[i].outputStart;
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

- (void)createConnectionModelFromInputPort:(InputPort)anInputPort inputWorkflowJob:(WorkflowJob)iWorkflowJob outputPort:(OutputPort)anOutputPort outputWorkflowJob:(WorkflowJob)oWorkflowJob connectionRef:(ConnectionController)connectionRef
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

- (void)deleteConnectionModelAtLink:(CPInteger)aLinkRef workflowRef:(CPInteger)aWorkflowNumber
{

    workflowJobsContentArray[connectionsContentArray[aLinkRef].workflowEnd].inputPorts[connectionsContentArray[aLinkRef].inputRef].isUsed = false;
    workflowJobsContentArray[aWorkflowNumber].outputPorts[connectionsContentArray[aLinkRef].outputRef].isUsed = false;
    connectionsContentArray[aLinkRef] = null;

    //delete server connection model
    [connectionArrayController setSelectionIndex:aLinkRef];
    var selectedIndices = [connectionArrayController selectedObjects];

    if ([selectedIndices[0] pk] != null)
        [selectedIndices[0] ensureDeleted]; //delete connection model

    else //add to deletecache and wait for notification
        [deleteCacheController.connectionsToDelete addObject:selectedIndices[0]];

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


