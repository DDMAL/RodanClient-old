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

@implementation AppController : RKController
{
    @outlet     PlugInsController           plugInsController;
    @outlet     AuthenticationController    authenticationController;
    @outlet     JobController               jobController;
    @outlet     PageController              pageController;
    @outlet     ProjectController           projectController;
    @outlet     WorkflowController          workflowController;
    @outlet     WorkspaceController         workspaceController;
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
}

- (void)applicationDidFinishLaunching:(CPNotification)aNotification
{
    [plugInsController loadPlugIns];
    [authenticationController checkIsAuthenticated];
}

- (void)didLogIn:(id)aNotification
{
    [RKNotificationTimer clearTimedNotification];
    [workspaceController clearView];
}

- (void)didLogOut:(id)aNotification
{
    [RKNotificationTimer clearTimedNotification];
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