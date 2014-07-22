/*
    Copyright (c) 2011-2012 Andrew Hankinson and Others (See AUTHORS file)

    Permission is hereby granted, free of charge, to any person obtaining
    a copy of this software and associated documentation files (the
    "Software"), to deal in the Software without restriction, including
    without limitation the rights to use, copy, modify, merge, publish,
    distribute, sublicense, and/or sell copies of the Software, and to
    permit persons to whom the Software is furnished to do so, subject to
    the following conditions:

    The above copyright notice and this permission notice shall be
    included in all copies or substantial portions of the Software.

    THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
    EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
    MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
    NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE
    LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION
    OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION
    WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
*/

@import <AppKit/AppKit.j>
@import <FileUpload/FileUpload.j>
@import <Foundation/CPObject.j>
@import <Ratatosk/Ratatosk.j>
@import <RodanKit/RodanKit.j>
@import <TNKit/TNKit.j>

@import "Categories/CPButtonBar+PopupButtons.j"
@import "Controllers/AuthenticationController.j"
@import "Controllers/MenuItemsController.j"
@import "Controllers/PageController.j"
@import "Controllers/PlugInsController.j"
@import "Controllers/ProjectController.j"
@import "Controllers/ResultsPackageController.j"
@import "Controllers/WorkflowController.j"
@import "Delegates/ResultsViewPagesDelegate.j"
@import "Delegates/ResultsViewResultsDelegate.j"
@import "Delegates/ResultsViewRunsDelegate.j"
@import "Delegates/ResultsViewWorkflowsDelegate.j"
@import "Delegates/ResultsViewRunJobsDelegate.j"
@import "Transformers/GameraClassNameTransformer.j"
@import "Transformers/RetryFailedRunJobsTransformer.j"
@import "Transformers/ResultsDisplayTransformer.j"
@import "Transformers/ResultThumbnailTransformer.j"

RodanDidLoadProjectNotification = @"RodanDidLoadProjectNotification";
RodanDidCloseProjectNotification = @"RodanDidCloseProjectNotification";
RodanShouldLoadProjectNotification = @"RodanShouldLoadProjectNotification";
RodanDidLoadProjectsNotification = @"RodanDidLoadProjectsNotification";
RodanDidLoadJobsNotification = @"RodanDidLoadJobsNotification";
RodanJobTreeNeedsRefresh = @"RodanJobTreeNeedsRefresh";
RodanDidLoadWorkflowsNotification = @"RodanDidLoadWorkflowsNotification";
RodanDidLoadWorkflowNotification = @"RodanDidLoadWorkflowNotification";
RodanDidRefreshWorkflowsNotification = @"RodanDidRefreshWorkflowsNotification";
RodanRemoveJobFromWorkflowNotification = @"RodanRemoveJobFromWorkflowNotification";
RodanWorkflowTreeNeedsRefresh = @"RodanWorkflowTreeNeedsRefresh";
RodanMustLogInNotification = @"RodanMustLogInNotification";
RodanDidLogInNotification = @"RodanDidLogInNotification";
RodanCannotLogInNotification = @"RodanCannotLogInNotification";
RodanLogInErrorNotification = @"RodanLogInErrorNotification";
RodanDidLogOutNotification = @"RodanDidLogOutNotification";
RodanShouldLoadInteractiveJobsNotification = @"RodanShouldLoadInteractiveJobsNotification";
RodanShouldLoadWorkflowRunsNotification = @"RodanShouldLoadWorkflowRunsNotification";
RodanShouldLoadWorkflowPagesNotification = @"RodanShouldLoadWorkflowPagesNotification";
RodanShouldLoadWorkflowRunsJobsNotification = @"RodanShouldLoadWorkflowRunsJobsNotification";
RodanShouldLoadPagesNotification = @"RodanShouldLoadPagesNotification";
RodanShouldLoadWorkflowsNotification = @"RodanShouldLoadWorkflowsNotification";
RodanShouldLoadWorkflowPageResultsNotification = @"RodanShouldLoadWorkflowPageResultsNotification";
RodanShouldLoadRunJobsNotification = @"RodanShouldLoadRunJobsNotification";
RodanWorkflowResultsTimerNotification = @"RodanWorkflowResultsTimerNotification";
RodanShouldLoadWorkflowResultsPackagesNotification = @"RodanShouldLoadWorkflowResultsPackagesNotification";
RodanHasFocusInteractiveJobsViewNotification = @"RodanHasFocusInteractiveJobsViewNotification";
RodanHasFocusWorkflowResultsViewNotification = @"RodanHasFocusWorkflowResultsViewNotification";
RodanHasFocusPagesViewNotification = @"RodanHasFocusPagesViewNotification";

