@import <Foundation/CPObject.j>
@import <RodanKit/Job.j>
@import <RodanKit/ResultsPackage.j>
@import <RodanKit/WorkflowRun.j>
@import "../AppController.j"

@global RodanRequestWorkflowResultsPackagesNotification
@global RodanRequestWorkflowRunsJobsNotification
@global activeUser
@global activeProject

var RADIOTAG_ALL = 1,
    RADIOTAG_SELECTED = 0;

@implementation ResultsPackageController : RKController
{
    @outlet ResultsViewRunsDelegate _runsDelegate;
    @outlet CPArrayController       _jobsArrayController;
    @outlet CPArrayController       _resultsPackagesArrayController;
    @outlet CPArrayController       _workflowPagesArrayController;
    @outlet CPMatrix                _pageRadioGroup;
    @outlet CPMatrix                _jobRadioGroup;
    @outlet CPTableView             _pageTableView;
    @outlet CPTableView             _jobTableView;
    @outlet CPWindow                _createResultsPackageWindow;
}

////////////////////////////////////////////////////////////////////////////////////////////
// Init Methods
////////////////////////////////////////////////////////////////////////////////////////////
- (id)init
{
    self = [super init];
    if (self)
    {
        [[CPNotificationCenter defaultCenter] addObserver:self
                                              selector:@selector(handleShouldLoadWorkflowResultsPackagesNotification:)
                                              name:RodanRequestWorkflowResultsPackagesNotification
                                              object:nil];
        [[CPNotificationCenter defaultCenter] addObserver:self
                                              selector:@selector(handleShouldLoadWorkfowRunsJobsNotification:)
                                              name:RodanRequestWorkflowRunsJobsNotification
                                              object:nil];
    }

    return self;
}

- (void)awakeFromCib
{
}

////////////////////////////////////////////////////////////////////////////////////////////
// Action Methods
////////////////////////////////////////////////////////////////////////////////////////////
/**
 * Opens the create results package window.
 */
- (@action)openCreateResultsPackageWindow:(id)aSender
{
    [_resultsPackagesArrayController setContent: nil];
    [_jobsArrayController setContent: nil];
    [self handleShouldLoadWorkflowResultsPackagesNotification:nil];
    [CPApp beginSheet:_createResultsPackageWindow
           modalForWindow:[CPApp mainWindow]
           modalDelegate:self
           didEndSelector:@selector(didEndSheet:returnCode:contextInfo:) contextInfo:nil];
}

/**
 * Closes the create results package window.
 */
- (@action)closeCreateResultsPackageWindow:(id)aSender
{
    [CPApp endSheet:_createResultsPackageWindow returnCode:[aSender tag]];
}

/**
 * Handles the create package request.
 */
- (@action)handleCreatePackageRequest:(id)aSender
{
    var resultsPackage = [[ResultsPackage alloc] init];
    [resultsPackage setWorkflowRunUrl:[[_runsDelegate currentlySelectedWorkflowRun] pk]];
    [resultsPackage setCreator:[activeUser pk]];

    // Check for selected pages.
    if ([[_pageRadioGroup selectedRadio] tag] != RADIOTAG_ALL)
    {
        var pageEnumerator = [[self _getSelectedPages] objectEnumerator],
            page = nil,
            pageUrlArray = [[CPMutableArray alloc] init];
        while (page = [pageEnumerator nextObject])
        {
            [pageUrlArray addObject:[page pk]];
        }
        [resultsPackage setPageUrls:pageUrlArray];
    }

    // Check for selected jobs.
    if ([[_jobRadioGroup selectedRadio] tag] != RADIOTAG_ALL)
    {
        var jobEnumerator = [[self _getSelectedJobs] objectEnumerator],
            job = nil,
            jobUrlArray = [[CPMutableArray alloc] init];
        while (job = [jobEnumerator nextObject])
        {
            [jobUrlArray addObject:[job pk]];
        }
        [resultsPackage setJobUrls:jobUrlArray];
    }
    [resultsPackage ensureCreated];
}

/**
 * Handles page radio button action.
 */
- (@action)handlePageRadioAction:(id)aSender
{
    [_pageTableView setEnabled: [[_pageRadioGroup selectedRadio] tag] != RADIOTAG_ALL];
    return YES;
}

/**
 * Handles job radio button action.
 */
