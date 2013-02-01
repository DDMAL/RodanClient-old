/*
 * AppController.j
 * Rodan
 *
 * Created by You on November 20, 2012.
 * Copyright 2012, Your Company All rights reserved.
 */

@import <Foundation/CPObject.j>
@import <AppKit/AppKit.j>
@import <FileUpload/FileUpload.j>
@import <Ratatosk/Ratatosk.j>

@import "Transformers/ArrayCountTransformer.j"
@import "Transformers/GameraClassNameTransformer.j"
@import "Transformers/CheckBoxTransformer.j"
@import "Transformers/UsernameTransformer.j"
@import "Transformers/ImageSizeTransformer.j"
@import "Transformers/DateFormatTransformer.j"

@import "Controllers/LogInController.j"
@import "Controllers/UserPreferencesController.j"
@import "Controllers/ServerAdminController.j"
@import "Controllers/WorkflowController.j"
@import "Controllers/ProjectController.j"
@import "Controllers/PageController.j"
@import "Controllers/JobController.j"
@import "Models/Project.j"

RodanDidOpenProjectNotification = @"RodanDidOpenProjectNotification";
RodanDidLoadProjectsNotification = @"RodanDidLoadProjectsNotification";
RodanDidLoadJobsNotification = @"RodanDidLoadJobsNotification";
RodanJobTreeNeedsRefresh = @"RodanJobTreeNeedsRefresh";

RodanMustLogInNotification = @"RodanMustLogInNotification";
RodanDidLogInNotification = @"RodanDidLogInNotification";
RodanCannotLogInNotification = @"RodanCannotLogInNotification";
RodanLogInErrorNotification = @"RodanLogInErrorNotification";
RodanDidLogOutNotification = @"RodanDidLogOutNotification";

isLoggedIn = NO;
activeUser = "";     // URI to the currently logged-in user
activeProject = "";  // URI to the currently open project

@implementation AppController : CPObject
{
    @outlet     CPWindow    theWindow;  //this "outlet" is connected automatically by the Cib
    @outlet     CPMenu      theMenu;
    @outlet     CPToolbar   theToolbar;
                CPBundle    theBundle;
    @outlet     CPWindow    logInWindow;

    @outlet     CPView      projectStatusView;
    @outlet     CPView      loginWaitScreenView;
    @outlet     CPView      selectProjectView;
    @outlet     CPView      manageWorkflowsView;
    @outlet     CPView      interactiveJobsView;
    @outlet     CPView      manageImagesView;
    @outlet     CPView      usersGroupsView;
    @outlet     CPView      workflowDesignerView;
                CPView      contentView;

    // @outlet     CPScrollView    contentScrollView;
                CPScrollView    contentScrollView;

    @outlet     CPWindow    userPreferencesWindow;
    @outlet     CPView      accountPreferencesView;

    @outlet     CPWindow    serverAdminWindow;
    @outlet     CPView      userAdminView;

    @outlet     CPWindow    newProjectWindow;
    @outlet     CPWindow    openProjectWindow;

    @outlet     CPWindow    newWorkflowWindow;

    @outlet     CPToolbarItem   statusToolbarItem;
    @outlet     CPToolbarItem   pagesToolbarItem;
    @outlet     CPToolbarItem   workflowsToolbarItem;
    @outlet     CPToolbarItem   jobsToolbarItem;
    @outlet     CPToolbarItem   usersToolbarItem;
    @outlet     CPToolbarItem   workflowDesignerToolbarItem;

    @outlet     ProjectController   projectController;
    @outlet     PageController      pageController;
    @outlet     JobController       jobController;
    @outlet     UploadButton        imageUploadButton;
    @outlet     LogInController     logInController;

    CGRect      _theWindowBounds;

                CPCookie        sessionID;
                CPCookie        CSRFToken;
                CPString        projectName;

}

+ (void)initialize
{
    [super initialize];
    [self registerValueTransformers];
}

