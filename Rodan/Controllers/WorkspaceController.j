/**
    This class handles management of view.  If you have a controller with
    views associated with it, this class will show it for you and take down
    whatever else is showing.
**/

@global RodanHasFocusInteractiveJobsViewNotification;
@global RodanHasFocusWorkflowResultsViewNotification;
@global RodanHasFocusPagesViewNotification;
@global RodanHasFocusProjectListViewNotification;

@implementation WorkspaceController : AbstractController
{
    @outlet     CPView          interactiveJobsView;
    @outlet     CPView          managePagesView;
    @outlet     CPView          workflowResultsView;
    @outlet     CPView          projectListView;
    @outlet     CPWindow        mainWindow;
    @outlet     CPMenuItem      rodanMenuItem;
                CPScrollView    _contentScrollView;
                CPView          _contentView;
                CPView          _blankView;
}

///////////////////////////////////////////////////////////////////////////////
// Public Methods
///////////////////////////////////////////////////////////////////////////////
#pragma mark Public Methods
- (void)awakeFromCib
{
    _blankView = [[CPView alloc] init];
    [mainWindow setFullPlatformWindow:YES];
    _contentView = [mainWindow contentView];
    [_contentView setAutoresizingMask:CPViewWidthSizable | CPViewHeightSizable];
    _contentScrollView = [[CPScrollView alloc] initWithFrame:[_contentView bounds]];
    [_contentScrollView setAutoresizingMask:CPViewWidthSizable | CPViewHeightSizable];
    [_contentScrollView setHasHorizontalScroller:YES];
    [_contentScrollView setHasVerticalScroller:YES];
    [_contentScrollView setAutohidesScrollers:YES];
    [_contentView setSubviews:[_contentScrollView]];
    var menubarIcon = [[CPImage alloc] initWithContentsOfFile:[[CPBundle mainBundle] pathForResource:@"menubar-icon.png"] size:CGSizeMake(16.0, 16.0)];
    [rodanMenuItem setImage:menubarIcon];
    window.onbeforeunload = function()
    {
        return "This will terminate the Application. Are you sure you want to leave?";
    }
}

- (void)clearView
{
    [_contentScrollView setDocumentView:_blankView];
}

- (void)setView:(CPView)aView
{
    [aView setFrame:[_contentScrollView bounds]];
    [aView setAutoresizingMask:CPViewWidthSizable];
    [_contentScrollView setDocumentView:aView];
}

///////////////////////////////////////////////////////////////////////////////
// Public Action Methods
///////////////////////////////////////////////////////////////////////////////
#pragma mark Public Action Methods
- (@action)switchWorkspaceToManagePages:(id)aSender
{
    [RKNotificationTimer clearTimedNotification];
    [self setView:managePagesView];
    [[CPNotificationCenter defaultCenter] postNotificationName:RodanHasFocusPagesViewNotification
                                          object:nil];
}

- (@action)switchWorkspaceToWorkflowResults:(id)aSender
{
    [RKNotificationTimer clearTimedNotification];
    [self setView:workflowResultsView];
    [[CPNotificationCenter defaultCenter] postNotificationName:RodanHasFocusWorkflowResultsViewNotification
                                          object:nil];
}

- (@action)switchWorkspaceToInteractiveJobs:(id)aSender
{
    [RKNotificationTimer clearTimedNotification];
    [self setView:interactiveJobsView];
    [[CPNotificationCenter defaultCenter] postNotificationName:RodanHasFocusInteractiveJobsViewNotification
                                          object:nil];
}

- (@action)switchWorkspaceToProjects:(id)aSender
{
    [RKNotificationTimer clearTimedNotification];
    [self setView:projectListView];
    [[CPNotificationCenter defaultCenter] postNotificationName:RodanHasFocusProjectListViewNotification
                                          object:nil];
}

///////////////////////////////////////////////////////////////////////////////
// Public Delegate Methods
///////////////////////////////////////////////////////////////////////////////
#pragma mark Public Delegate Methods
@end
