@import <Foundation/CPTimer.j>
@import <RodanKit/RunJob.j>
@import <RodanKit/RKInteractiveJob.j>
@import <RodanKit/RKNotificationTimer.j>

@global RodanHasFocusInteractiveJobsViewNotification
@global RodanRequestInteractiveJobsNotification
@global activeProject

var _LOADINTERVAL = 5.0,
    _JOBNAME_CLASSIFIER = "gamera.custom.neume_classification.manual_classification";

/**
 * General interactive jobs controller.
 */
@implementation InteractiveJobsController : RKController
{
    @outlet CPTableView                 interactiveJobsTableView;
    @outlet CPArrayController           interactiveJobsArrayController  @accessors(readonly);
    @outlet ClassifierViewController    _classifierViewController;
}

- (void)awakeFromCib
{
    // Register self to listen for interactive job array loading (and success).
    [[CPNotificationCenter defaultCenter] addObserver:self
                                          selector:@selector(shouldLoad:)
                                          name:RodanRequestInteractiveJobsNotification
                                          object:nil];
    [[CPNotificationCenter defaultCenter] addObserver:self
                                          selector:@selector(receiveHasFocusEvent:)
                                          name:RodanHasFocusInteractiveJobsViewNotification
                                          object:nil];
}

- (void)receiveHasFocusEvent:(CPNotification)aNotification
{
    [RKNotificationTimer setTimedNotification:_LOADINTERVAL
                         notification:RodanRequestInteractiveJobsNotification];
}

/**
 * Handles the request to load interactive jobs.
 */
- (void)shouldLoad:(CPNotification)aNotification
{
    var projectUUID = nil;
    if (activeProject != nil)
    {
        projectUUID = [activeProject uuid];
    }
    [WLRemoteAction schedule:WLRemoteActionGetType
                    path:[[CPBundle mainBundle] objectForInfoDictionaryKey:"ServerHost"] + "/runjobs/?requires_interaction=true&project=" + projectUUID
                    delegate:self
                    message:"Retrieving RunJobs"
                    withCredentials:YES];
}

/**
 * Handles success of interactive jobs loading.
 */
- (void)remoteActionDidFinish:(WLRemoteAction)aAction
{
    if ([aAction result])
    {
        var runJobs = [RunJob objectsFromJson:[aAction result]];
        [interactiveJobsArrayController setContent:runJobs];
    }
}

/**
 * Loads interactive job window.
 */
- (@action)displayInteractiveJobWindow:(id)aSender
{
    var runJob = [[interactiveJobsArrayController selectedObjects] objectAtIndex:0];
    [self runInteractiveRunJob:runJob fromSender:aSender];
}

/**
 * Attempts to start interactive run job given run job.
 */
- (void)runInteractiveRunJob:(RunJob)aRunJob fromSender:(id)aSender
{
    if (aRunJob == nil || ![aRunJob needsInput])
    {
        return;
    }

    // If we're dealing with special case classifier, deal with it.
    if ([aRunJob jobName] === _JOBNAME_CLASSIFIER)
    {
        [_classifierViewController workRunJob:aRunJob];
        return;
    }

    // Get the UUID and give it to a new window.
    var newPlatformWindow = [[CPPlatformWindow alloc] initWithContentRect:CGRectMake(0, 0, 800, 600)],
        runJobUUID = [aRunJob getUUID],
        jobName = [aRunJob jobName],
        jobWindow = [[RKInteractiveJobWindow alloc] initWithContentRect:CGRectMake(0, 0, 800, 600)
                                                    styleMask:CPClosableWindowMask | CPResizableWindowMask
                                                    runJobUUID:runJobUUID
                                                    jobName:jobName];
    [jobWindow setFullPlatformWindow:YES];
    [jobWindow setPlatformWindow:newPlatformWindow];
    [jobWindow center];
    [jobWindow makeKeyAndOrderFront:aSender];
}

//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// DELEGATE METHODS
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
/**
 * Handle row selection.
 */
- (BOOL)tableView:(CPTableView)aTableView shouldSelectRow:(int)aRowIndex
{
    return YES;
}

@end