activeUser = nil;     // URI to the currently logged-in user
activeProject = nil;  // URI to the currently open project

@implementation AppController : CPObject
{
    @outlet     CPWindow                    theWindow;
    @outlet     TNToolbar                   theToolbar  @accessors(readonly);
    @outlet     CPView                      projectStatusView;
    @outlet     CPView                      loginWaitScreenView;
    @outlet     CPView                      workflowResultsView;
    @outlet     CPView                      interactiveJobsView;
    @outlet     CPView                      managePagesView;
    @outlet     CPView                      chooseWorkflowView;
    @outlet     CPObject                    menuItemsController;
    @outlet     CPArrayController           projectArrayController;
    @outlet     CPToolbarItem               statusToolbarItem;
    @outlet     CPToolbarItem               pagesToolbarItem;
    @outlet     CPToolbarItem               workflowResultsToolbarItem;
    @outlet     CPToolbarItem               jobsToolbarItem;
    @outlet     CPToolbarItem               usersToolbarItem;
    @outlet     CPButtonBar                 workflowAddRemoveBar;
    @outlet     CPMenu                      switchWorkspaceMenu;
    @outlet     CPMenuItem                  rodanMenuItem;
    @outlet     CPMenuItem                  plugInsMenuItem;
    @outlet     AuthenticationController    authenticationController;
    @outlet     JobController               jobController;
    @outlet     PageController              pageController;
    @outlet     ProjectController           projectController;
    @outlet     UploadButton                imageUploadButton;
    @outlet     WorkflowController          workflowController;

    CGRect          _theWindowBounds;
    CPScrollView    contentScrollView @accessors(readonly);
    CPView          contentView;
    CPBundle        theBundle;
    CPCookie        CSRFToken;
    CPString        projectName;

}

///////////////////////////////////////////////////////////////////////////////
// Public Static Methods
///////////////////////////////////////////////////////////////////////////////
#pragma mark Public Static Methods
+ (void)initialize
{
    [super initialize];
    [RodanKit initialize];
    [self registerValueTransformers];
}

+ (void)registerValueTransformers
{
    gameraClassNameTransformer = [[GameraClassNameTransformer alloc] init];
    [GameraClassNameTransformer setValueTransformer:gameraClassNameTransformer forName:@"GameraClassNameTransformer"];

    resultsDisplayTransformer = [[ResultsDisplayTransformer alloc] init];
    [ResultsDisplayTransformer setValueTransformer:resultsDisplayTransformer forName:@"ResultsDisplayTransformer"];

    resultThumbnailTransformer = [[ResultThumbnailTransformer alloc] init];
    [ResultThumbnailTransformer setValueTransformer:resultThumbnailTransformer forName:@"ResultThumbnailTransformer"];

    retryFailedRunJobsTransformer = [[RetryFailedRunJobsTransformer alloc] init];
    [RetryFailedRunJobsTransformer setValueTransformer:retryFailedRunJobsTransformer forName:@"RetryFailedRunJobsTransformer"];
}

