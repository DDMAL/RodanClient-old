@import <Foundation/CPObject.j>
@import "../Delegates/ResultsViewResultsDelegate.j"
@import "../Delegates/ResultsViewRunJobsDelegate.j"

@global RodanRequestWorkflowPagesNotification
@global RodanRequestRunJobsNotification
@global RodanRequestWorkflowPageResultsNotification

/**
 * Delegate to handle the pages table in the Results view.
 */
@implementation ResultsViewPagesDelegate : CPObject
{
    @outlet ResultsViewResultsDelegate  _resultsViewResultsDelegate;
    @outlet ResultsViewRunJobsDelegate  _resultsViewRunJobsDelegate;
    @outlet CPArrayController           _pageArrayController;
            Page                        _currentlySelectedPage;
            WorkflowRun                 _associatedWorkflowRun;
            BOOL                        _selectionFlag;
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
                                              name:RodanRequestWorkflowPagesNotification
                                              object:nil];
    }
    _selectionFlag = NO;
    return self;
}

- (void)reset
{
    _currentlySelectedPage = nil;
    _associatedWorkflowRun = nil;
    _selectionFlag = NO;
    [_pageArrayController setContent:nil];
    [_resultsViewResultsDelegate reset];
    [_resultsViewRunJobsDelegate reset];
}

////////////////////////////////////////////////////////////////////////////////////////////
// Handler Methods
////////////////////////////////////////////////////////////////////////////////////////////
- (void)tableViewSelectionIsChanging:(CPNotification)aNotification
{
    if (!_selectionFlag)
    {
        _currentlySelectedPage = nil;
        [_resultsViewResultsDelegate reset];
        [_resultsViewRunJobsDelegate reset];
    }
    _selectionFlag = NO;
}

- (BOOL)tableView:(CPTableView)aTableView shouldSelectRow:(int)rowIndex
{
    _currentlySelectedPage = [[_pageArrayController contentArray] objectAtIndex:rowIndex];
    var objectToPass = [[CPObject alloc] init];
    objectToPass.page = _currentlySelectedPage;
    objectToPass.workflowRun = _associatedWorkflowRun;
    [[CPNotificationCenter defaultCenter] postNotificationName:RodanRequestRunJobsNotification
                                          object:objectToPass];
    [[CPNotificationCenter defaultCenter] postNotificationName:RodanRequestWorkflowPageResultsNotification
                                          object:objectToPass];
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
        _associatedWorkflowRun = [aNotification object];
    }

    if (_associatedWorkflowRun != nil)
    {
        [WLRemoteAction schedule:WLRemoteActionGetType
                        path:[_associatedWorkflowRun pk] + "/?by_page=true"
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
    if ([aAction result] && _associatedWorkflowRun != nil)
    {
        [WLRemoteObject setDirtProof:YES];
        var workflowRun = [[WorkflowRun alloc] initWithJson:[aAction result]];
        [_pageArrayController setContent:[workflowRun pages]];
        [WLRemoteObject setDirtProof:NO];
    }
}
@end
