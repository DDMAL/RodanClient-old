@import <Foundation/CPObject.j>
@import "../Controllers/RKController.j"
@import "../Models/Workflow.j"
@import "../Tools/RKNotificationTimer.j"
@import "../../../Delegates/ResultsViewWorkflowsDelegate.j"

@global activeProject
@global activeUser
@global RodanDidLoadWorkflowsNotification
@global RodanWorkflowResultsTimerNotification
@global RodanHasFocusWorkflowResultsViewNotification
@global RodanRequestWorkflowsNotification
@global RodanRequestWorkflowRunsNotification
@global RodanRequestWorkflowPagesNotification
@global RodanRequestRunJobsNotification
@global RodanRequestWorkflowPageResultsNotification
@global RodanRequestWorkflowResultsPackagesNotification
@global RodanRequestWorkflowRunsJobsNotification

RodanDidLoadWorkflowNotification = @"RodanDidLoadWorkflowNotification";
RodanDidLoadWorkflowsNotification = @"RodanDidLoadWorkflowsNotification";

var activeWorkflow = nil,
    _msLOADINTERVAL = 5.0,

    _MESSAGE_WORKFLOW_LOAD = "Loading Workflow",
    _MESSAGE_WORKFLOWS_LOAD = "Loading Workflows";

/**
 * General workflow controller that exists with the Workflow Results View.
 * It's purpose is to do a lot of reload handling.
 */
@implementation WorkflowController : RKController
{
    @outlet     CPArrayController               workflowArrayController;
    @outlet     CPArrayController               workflowPagesArrayController;
    @outlet     CPButtonBar                     workflowAddRemoveBar;
    @outlet     ResultsViewWorkflowsDelegate    resultsViewWorkflowsDelegate;

    @outlet     Workflow                        currentWorkflow;
}

////////////////////////////////////////////////////////////////////////////////////////////
// Init Methods
////////////////////////////////////////////////////////////////////////////////////////////
- (void)awakeFromCib
{
    var addWorkflowTitle = @"Add Workflow...";

    // [removeButton bind:@"enabled"
    //               toObject:workflowArrayController
    //               withKeyPath:@"selectedObjects.@count"
    //               options:nil];

    // Subscriptions for self.
    [[CPNotificationCenter defaultCenter] addObserver:self
                                          selector:@selector(receiveHasFocusEvent:)
                                          name:RodanHasFocusWorkflowResultsViewNotification
                                          object:nil];
    
    [[CPNotificationCenter defaultCenter] addObserver:self
                                          selector:@selector(handleTimerNotification:)
                                          name:RodanWorkflowResultsTimerNotification
                                          object:nil];

    [[CPNotificationCenter defaultCenter] addObserver:self
                                          selector:@selector(receiveRequestWorkflowsNotification:)
                                          name:RodanRequestWorkflowsNotification
                                          object:nil];
}
///////////////////////////////////////////////////////////////////////////////////////////
//Public Delegate Methods
///////////////////////////////////////////////////////////////////////////////////////////

- (void)remoteActionDidFinish:(WLRemoteAction)anAction 
{
    if ([anAction result])
    {
        switch ([anAction message])
        {
            case _MESSAGE_WORKFLOWS_LOAD:
                var workflow = [Workflow objectsFromJson:[anAction result]];
                [workflowArrayController setContent:workflow];
                [[CPNotificationCenter defaultCenter] postNotificationName:RodanDidLoadWorkflowsNotification
                                                      object:[anAction result]];
                break;

            case _MESSAGE_WORKFLOW_LOAD:
                currentWorkflow =  [self updateWorkflowWithJson:[anAction result]];
                [[CPNotificationCenter defaultCenter] postNotificationName:RodanDidLoadWorkflowNotification
                                                      object:nil];
                break;
        }
    }
}


////////////////////////////////////////////////////////////////////////////////////////////
// Public Methods
////////////////////////////////////////////////////////////////////////////////////////////

- (void)fetchWorkflows
{
    [WLRemoteAction schedule:WLRemoteActionGetType
                    path:[self serverHost] + "/workflows/?project=" + [activeProject uuid]
                    delegate:self
                    message:"Loading Workflows"
                    withCredentials:YES];
}


- (void)fetchWorkflow:(CPUInteger)anIndex
{
    var uuid = [[[workflowArrayController contentArray] objectAtIndex:anIndex] uuid];
    [WLRemoteAction schedule:WLRemoteActionGetType
                    path:[self serverHost] + "/workflow/" + uuid + "/"
                    delegate:self
                    message:"Loading Workflow"
                    withCredentials:YES]; 
}

- (void)removeWorkflow:(CPIndexSet)anIndexSet
{
    [workflowArrayController setSelectedObjects:anIndexSet];
    if ([workflowArrayController selectedObjects])
    {
        var alert = [CPAlert alertWithMessageText:@"You are about to permanently delete this workflow"
                             defaultButton:@"Delete"
                             alternateButton:@"Cancel"
                             otherButton:nil
                             informativeTextWithFormat:nil];
        [alert setDelegate:self];
        [alert runModal];
    }
}

