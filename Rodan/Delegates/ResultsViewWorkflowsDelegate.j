@import <Foundation/CPObject.j>
@import "../Frameworks/RodanKit/Controllers/WorkflowController.j"

@global activeProject
@global RodanRequestWorkflowsNotification
@global RodanShouldLoadWorkflowRunsNotification

@class WorkflowController

/**
 * Delegate for the Workflow table view in the Results view.
 */
@implementation ResultsViewWorkflowsDelegate : CPObject
{
    @outlet     CPArrayController       _workflowArrayController;
    @outlet     ResultsViewRunsDelegate _resultsViewRunsDelegate;
    @outlet     CPView                  _workflowControlView;
                Workflow                _currentlySelectedWorkflow;
                Workflow                _loadingWorkflow;
                BOOL                    _selectionFlag;
}

#pragma mark Public
////////////////////////////////////////////////////////////////////////////////////////////
// Init Methods
////////////////////////////////////////////////////////////////////////////////////////////
- (void)awakeFromCib
{
    var initialFrame = [_workflowControlView frame],
        xDimension = CGRectGetMaxX(initialFrame) - CGRectGetMinX(initialFrame),
        yDimension = CGRectGetMaxY(initialFrame) - CGRectGetMinY(initialFrame);
    [_workflowControlView setFrameSize:CGSizeMake(xDimension, yDimension * 1.5)];
}

- (id)init
{
    _selectionFlag = NO;
    [[CPNotificationCenter defaultCenter] addObserver:self
                                          selector:@selector(handleShouldLoadWorkflowsNotification:)
                                          name:RodanRequestWorkflowsNotification
                                          object:nil];
    return self;
}

////////////////////////////////////////////////////////////////////////////////////////////
// Public Methods
////////////////////////////////////////////////////////////////////////////////////////////
- (void)reset
{
    [_resultsViewRunsDelegate reset];
    _currentlySelectedWorkflow = [WorkflowController activeWorkflow];
    _selectionFlag = NO;
}

/**
 * Does a workflow load request.
 */
- (void)sendLoadRequest
{
    [WLRemoteAction schedule:WLRemoteActionGetType
                    path:[[CPBundle mainBundle] objectForInfoDictionaryKey:"ServerHost"] + @"/workflows/?project=" + [activeProject uuid]
                    delegate:self
                    message:nil
                    withCredentials:YES];
}

////////////////////////////////////////////////////////////////////////////////////////////
// Handler Methods
////////////////////////////////////////////////////////////////////////////////////////////
- (void)tableViewSelectionIsChanging:(CPNotification)aNotification
{
    if (!_selectionFlag)
    {
        _currentlySelectedWorkflow = nil;
        [WorkflowController setActiveWorkflow:nil];
        [_resultsViewRunsDelegate reset];
    }
    _selectionFlag = NO;
}

- (BOOL)tableView:(CPTableView)aTableView shouldSelectRow:(int)rowIndex
{

    _currentlySelectedWorkflow = [[_workflowArrayController contentArray] objectAtIndex:rowIndex];
    [WorkflowController setActiveWorkflow:_currentlySelectedWorkflow];
    [_resultsViewRunsDelegate reset];
    [[CPNotificationCenter defaultCenter] postNotificationName:RodanShouldLoadWorkflowRunsNotification
                                          object:[_currentlySelectedWorkflow uuid]];
    _selectionFlag = YES;
    return YES;
}

/**
 * Handles workflows load notification.
 */
- (void)handleShouldLoadWorkflowsNotification:(CPNotification)aNotification
{
    [self sendLoadRequest];
}

/**
 * Handles remote object load.
 */
- (void)remoteActionDidFinish:(WLRemoteAction)aAction
{
    if ([aAction result])
    {
        [WLRemoteObject setDirtProof:YES];
        var workflowArray = [Workflow objectsFromJson:[aAction result]];
        [_workflowArrayController setContent:workflowArray];
        [WLRemoteObject setDirtProof:NO];
    }
}
@end