- (@action)handleJobRadioAction:(id)aSender
{
    [_jobTableView setEnabled: [[_jobRadioGroup selectedRadio] tag] != RADIOTAG_ALL];
    return YES;
}

/**
 * Handles download of results package.
 */
- (@action)handleDownload:(id)aSender
{
    if ([[_resultsPackagesArrayController selectedObjects] count] > 0)
    {
        var resultsPackage = [[_resultsPackagesArrayController selectedObjects] objectAtIndex:0];
        if ([resultsPackage percentCompleted] == 100)
        {
            window.open([resultsPackage downloadUrl], "_blank");
        }
    }
}

////////////////////////////////////////////////////////////////////////////////////////////
// Handler Methods
////////////////////////////////////////////////////////////////////////////////////////////
- (void)handleShouldLoadWorkflowResultsPackagesNotification:(id)aSender
{
    if ([_runsDelegate currentlySelectedWorkflowRun] != nil)
    {
        [self _requestResultsPackages:[_runsDelegate currentlySelectedWorkflowRun]];
    }
}

- (void)handleShouldLoadWorkfowRunsJobsNotification:(id)aSender
{
    if ([_runsDelegate currentlySelectedWorkflowRun] != nil)
    {
        [self _requestJobs:[_runsDelegate currentlySelectedWorkflowRun]];
    }
}

/**
 * Handles success of loading.
 */
- (void)remoteActionDidFinish:(WLRemoteAction)aAction
{
    if ([aAction result])
    {
        switch ([aAction message])
        {
            case RodanRequestWorkflowResultsPackagesNotification:
                [self _processRemoteActionResultPackages:aAction];
                break;

            case  RodanRequestWorkflowRunsJobsNotification:
                [self _processRemoteActionWorkflowJobs:aAction];
                break;

            default:
                return;
        }
    }
}

/**
 * Handler for window close.
 */
- (void)didEndSheet:(CPWindow)aSheet returnCode:(int)returnCode contextInfo:(id)contextInfo
{
    [aSheet orderOut:self];
}

////////////////////////////////////////////////////////////////////////////////////////////
// Private Methods
////////////////////////////////////////////////////////////////////////////////////////////
- (void)_requestResultsPackages:(WorkflowRun)aWorkflowRun
{
    var getParameters = @"?workflowrun=" + [aWorkflowRun pk];
    getParameters += @"&creator=" + [activeUser pk];
    [WLRemoteAction schedule:WLRemoteActionGetType
                    path:[[CPBundle mainBundle] objectForInfoDictionaryKey:"ServerHost"] + @"/resultspackages/" + getParameters
                    delegate:self
                    message:RodanRequestWorkflowResultsPackagesNotification
                    withCredentials:YES];
}
- (void)_requestJobs:(WorkflowRun)aWorkflowRun
{
    var getParameters = @"?workflowrun=" + [aWorkflowRun pk];
    [WLRemoteAction schedule:WLRemoteActionGetType
                    path:[[CPBundle mainBundle] objectForInfoDictionaryKey:"ServerHost"] + @"/jobs/" + getParameters
                    delegate:self
                    message:RodanRequestWorkflowRunsJobsNotification
                    withCredentials:YES];
}

- (void)_processRemoteActionResultPackages:(WLRemoteAction)aAction
{
    [WLRemoteObject setDirtProof:YES];
    [_resultsPackagesArrayController setContent: [ResultsPackage objectsFromJson:[aAction result]]];
    [WLRemoteObject setDirtProof:NO];
}

- (void)_processRemoteActionWorkflowJobs:(WLRemoteAction)aAction
{
    [WLRemoteObject setDirtProof:YES];
    [_jobsArrayController setContent: [Job objectsFromJson:[aAction result]]];
    [WLRemoteObject setDirtProof:NO];
}

- (CPArray)_getSelectedPages
{
    var selectedObjects = [[CPArray alloc] init];
    if ([[_pageRadioGroup selectedRadio] tag] != RADIOTAG_ALL)
    {
        selectedObjects = [_workflowPagesArrayController selectedObjects];
    }
    return selectedObjects;
}

- (CPArray)_getSelectedJobs
{
    var selectedObjects = [[CPArray alloc] init];
    if ([[_jobRadioGroup selectedRadio] tag] != RADIOTAG_ALL)
    {
        selectedObjects = [_jobsArrayController selectedObjects];
    }
    return selectedObjects;
}
@end