+ (void)registerValueTransformers
{
    arrayCountTransformer = [[ArrayCountTransformer alloc] init];
    [ArrayCountTransformer setValueTransformer:arrayCountTransformer
                             forName:@"ArrayCountTransformer"];

    gameraClassNameTransformer = [[GameraClassNameTransformer alloc] init];
    [GameraClassNameTransformer setValueTransformer:gameraClassNameTransformer
                                forName:@"GameraClassNameTransformer"];

    usernameTransformer = [[UsernameTransformer alloc] init];
    [UsernameTransformer setValueTransformer:usernameTransformer
                                forName:@"UsernameTransformer"];

    imageSizeTransformer = [[ImageSizeTransformer alloc] init];
    [ImageSizeTransformer setValueTransformer:imageSizeTransformer
                                forName:@"ImageSizeTransformer"];

    dateFormatTransformer = [[DateFormatTransformer alloc] init];
    [DateFormatTransformer setValueTransformer:dateFormatTransformer
                                forName:@"DateFormatTransformer"];
}

- (id)awakeFromCib
{
    CPLogRegister(CPLogConsole);
    CPLog("AppController Awake From CIB");
    isLoggedIn = NO;

    [[LogInCheckController alloc] initCheckingStatus];

    sessionID = [[CPCookie alloc] initWithName:@"sessionid"];
    CSRFToken = [[CPCookie alloc] initWithName:@"csrftoken"];

    [[WLRemoteLink sharedRemoteLink] setDelegate:self];

    console.log([theWindow frame]);
    [theWindow setFullPlatformWindow:YES];

    [imageUploadButton setValue:[CSRFToken value] forParameter:@"csrfmiddlewaretoken"]
    [imageUploadButton setBordered:YES];
    [imageUploadButton setFileKey:@"files"];
    [imageUploadButton allowsMultipleFiles:YES];
    [imageUploadButton setDelegate:pageController];
    [imageUploadButton setURL:@"/pages/"];

    theBundle = [CPBundle mainBundle],
    contentView = [theWindow contentView],
    _theWindowBounds = [contentView bounds];
    var center = [CPNotificationCenter defaultCenter];

    [center addObserver:self selector:@selector(didOpenProject:) name:RodanDidOpenProjectNotification object:nil];
    [center addObserver:self selector:@selector(showProjectsChooser:) name:RodanDidLoadProjectsNotification object:nil];

    [center addObserver:self selector:@selector(didLogIn:) name:RodanDidLogInNotification object:nil];
    [center addObserver:self selector:@selector(mustLogIn:) name:RodanMustLogInNotification object:nil];
    [center addObserver:self selector:@selector(cannotLogIn:) name:RodanCannotLogInNotification object:nil];
    [center addObserver:self selector:@selector(cannotLogIn:) name:RodanLogInErrorNotification object:nil];
    [center addObserver:self selector:@selector(didLogOut:) name:RodanDidLogOutNotification object:nil];

    /* Debugging Observers */
    [center addObserver:self selector:@selector(observerDebug:) name:RodanDidOpenProjectNotification object:nil];
    [center addObserver:self selector:@selector(observerDebug:) name:RodanDidLoadProjectsNotification object:nil];
    /* ------------------- */

    [theToolbar setVisible:NO];

    var statusToolbarIcon = [[CPImage alloc] initWithContentsOfFile:[theBundle pathForResource:@"toolbar-status.png"] size:CGSizeMake(32.0, 32.0)],
        statusToolbarIconSelected = [[CPImage alloc] initWithContentsOfFile:[theBundle pathForResource:@"toolbar-status-selected.png"] size:CGSizeMake(32.0, 32.0)],
        pagesToolbarIcon = [[CPImage alloc] initWithContentsOfFile:[theBundle pathForResource:@"toolbar-images.png"] size:CGSizeMake(40.0, 32.0)],
        pagesToolbarIconSelected = [[CPImage alloc] initWithContentsOfFile:[theBundle pathForResource:@"toolbar-images-selected.png"] size:CGSizeMake(40.0, 32.0)],
        workflowsToolbarIcon = [[CPImage alloc] initWithContentsOfFile:[theBundle pathForResource:@"toolbar-workflows.png"] size:CGSizeMake(32.0, 32.0)],
        workflowsToolbarIconSelected = [[CPImage alloc] initWithContentsOfFile:[theBundle pathForResource:@"toolbar-workflows-selected.png"] size:CGSizeMake(32.0, 32.0)],
        jobsToolbarIcon = [[CPImage alloc] initWithContentsOfFile:[theBundle pathForResource:@"toolbar-jobs.png"] size:CGSizeMake(32.0, 32.0)],
        jobsToolbarIconSelected = [[CPImage alloc] initWithContentsOfFile:[theBundle pathForResource:@"toolbar-jobs-selected.png"] size:CGSizeMake(32.0, 32.0)],
        usersToolbarIcon = [[CPImage alloc] initWithContentsOfFile:[theBundle pathForResource:@"toolbar-users.png"] size:CGSizeMake(46.0, 32.0)],
        usersToolbarIconSelected = [[CPImage alloc] initWithContentsOfFile:[theBundle pathForResource:@"toolbar-users-selected.png"] size:CGSizeMake(46.0, 32.0)];

    [statusToolbarItem setImage:statusToolbarIcon];
    [statusToolbarItem setAlternateImage:statusToolbarIconSelected];
    [pagesToolbarItem setImage:pagesToolbarIcon];
    [pagesToolbarItem setAlternateImage:pagesToolbarIconSelected];
    [workflowsToolbarItem setImage:workflowsToolbarIcon];
    [workflowsToolbarItem setAlternateImage:workflowsToolbarIconSelected];
    [jobsToolbarItem setImage:jobsToolbarIcon];
    [jobsToolbarItem setAlternateImage:jobsToolbarIconSelected];
    [usersToolbarItem setImage:usersToolbarIcon];
    [usersToolbarItem setAlternateImage:usersToolbarIconSelected];

    [contentView setAutoresizingMask:CPViewWidthSizable | CPViewHeightSizable];

    contentScrollView = [[CPScrollView alloc] initWithFrame:[contentView bounds]];
    [contentScrollView setAutoresizingMask:CPViewWidthSizable | CPViewHeightSizable];
    [contentScrollView setHasHorizontalScroller:YES];
    [contentScrollView setHasVerticalScroller:YES];
    [contentScrollView setAutohidesScrollers:YES];

    [contentView setSubviews:[contentScrollView]];
}


