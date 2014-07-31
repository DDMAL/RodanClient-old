@import <Foundation/CPObject.j>
@import "../Controllers/InteractiveJobsController.j"
@import "../Delegates/ResultsViewPagesDelegate.j"


@global RodanRequestWorkflowRunsNotification
@global RodanRequestWorkflowPagesNotification

/**
 * Runs status delegate that handles the "runs" view.
 */
@implementation ResultsViewRunsDelegate : CPObject
{
    @outlet InteractiveJobsController       _interactiveJobsController;
    @outlet ResultsViewPagesDelegate        _resultsViewPagesDelegate;
    @outlet CPArrayController               _runsArrayController;
            WorkflowRun                     _currentlySelectedWorkflowRun @accessors(property=currentlySelectedWorkflowRun);
            CPString                        _workflowUUID;
            BOOL                            _selectionFlag;
}

////////////////////////////////////////////////////////////////////////////////////////////
// Public Methods
////////////////////////////////////////////////////////////////////////////////////////////
- (id)init
{
    self = [super init];
    if (self)
    {
        [[CPNotificationCenter defaultCenter] addObserver:self
                                              selector:@selector(handleShouldLoadNotification:)
                                              name:RodanRequestWorkflowRunsNotification
                                              object:nil];
    }
    _selectionFlag = NO;
    return self;
}

- (void)reset
{
    _currentlySelectedWorkflowRun = nil;
    _workflowUUID = nil;
    _selectionFlag = NO;
    [_runsArrayController setContent:nil];
    [_resultsViewPagesDelegate reset];
}

////////////////////////////////////////////////////////////////////////////////////////////
// Action Methods
////////////////////////////////////////////////////////////////////////////////////////////
/**
 * Attempts to cancel workflow run.
 */
- (@action)cancelWorkflowRun:(id)aSender
{
    // _currentlySelectedWorkflowRun
    if (_currentlySelectedWorkflowRun != nil)
    {
        [_currentlySelectedWorkflowRun setCancelled:YES];
        [_currentlySelectedWorkflowRun ensureSaved];
    }
}

////////////////////////////////////////////////////////////////////////////////////////////
// Handler Methods
////////////////////////////////////////////////////////////////////////////////////////////
- (void)tableViewSelectionIsChanging:(CPNotification)aNotification
{
    if (!_selectionFlag)
    {
        _currentlySelectedWorkflowRun = nil;
        [_resultsViewPagesDelegate reset];
    }
    _selectionFlag = NO;
}

- (BOOL)tableView:(CPTableView)aTableView shouldSelectRow:(int)rowIndex
{
    _currentlySelectedWorkflowRun = [[_runsArrayController contentArray] objectAtIndex:rowIndex];
    [_resultsViewPagesDelegate reset];
    [[CPNotificationCenter defaultCenter] postNotificationName:RodanRequestWorkflowPagesNotification
                                          object:_currentlySelectedWorkflowRun];
    _selectionFlag = YES;
    return YES;
}

/**
 * Handles the request to load.
 */
- (void)handleShouldLoadNotification:(CPNotification)aNotification
{
    if ([aNotification object] != nil)
    {
        _workflowUUID = [aNotification object];
    }

    if (_workflowUUID != nil)
    {
        var parameters = @"?workflow=" + _workflowUUID;
        parameters += @"&ordering=created";
        [WLRemoteAction schedule:WLRemoteActionGetType
                        path:[[CPBundle mainBundle] objectForInfoDictionaryKey:"ServerHost"] + @"/workflowruns/" + parameters
                        delegate:self
                        message:nil
                        withCredentials:YES];
    }
}

/**
 * Handles success of loading.
 */
- (void)remoteActionDidFinish:(WLRemoteAction)aAction
{
    if ([aAction result] && _workflowUUID != nil)
    {
        [WLRemoteObject setDirtProof:YES];
        var workflowRunsArray = [WorkflowRun objectsFromJson:[aAction result]];
        [_runsArrayController setContent:workflowRunsArray];
        [WLRemoteObject setDirtProof:NO];
    }
}
@end
