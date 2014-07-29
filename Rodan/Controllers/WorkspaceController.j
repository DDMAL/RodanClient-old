/**
    This class handles management of view.  If you have a controller with
    views associated with it, this class will show it for you and take down
    whatever else is showing.
**/

@global RodanDidCloseProjectNotification;
@global RodanDidLoadProjectNotification;
@global RodanDidLogInNotification;
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

    @outlet     TNToolbar       mainToolbar;
    @outlet     CPToolbarItem   pagesToolbarItem;
    @outlet     CPToolbarItem   workflowResultsToolbarItem;
    @outlet     CPToolbarItem   jobsToolbarItem;

    @outlet     CPMenuItem      rodanMenuItem;
    @outlet     CPMenuItem      projectMenuItem;
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
    [self _initializeMainMenu];
    [self _initializeNotificationSubscriptions];
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
- (void)handleLogInNotification:(id)aNotification
{
    [workspaceMenuItem setEnabled:NO];
    [rodanMenuItem setEnabled:YES];
    [projectMenuItem setEnabled:NO];
    [plugInsMenuItem setEnabled:YES];
}

- (void)handleProjectLoadNotification:(id)aNotification
{
    [workspaceMenuItem setEnabled:YES];
    [rodanMenuItem setEnabled:YES];
    [projectMenuItem setEnabled:YES];
    [plugInsMenuItem setEnabled:YES];
}

- (void)handleProjectCloseNotification:(id)aNotification
{
    [workspaceMenuItem setEnabled:NO];
    [rodanMenuItem setEnabled:YES];
    [projectMenuItem setEnabled:NO];
    [plugInsMenuItem setEnabled:YES];
}

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
    [pagesToolbarItem setImage:pagesToolbarIcon];
    [workflowResultsToolbarItem setImage:workflowResultsToolbarIcon];
    [jobsToolbarItem setImage:jobsToolbarIcon];
}

- (void)_initializeMainMenu
{
    [workspaceMenuItem setEnabled:NO];
    [rodanMenuItem setEnabled:NO];
    [projectMenuItem setEnabled:NO];
    [plugInsMenuItem setEnabled:NO];
}

- (void)_initializeNotificationSubscriptions
{
    [[CPNotificationCenter defaultCenter] addObserver:self
                                          selector:@selector(handleLogInNotification:)
                                          name:RodanDidLogInNotification
                                          object:nil];
    [[CPNotificationCenter defaultCenter] addObserver:self
                                          selector:@selector(handleProjectLoadNotification:)
                                          name:RodanDidLoadProjectNotification
                                          object:nil];
    [[CPNotificationCenter defaultCenter] addObserver:self
                                          selector:@selector(handleProjectCloseNotification:)
                                          name:RodanDidCloseProjectNotification
                                          object:nil];
}
@end