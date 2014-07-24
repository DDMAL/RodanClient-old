@global RodanHasFocusInteractiveJobsViewNotification;
@global RodanHasFocusWorkflowResultsViewNotification;
@global RodanHasFocusPagesViewNotification;

@implementation WorkspaceController : AbstractController
{
    @outlet     CPView          interactiveJobsView;
    @outlet     CPView          managePagesView;
    @outlet     CPView          workflowResultsView;
    @outlet     CPObject        menuItemsController;
                CPScrollView    _contentScrollView @accessors(property=contentScrollView);
}

///////////////////////////////////////////////////////////////////////////////
// Public Methods
///////////////////////////////////////////////////////////////////////////////
#pragma mark Public Methods
- (void)awakeFromCib
{
}

- (@action)switchWorkspaceToManagePages:(id)aSender
{
    [RKNotificationTimer clearTimedNotification];
    [menuItemsController reset];
    [menuItemsController setPagesIsActive:YES];
    [managePagesView setAutoresizingMask:CPViewWidthSizable];
    [managePagesView setFrame:[_contentScrollView bounds]];
    [_contentScrollView setDocumentView:managePagesView];
    [[CPNotificationCenter defaultCenter] postNotificationName:RodanHasFocusPagesViewNotification
                                          object:nil];
}

- (@action)switchWorkspaceToWorkflowResults:(id)aSender
{
    [RKNotificationTimer clearTimedNotification];
    [menuItemsController reset];
    [menuItemsController setResultsIsActive:YES];
    [workflowResultsView setAutoresizingMask:CPViewWidthSizable];
    [workflowResultsView setFrame:[_contentScrollView bounds]];
    [_contentScrollView setDocumentView:workflowResultsView];
    [[CPNotificationCenter defaultCenter] postNotificationName:RodanHasFocusWorkflowResultsViewNotification
                                          object:nil];
}

- (@action)switchWorkspaceToInteractiveJobs:(id)aSender
{
    [RKNotificationTimer clearTimedNotification];
    [menuItemsController reset];
    [menuItemsController setJobsIsActive:YES];
    [interactiveJobsView setAutoresizingMask:CPViewWidthSizable];
    [interactiveJobsView setFrame:[_contentScrollView bounds]];
    [_contentScrollView setDocumentView:interactiveJobsView];
    [[CPNotificationCenter defaultCenter] postNotificationName:RodanHasFocusInteractiveJobsViewNotification
                                          object:nil];
}
@end
