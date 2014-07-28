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
@import "Controllers/PageController.j"
@import "Controllers/PlugInsController.j"
@import "Controllers/ProjectController.j"
@import "Controllers/ResultsPackageController.j"
@import "Controllers/WorkspaceController.j"
@import "Frameworks/RodanKit/Controllers/WorkflowController.j"
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
RodanDidLoadJobsNotification = @"RodanDidLoadJobsNotification";
RodanDidLoadWorkflowNotification = @"RodanDidLoadWorkflowNotification";
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

// Focus events.
RodanHasFocusInteractiveJobsViewNotification = @"RodanHasFocusInteractiveJobsViewNotification";
RodanHasFocusWorkflowResultsViewNotification = @"RodanHasFocusWorkflowResultsViewNotification";
RodanHasFocusPagesViewNotification = @"RodanHasFocusPagesViewNotification";
RodanHasFocusProjectListViewNotification = @"RodanHasFocusProjectListViewNotification";

activeProject = nil;  // URI to the currently open project

@implementation AppController : CPObject
{
    @outlet     TNToolbar                   theToolbar  @accessors(readonly);
    @outlet     CPView                      workflowResultsView;
    @outlet     CPView                      interactiveJobsView;
    @outlet     CPView                      managePagesView;
    @outlet     CPView                      chooseWorkflowView;
    @outlet     CPToolbarItem               pagesToolbarItem;
    @outlet     CPToolbarItem               workflowResultsToolbarItem;
    @outlet     CPToolbarItem               jobsToolbarItem;
    @outlet     CPButtonBar                 workflowAddRemoveBar;
    @outlet     CPMenu                      switchWorkspaceMenu;
    @outlet     PlugInsController           plugInsController;
    @outlet     CPMenuItem                  plugInsMenuItem;
    @outlet     AuthenticationController    authenticationController;
    @outlet     JobController               jobController @accessors(readonly);
    @outlet     PageController              pageController;
    @outlet     ProjectController           projectController;
    @outlet     UploadButton                imageUploadButton;
    @outlet     WorkflowController          workflowController;
    @outlet     WorkspaceController         workspaceController;

    CPString    projectName;

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
    [self _registerMessageListening];

    [imageUploadButton setBordered:YES];
    [imageUploadButton setFileKey:@"files"];
    [imageUploadButton allowsMultipleFiles:YES];
    [imageUploadButton setDelegate:pageController];
    [imageUploadButton setURL:@"/pages/"];

    [theToolbar setVisible:NO];
    var pagesToolbarIcon = [[CPImage alloc] initWithContentsOfFile:[[CPBundle mainBundle] pathForResource:@"toolbar-images.png"] size:CGSizeMake(40.0, 32.0)],
        workflowResultsToolbarIcon = [[CPImage alloc] initWithContentsOfFile:[[CPBundle mainBundle] pathForResource:@"toolbar-workflows.png"] size:CGSizeMake(32.0, 32.0)],
        jobsToolbarIcon = [[CPImage alloc] initWithContentsOfFile:[[CPBundle mainBundle] pathForResource:@"toolbar-jobs.png"] size:CGSizeMake(32.0, 32.0)],
        backgroundTexture = [[CPImage alloc] initWithContentsOfFile:[[CPBundle mainBundle] pathForResource:@"workflow-backgroundTexture.png"] size:CGSizeMake(200.0, 200.0)];
    [pagesToolbarItem setImage:pagesToolbarIcon];
    [workflowResultsToolbarItem setImage:workflowResultsToolbarIcon];
    [jobsToolbarItem setImage:jobsToolbarIcon];

    [chooseWorkflowView setBackgroundColor:[CPColor colorWithPatternImage:backgroundTexture]];
}

- (void)applicationDidFinishLaunching:(CPNotification)aNotification
{
    [plugInsController loadPlugIns];
    [authenticationController checkIsAuthenticated];
}

- (void)didLogIn:(id)aNotification
{
    [workspaceController switchWorkspaceToProjects:nil];
}

- (void)didLogOut:(id)aNotification
{
    [workspaceController clearView];
    [authenticationController checkIsAuthenticated];
}

///////////////////////////////////////////////////////////////////////////////
// Private Methods
///////////////////////////////////////////////////////////////////////////////
#pragma mark Private Methods
- (void)_registerMessageListening
{
    [[CPNotificationCenter defaultCenter] addObserver:self selector:@selector(didLogIn:) name:RodanDidLogInNotification object:nil];
    [[CPNotificationCenter defaultCenter] addObserver:self selector:@selector(didLogOut:) name:RodanDidLogOutNotification object:nil];
}
@end