- (void)applicationDidFinishLaunching:(CPNotification)aNotification
{

    window.onbeforeunload = function()
    {
        return "This will terminate the Application. Are you sure you want to leave?";
    }

    CPLog("Application Did Finish Launching");
    [loginWaitScreenView setFrame:[contentScrollView bounds]];
    [loginWaitScreenView setAutoresizingMask:CPViewWidthSizable];
    [contentScrollView setDocumentView:loginWaitScreenView];
}

- (void)mustLogIn:(id)aNotification
{
    var blankView = [[CPView alloc] init];
    [contentScrollView setDocumentView:blankView];
    [logInController runLogInSheet];
}

- (void)cannotLogIn:(id)aNotification
{
    CPLog("Cannot log in called");
    isLoggedIn = NO;
    // display an alert that they cannot log in
    var alert = [[CPAlert alloc] init];
    [alert setTitle:@"Cannot Log In"];
    [alert setMessageText:@"You cannot log in"];
    [alert setInformativeText:@"Please check your username and password. If you are still having difficulties, please contact an administrator."];
    [alert setShowsHelp:YES];
    [alert setAlertStyle:CPInformationalAlertStyle];
    [alert addButtonWithTitle:"Ok"];
    [alert runModal];
}

- (void)didLogIn:(id)aNotification
{
    CPLog("Did Log In Successfully.");
    var authResponse = [aNotification object];

    isLoggedIn = YES;
    activeUser = [authResponse valueForKey:@"user"];

    [projectController fetchProjects];
    [jobController fetchJobs];
}

- (void)didLogOut:(id)aNotification
{
    // [contentScrollView setDocumentView:];
    [projectController emptyProjectArrayController];
    [[CPNotificationCenter defaultCenter] postNotificationName:RodanMustLogInNotification
                                      object:nil];
}

- (void)showProjectsChooser:(id)aNotification
{
    [selectProjectView setFrame:[contentScrollView bounds]];
    [selectProjectView setAutoresizingMask:CPViewWidthSizable];
    [contentScrollView setDocumentView:selectProjectView];
}

- (IBAction)logOut:(id)aSender
{
    [LogOutController logOut];
}

