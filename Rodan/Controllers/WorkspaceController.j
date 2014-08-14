/**
    This class handles management of view.  If you have a controller with
    views associated with it, this class will show it for you and take down
    whatever else is showing.
**/

@global RodanDidLogInNotification
@global RodanDidLogOutNotification
@global RodanHasFocusInteractiveJobsViewNotification;
@global RodanHasFocusWorkflowResultsViewNotification;
@global RodanHasFocusResourcesViewNotification;
@global RodanHasFocusProjectListViewNotification;

@implementation WorkspaceController : RKController
{
    @outlet     CPView          interactiveJobsView;
    @outlet     CPView          manageResourcesView;
    @outlet     CPView          workflowResultsView;
    @outlet     CPView          projectListView;
    @outlet     CPWindow        mainWindow;

    @outlet     CPToolbar       mainToolbar;
    @outlet     CPToolbarItem   resourcesToolbarItem;
    @outlet     CPToolbarItem   workflowResultsToolbarItem;
    @outlet     CPToolbarItem   jobsToolbarItem;

    @outlet     CPMenuItem      projectsMenuItem;
    @outlet     CPMenuItem      workspaceMenuItem;
    @outlet     CPMenuItem      plugInsMenuItem;

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
    [self _initializeContentView];
    [self _initializeToolbar];
    [self setMenuEnabled:NO];
    window.onbeforeunload = function()
    {
        return "This will terminate the Application. Are you sure you want to leave?";
    }

    // Subscribe to notifications.
    [[CPNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(_didLogIn:)
                                                 name:RodanDidLogInNotification
                                                 object:nil];
    [[CPNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(_didLogOut:)
                                                 name:RodanDidLogOutNotification
                                                 object:nil];
}

- (void)clearView
{
    [mainWindow setToolbar:nil];
    [_contentScrollView setDocumentView:_blankView];
}

- (void)setView:(CPView)aView
{
    [aView setFrame:[_contentScrollView bounds]];
    [aView setAutoresizingMask:CPViewWidthSizable];
    [_contentScrollView setDocumentView:aView];
}

- (void)setView:(CPView)aView withToolbar:(CPToolbar)aToolbar
{
    [self setView:aView];
    [mainWindow setToolbar:aToolbar];
}

- (void)setMenuEnabled:(BOOL)aEnable
{
    [projectsMenuItem setEnabled:aEnable];
    [workspaceMenuItem setEnabled:aEnable];
    [plugInsMenuItem setEnabled:aEnable];
}

///////////////////////////////////////////////////////////////////////////////
// Public Action Methods
///////////////////////////////////////////////////////////////////////////////
#pragma mark Public Action Methods
- (@action)switchWorkspaceToManageResources:(id)aSender
{
    [RKNotificationTimer clearTimedNotification];
    [self setView:manageResourcesView withToolbar:nil];
    [[CPNotificationCenter defaultCenter] postNotificationName:RodanHasFocusResourcesViewNotification
                                          object:nil];
}

- (@action)switchWorkspaceToWorkflowResults:(id)aSender
{
    [RKNotificationTimer clearTimedNotification];
    [self setView:workflowResultsView withToolbar:nil];
    [[CPNotificationCenter defaultCenter] postNotificationName:RodanHasFocusWorkflowResultsViewNotification
                                          object:nil];
}

- (@action)switchWorkspaceToInteractiveJobs:(id)aSender
{
    [RKNotificationTimer clearTimedNotification];
    [self setView:interactiveJobsView withToolbar:nil];
    [[CPNotificationCenter defaultCenter] postNotificationName:RodanHasFocusInteractiveJobsViewNotification
                                          object:nil];
}

- (@action)switchWorkspaceToProjects:(id)aSender
{
    [RKNotificationTimer clearTimedNotification];
    [self setView:projectListView withToolbar:nil];
    [[CPNotificationCenter defaultCenter] postNotificationName:RodanHasFocusProjectListViewNotification
                                          object:nil];
}

///////////////////////////////////////////////////////////////////////////////
// Public Delegate Methods
///////////////////////////////////////////////////////////////////////////////
#pragma mark Public Delegate Methods

///////////////////////////////////////////////////////////////////////////////
// Private Methods
///////////////////////////////////////////////////////////////////////////////
#pragma mark Private Methods
- (void)_initializeContentView
{
    [mainWindow setFullPlatformWindow:YES];
    _contentView = [mainWindow contentView];
    [_contentView setAutoresizingMask:CPViewWidthSizable | CPViewHeightSizable];
    _contentScrollView = [[CPScrollView alloc] initWithFrame:[_contentView bounds]];
    [_contentScrollView setAutoresizingMask:CPViewWidthSizable | CPViewHeightSizable];
    [_contentScrollView setHasHorizontalScroller:YES];
    [_contentScrollView setHasVerticalScroller:YES];
    [_contentScrollView setAutohidesScrollers:YES];
    [_contentView setSubviews:[_contentScrollView]];
    [self clearView];
}

- (void)_initializeToolbar
{
    [mainToolbar setVisible:NO];
    var pagesToolbarIcon = [[CPImage alloc] initWithContentsOfFile:[[CPBundle mainBundle] pathForResource:@"toolbar-images.png"] size:CGSizeMake(40.0, 32.0)],
        workflowResultsToolbarIcon = [[CPImage alloc] initWithContentsOfFile:[[CPBundle mainBundle] pathForResource:@"toolbar-workflows.png"] size:CGSizeMake(32.0, 32.0)],
        jobsToolbarIcon = [[CPImage alloc] initWithContentsOfFile:[[CPBundle mainBundle] pathForResource:@"toolbar-jobs.png"] size:CGSizeMake(32.0, 32.0)];
    [resourcesToolbarItem setImage:pagesToolbarIcon];
    [workflowResultsToolbarItem setImage:workflowResultsToolbarIcon];
    [jobsToolbarItem setImage:jobsToolbarIcon];
    [resourcesToolbarItem setEnabled:NO];
    [workflowResultsToolbarItem setEnabled:NO];
    [jobsToolbarItem setEnabled:NO];
}

- (void)_didLogIn:(id)aNotification
{
    [projectsMenuItem setEnabled:YES];
    [plugInsMenuItem setEnabled:YES];
}

- (void)_didLogOut:(id)aNotification
{
    [projectsMenuItem setEnabled:NO];
    [plugInsMenuItem setEnabled:NO];
}
@end