- (void)removeWorkflow
{
    if ([workflowArrayController selectedObjects])
    {
        var alert = [CPAlert alertWithMessageText:@"You are about to permanently delete this workflow"
                             defaultButton:@"Delete"
                             alternateButton:@"Cancel"
                             otherButton:nil
                             informativeTextWithFormat:nil];
        [alert setDelegate:self];
        [alert runModal];
    }
}

- (void)newWorkflow
{
    var wflow = [[Workflow alloc] init];
    [wflow setProjectURL:[activeProject pk]];
    [wflow setWorkflowCreator:[activeUser pk]];
    [workflowArrayController addObject:wflow];
    [wflow ensureCreated];
}

- (void)alertDidEnd:(CPAlert)theAlert returnCode:(int)returnCode
{
    if (returnCode == 0)
    {
        var selectedObjects = [workflowArrayController selectedObjects];
        [workflowArrayController removeObjects:selectedObjects];
        [selectedObjects makeObjectsPerformSelector:@selector(ensureDeleted)];
    }
}

- (void)emptyWorkflowArrayController
{
    [workflowArrayController setContent:nil];
}

- (Workflow)updateWorkflowWithJson:(id)aJson
{
    // Create a temp workflow (so we don't have to deal with JSON).
    [WLRemoteObject setDirtProof:YES];
    var tempWorkflow = [[Workflow alloc] initWithJson:aJson];
    [WLRemoteObject setDirtProof:NO];

    // Go through workflow array and update the workflow.
    var workflowEnumerator = [[workflowArrayController arrangedObjects] objectEnumerator],
        workflow = nil;
    while (workflow = [workflowEnumerator nextObject])
    {
        if ([workflow pk] === [tempWorkflow pk])
        {
            [WLRemoteObject setDirtProof:YES];
            workflow = [workflow initWithJson:aJson];
            [WLRemoteObject setDirtProof:NO];
            return workflow;
        }
    }
    return nil;
}


- (void)receiveRequestWorkflowsNotification:(CPNotification)aNotification
{
    [self fetchWorkflows];
}

////////////////////////////////////////////////////////////////////////////////////////////
// Action Methods
////////////////////////////////////////////////////////////////////////////////////////////
/**
 * Runs the currently selected workflow.
 */
- (@action)runWorkflow:(id)aSender
{
    var workflow = [WorkflowController activeWorkflow];
    if (workflow != nil)
    {
        [workflow touchWorkflowJobs];
        var workflowRunAsJson = {"workflow": [workflow pk], "creator": [activeUser pk]},
            workflowRun = [[WorkflowRun alloc] initWithJson:workflowRunAsJson];
        [workflowRun ensureCreated];
    }
}

/**
 * Tests the workflow.
 */
- (@action)testWorkflow:(id)aSender
{
    var workflow = [WorkflowController activeWorkflow];
    if (workflow != nil)
    {
        [workflow touchWorkflowJobs];
        var selectedPage = [[workflowPagesArrayController contentArray] objectAtIndex:[workflowPagesArrayController selectionIndex]],
            workflowRunAsJson = {"workflow": [workflow pk], "test_run": true, "creator": [activeUser pk]},
            testWorkflowRun = [[WorkflowRun alloc] initWithJson:workflowRunAsJson];
        [testWorkflowRun setTestPageID:[selectedPage pk]];
        [testWorkflowRun ensureCreated];
    }
}

////////////////////////////////////////////////////////////////////////////////////////////
// Handler Methods
////////////////////////////////////////////////////////////////////////////////////////////
- (void)receiveHasFocusEvent:(CPNotification)aNotification
{
    [resultsViewWorkflowsDelegate reset];
    [RKNotificationTimer setTimedNotification:_msLOADINTERVAL
                         notification:RodanWorkflowResultsTimerNotification];
}

- (void)handleTimerNotification:(CPNotification)aNotification
{
    [[CPNotificationCenter defaultCenter] postNotificationName:RodanRequestWorkflowsNotification
                                          object:nil];
    [[CPNotificationCenter defaultCenter] postNotificationName:RodanRequestWorkflowRunsNotification
                                          object:nil];
    [[CPNotificationCenter defaultCenter] postNotificationName:RodanRequestWorkflowPagesNotification
                                          object:nil];
    [[CPNotificationCenter defaultCenter] postNotificationName:RodanRequestRunJobsNotification
                                          object:nil];
    [[CPNotificationCenter defaultCenter] postNotificationName:RodanRequestWorkflowPageResultsNotification
                                          object:nil];
    [[CPNotificationCenter defaultCenter] postNotificationName:RodanRequestWorkflowResultsPackagesNotification
                                          object:nil];
    [[CPNotificationCenter defaultCenter] postNotificationName:RodanRequestWorkflowRunsJobsNotification
                                          object:nil];
}

////////////////////////////////////////////////////////////////////////////////////////////
// Public Static Methods
////////////////////////////////////////////////////////////////////////////////////////////
+ (Workflow)activeWorkflow
{
    return activeWorkflow;
}

+ (void)setActiveWorkflow:(Workflow)aWorkflow
{
    activeWorkflow = aWorkflow;
}
@end