///////////////////////////////////////////////////////////////////////////////
// Public Methods
///////////////////////////////////////////////////////////////////////////////
#pragma mark Public Methods
- (void)awakeFromCib
{
    CPLogRegister(CPLogConsole);

    // Initialize authentication control.
    [authenticationController checkIsAuthenticated];

    CSRFToken = [[CPCookie alloc] initWithName:@"csrftoken"];

    [theWindow setFullPlatformWindow:YES];

    //[imageUploadButton setValue:[CSRFToken value] forParameter:@"csrfmiddlewaretoken"]
    [imageUploadButton setBordered:YES];
    [imageUploadButton setFileKey:@"files"];
    [imageUploadButton allowsMultipleFiles:YES];
    [imageUploadButton setDelegate:pageController];
    [imageUploadButton setURL:@"/pages/"];

    theBundle = [CPBundle mainBundle],
    contentView = [theWindow contentView],
    _theWindowBounds = [contentView bounds];
    var center = [CPNotificationCenter defaultCenter];

    // [center addObserver:self selector:@selector(didOpenProject:) name:RodanDidLoadProjectNotification object:nil];
    [center addObserver:self selector:@selector(didLoadProject:) name:RodanDidLoadProjectNotification object:nil];
    // [center addObserver:self selector:@selector(showProjectsChooser:) name:RodanDidLoadProjectsNotification object:nil];
    // [center addObserver:self selector:@selector(didCloseProject:) name:RodanDidCloseProjectNotification object:nil];
    [center addObserver:self selector:@selector(didLogIn:) name:RodanDidLogInNotification object:nil];
    [center addObserver:self selector:@selector(mustLogIn:) name:RodanMustLogInNotification object:nil];
    [center addObserver:self selector:@selector(cannotLogIn:) name:RodanCannotLogInNotification object:nil];
    [center addObserver:self selector:@selector(cannotLogIn:) name:RodanLogInErrorNotification object:nil];
    [center addObserver:self selector:@selector(didLogOut:) name:RodanDidLogOutNotification object:nil];

    [theToolbar setVisible:NO];

    var statusToolbarIcon = [[CPImage alloc] initWithContentsOfFile:[theBundle pathForResource:@"toolbar-status.png"] size:CGSizeMake(32.0, 32.0)],
        pagesToolbarIcon = [[CPImage alloc] initWithContentsOfFile:[theBundle pathForResource:@"toolbar-images.png"] size:CGSizeMake(40.0, 32.0)],
        workflowResultsToolbarIcon = [[CPImage alloc] initWithContentsOfFile:[theBundle pathForResource:@"toolbar-workflows.png"] size:CGSizeMake(32.0, 32.0)],
        jobsToolbarIcon = [[CPImage alloc] initWithContentsOfFile:[theBundle pathForResource:@"toolbar-jobs.png"] size:CGSizeMake(32.0, 32.0)],
        usersToolbarIcon = [[CPImage alloc] initWithContentsOfFile:[theBundle pathForResource:@"toolbar-users.png"] size:CGSizeMake(46.0, 32.0)],
        backgroundTexture = [[CPImage alloc] initWithContentsOfFile:[theBundle pathForResource:@"workflow-backgroundTexture.png"] size:CGSizeMake(200.0, 200.0)];

    [statusToolbarItem setImage:statusToolbarIcon];
    [pagesToolbarItem setImage:pagesToolbarIcon];
    [workflowResultsToolbarItem setImage:workflowResultsToolbarIcon];
    [jobsToolbarItem setImage:jobsToolbarIcon];
    [usersToolbarItem setImage:usersToolbarIcon];

    [chooseWorkflowView setBackgroundColor:[CPColor colorWithPatternImage:backgroundTexture]];

    [contentView setAutoresizingMask:CPViewWidthSizable | CPViewHeightSizable];

    contentScrollView = [[CPScrollView alloc] initWithFrame:[contentView bounds]];
    [contentScrollView setAutoresizingMask:CPViewWidthSizable | CPViewHeightSizable];
    [contentScrollView setHasHorizontalScroller:YES];
    [contentScrollView setHasVerticalScroller:YES];
    [contentScrollView setAutohidesScrollers:YES];

    [contentView setSubviews:[contentScrollView]];

    // Load plugins.
    [PlugInsController setMenuItem:plugInsMenuItem];
    [PlugInsController loadPlugIns];
}


- (void)applicationDidFinishLaunching:(CPNotification)aNotification
{
    // This will catch a user and display a dialog if they try to leave the page. This
    // is to avoid any inadvertent forward/back behaviour if, e.g., they're scrolling in a table.
    window.onbeforeunload = function()
    {
        return "This will terminate the Application. Are you sure you want to leave?";
    }

    [CPMenu setMenuBarVisible:NO];
    var menubarIcon = [[CPImage alloc] initWithContentsOfFile:[theBundle pathForResource:@"menubar-icon.png"] size:CGSizeMake(16.0, 16.0)];
    [rodanMenuItem setImage:menubarIcon];

    [loginWaitScreenView setFrame:[contentScrollView bounds]];
    [loginWaitScreenView setAutoresizingMask:CPViewWidthSizable];
    [contentScrollView setDocumentView:loginWaitScreenView];
}

- (void)mustLogIn:(id)aNotification
{
    var blankView = [[CPView alloc] init];
    [contentScrollView setDocumentView:blankView];
    [authenticationController runLogInSheet];
}

