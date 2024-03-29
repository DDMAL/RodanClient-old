@import <Foundation/CPObject.j>
@import <RodanKit/RKNotificationTimer.j>
@import "../Models/Workflow.j"
@import "../Delegates/ResultsViewWorkflowsDelegate.j"

@global activeProject
@global activeUser
@global RodanWorkflowResultsTimerNotification
@global RodanHasFocusWorkflowResultsViewNotification
@global RodanShouldLoadWorkflowsNotification
@global RodanShouldLoadWorkflowRunsNotification
@global RodanShouldLoadWorkflowPagesNotification
@global RodanShouldLoadRunJobsNotification
@global RodanShouldLoadWorkflowPageResultsNotification
@global RodanShouldLoadWorkflowResultsPackagesNotification
@global RodanShouldLoadWorkflowRunsJobsNotification

var activeWorkflow = nil,
    _msLOADINTERVAL = 5.0;

/**
 * General workflow controller that exists with the Workflow Results View.
 * It's purpose is to do a lot of reload handling.
 */
@implementation WorkflowController : CPObject
{
    @outlet     CPArrayController               workflowArrayController;
    @outlet     CPArrayController               workflowPagesArrayController;
    @outlet     CPButtonBar                     workflowAddRemoveBar;
    @outlet     ResultsViewWorkflowsDelegate    resultsViewWorkflowsDelegate;
}

////////////////////////////////////////////////////////////////////////////////////////////
// Init Methods
////////////////////////////////////////////////////////////////////////////////////////////
- (void)awakeFromCib
{
    var addButton = [CPButtonBar plusPopupButton],
        removeButton = [CPButtonBar minusButton],
        addWorkflowTitle = @"Add Workflow...";

    [addButton addItemsWithTitles:[addWorkflowTitle]];
    [workflowAddRemoveBar setButtons:[addButton, removeButton]];

    var addWorkflowItem = [addButton itemWithTitle:addWorkflowTitle];

    [addWorkflowItem setAction:@selector(newWorkflow:)];
    [addWorkflowItem setTarget:self];
    [removeButton setAction:@selector(removeWorkflow:)];
    [removeButton setTarget:self];

    [removeButton bind:@"enabled"
                  toObject:workflowArrayController
                  withKeyPath:@"selectedObjects.@count"
                  options:nil];

    // Subscriptions for self.
    [[CPNotificationCenter defaultCenter] addObserver:self
                                          selector:@selector(receiveHasFocusEvent:)
                                          name:RodanHasFocusWorkflowResultsViewNotification
                                          object:nil];
    [[CPNotificationCenter defaultCenter] addObserver:self
                                          selector:@selector(handleTimerNotification:)
                                          name:RodanWorkflowResultsTimerNotification
                                          object:nil];
}

////////////////////////////////////////////////////////////////////////////////////////////
// Public Methods
////////////////////////////////////////////////////////////////////////////////////////////
- (void)removeWorkflow:(id)aSender
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

- (void)newWorkflow:(id)aSender
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
    [[CPNotificationCenter defaultCenter] postNotificationName:RodanShouldLoadWorkflowsNotification
                                          object:nil];
    [[CPNotificationCenter defaultCenter] postNotificationName:RodanShouldLoadWorkflowRunsNotification
                                          object:nil];
    [[CPNotificationCenter defaultCenter] postNotificationName:RodanShouldLoadWorkflowPagesNotification
                                          object:nil];
    [[CPNotificationCenter defaultCenter] postNotificationName:RodanShouldLoadRunJobsNotification
                                          object:nil];
    [[CPNotificationCenter defaultCenter] postNotificationName:RodanShouldLoadWorkflowPageResultsNotification
                                          object:nil];
//    [[CPNotificationCenter defaultCenter] postNotificationName:RodanShouldLoadWorkflowResultsPackagesNotification
  //                                        object:nil];
    [[CPNotificationCenter defaultCenter] postNotificationName:RodanShouldLoadWorkflowRunsJobsNotification
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