- (IBAction)switchWorkspace:(id)aSender
{
    CPLog("switchWorkspace called");
    console.log([contentScrollView subviews]);
    switch ([aSender itemIdentifier])
    {
        case @"statusToolbarButton":
            CPLog("Status Button!");
            [projectStatusView setFrame:[contentScrollView bounds]];
            [projectStatusView setAutoresizingMask:CPViewWidthSizable];
            [contentScrollView setDocumentView:projectStatusView];
            break;
        case @"manageImagesToolbarButton":
            CPLog("Manage Images!");
            [manageImagesView setFrame:[contentScrollView bounds]];
            [manageImagesView setAutoresizingMask:CPViewWidthSizable];
            [contentScrollView setDocumentView:manageImagesView];
            break;
        case @"manageWorkflowsToolbarButton":
            CPLog("Manage Workflows!");
            [manageWorkflowsView setFrame:[contentScrollView bounds]];
            [manageWorkflowsView setAutoresizingMask:CPViewWidthSizable];
            [contentScrollView setDocumentView:manageWorkflowsView];
            break;
        case @"interactiveJobsToolbarButton":
            CPLog("Interactive Jobs!");
            [interactiveJobsView setFrame:[contentScrollView bounds]];
            [interactiveJobsView setAutoresizingMask:CPViewWidthSizable];
            [contentScrollView setDocumentView:interactiveJobsView];
            break;
        case @"usersGroupsToolbarButton":
            CPLog("Users and Groups!");
            [usersGroupsView setFrame:[contentScrollView bounds]];
            [usersGroupsView setAutoresizingMask:CPViewWidthSizable];
            [contentScrollView setDocumentView:usersGroupsView];
            break;
        case @"workflowDesignerToolbarButton":
            CPLog("Workflow Designer!");
            [workflowDesignerView setFrame:[contentScrollView bounds]];
            [workflowDesignerView layoutIfNeeded];
            [contentScrollView setDocumentView:workflowDesignerView];
            break;
        default:
            console.log("Unknown identifier");
            break;
    }
}

- (void)didOpenProject:(CPNotification)aNotification
{
    activeProject = [aNotification object];

    [imageUploadButton setValue:[activeProject resourceURI] forParameter:@"project"];
    [pageController createObjectsWithJSONResponse:activeProject];

    projectName = [[aNotification object] projectName];
    [theWindow setTitle:@"Rodan — " + projectName];
    [theToolbar setVisible:YES];

    [projectStatusView setFrame:[contentScrollView bounds]];
    [projectStatusView setAutoresizingMask:CPViewWidthSizable];
    [contentScrollView setDocumentView:projectStatusView];
}

- (IBAction)openUserPreferences:(id)aSender
{
    [userPreferencesWindow center];
    var preferencesContentView = [userPreferencesWindow contentView];
    [preferencesContentView addSubview:accountPreferencesView];
    [userPreferencesWindow orderFront:aSender];
}

- (IBAction)openServerAdmin:(id)aSender
{
    [serverAdminWindow center];
    var serverAdminContentView = [serverAdminWindow contentView];
    [serverAdminContentView addSubview:userAdminView];
    [serverAdminWindow orderFront:aSender];
}

- (IBAction)closeProject:(id)aSender
{
    CPLog("Close Project");
    var alert = [[CPAlert alloc] init];
    [alert setTitle:"Informational Alert"];
    [alert setMessageText:"Informational Alert"];
    [alert setInformativeText:"CPAlerts can also be used as sheets! With the same options as before."];
    [alert setShowsHelp:YES];
    [alert setShowsSuppressionButton:YES];
    [alert setAlertStyle:CPInformationalAlertStyle];
    [alert addButtonWithTitle:"Okay"];

    var closeProjectController = [[SheetController alloc] init];
    [alert setDelegate:closeProjectController];
    [closeProjectController setSheet:alert];
    [closeProjectController beginSheet]
}

- (void)observerDebug:(id)aNotification
{
    CPLog("Notification was Posted: " + [aNotification name]);
}

#pragma mark WLRemoteLink Delegate

- (void)remoteLink:(WLRemoteLink)aLink willSendRequest:(CPURLRequest)aRequest withDelegate:(id)aDelegate context:(id)aContext
{
    switch ([[aRequest HTTPMethod] uppercaseString])
    {
        case "POST":
        case "PUT":
        case "PATCH":
        case "DELETE":
            [aRequest setValue:[CSRFToken value] forHTTPHeaderField:"X-CSRFToken"];
    }
}
@end


@implementation SheetController : CPObject
{
    CPAlert sheet @accessors;
}

- (void)beginSheet
{
    CPLog("Beginning Sheet");
    [sheet beginSheetModalForWindow:[CPApp mainWindow]];
}

- (void)alertDidEnd:(CPAlert)theAlert returnCode:(int)returnCode
{
    CPLog("Alert did End returning " + returnCode);
}
@end