- (void)cannotLogIn:(id)aNotification
{
    // display an alert that they cannot log in
    var alert = [[CPAlert alloc] init];
    [alert setTitle:@"Cannot Log In"];
    [alert setDelegate:self];
    [alert setMessageText:@"You cannot log in"];
    [alert setInformativeText:@"Please check your username and password. If you are still having difficulties, please contact an administrator."];
    [alert setShowsHelp:YES];
    [alert setAlertStyle:CPCriticalAlertStyle];
    [alert addButtonWithTitle:"Ok"];
    [alert runModal];
}

- (void)alertDidEnd:(CPAlert)alert returnCode:(int)returnCode
{
    /*
        The cannotLogIn alert has ended, informing the user they should try again. This will
        redirect them back to the login sheet.
    */
    [[CPNotificationCenter defaultCenter] postNotificationName:RodanMustLogInNotification
                                          object:nil];
}

- (void)didLogIn:(id)aNotification
{
    activeUser = [aNotification object];
    [projectController fetchProjects];
    [jobController fetchJobs];
}

- (void)didLogOut:(id)aNotification
{
    [projectController emptyProjectArrayController];
    [CPMenu setMenuBarVisible:NO];
    [theToolbar setVisible:NO];

    /*
        Once the user has logged out, redirect the screen to the login sheet.
    */
    [[CPNotificationCenter defaultCenter] postNotificationName:RodanMustLogInNotification
                                          object:nil];
}

- (@action)logOut:(id)aSender
{
    [authenticationController logOut];
}

- (void)didLoadProject:(CPNotification)aNotification
{
    [theWindow setTitle:@"Rodan &mdash; " + [activeProject projectName]];

    [CPMenu setMenuBarVisible:YES];
    [theToolbar setVisible:YES];

    [contentScrollView setDocumentView:projectStatusView];
    [projectStatusView setAutoresizingMask:CPViewWidthSizable];
    [projectStatusView setFrame:[contentScrollView bounds]];
}


#pragma mark -
#pragma mark Switch Workspaces

- (IBAction)switchWorkspaceToProjectStatus:(id)aSender
{
    [RKNotificationTimer clearTimedNotification];

    [menuItemsController reset];
    [menuItemsController setStatusIsActive:YES];

    [projectStatusView setAutoresizingMask:CPViewWidthSizable];
    [projectStatusView setFrame:[contentScrollView bounds]];
    [contentScrollView setDocumentView:projectStatusView];
}

- (IBAction)switchWorkspaceToManagePages:(id)aSender
{
    [RKNotificationTimer clearTimedNotification];

    [menuItemsController reset];
    [menuItemsController setPagesIsActive:YES];

    [managePagesView setAutoresizingMask:CPViewWidthSizable];
    [managePagesView setFrame:[contentScrollView bounds]];
    [contentScrollView setDocumentView:managePagesView];

    [[CPNotificationCenter defaultCenter] postNotificationName:RodanHasFocusPagesViewNotification
                                          object:nil];
}

- (IBAction)switchWorkspaceToWorkflowResults:(id)aSender
{
    [RKNotificationTimer clearTimedNotification];

    [menuItemsController reset];
    [menuItemsController setResultsIsActive:YES];

    [workflowResultsView setAutoresizingMask:CPViewWidthSizable];
    [workflowResultsView setFrame:[contentScrollView bounds]];
    [contentScrollView setDocumentView:workflowResultsView];

    [[CPNotificationCenter defaultCenter] postNotificationName:RodanHasFocusWorkflowResultsViewNotification
                                          object:nil];
}

- (IBAction)switchWorkspaceToInteractiveJobs:(id)aSender
{
    [RKNotificationTimer clearTimedNotification];

    [menuItemsController reset];
    [menuItemsController setJobsIsActive:YES];

    [interactiveJobsView setAutoresizingMask:CPViewWidthSizable];
    [interactiveJobsView setFrame:[contentScrollView bounds]];
    [contentScrollView setDocumentView:interactiveJobsView];

    [[CPNotificationCenter defaultCenter] postNotificationName:RodanHasFocusInteractiveJobsViewNotification
                                          object:nil];
}
- (void)observerDebug:(id)aNotification
{
    CPLog("Notification was Posted: " + [aNotification name]);
}
@end
