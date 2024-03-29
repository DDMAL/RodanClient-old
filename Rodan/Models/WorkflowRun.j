@import <Ratatosk/WLRemoteObject.j>
@import "../Transformers/RunJobStatusTransformer.j"
@import "RunJob.j"
@import "User.j"
@import "Page.j"

@global RUNJOB_STATUS_FAILED
@global RUNJOB_STATUS_NOTRUNNING
@global RUNJOB_STATUS_RUNNING
@global RUNJOB_STATUS_WAITINGFORINPUT
@global RUNJOB_STATUS_RUNONCEWAITING
@global RUNJOB_STATUS_HASFINISHED
@global RUNJOB_STATUS_CANCELLED

/**
 * WorkflowRun model.
 */
@implementation WorkflowRun : WLRemoteObject
{
    CPString    pk          @accessors;
    CPString    uuid        @accessors;
    CPNumber    run         @accessors;
    CPString    workflowURL @accessors;
    CPDate      created     @accessors;
    CPString    runCreator  @accessors;
    CPDate      updated     @accessors;
    BOOL        testRun     @accessors;
    CPString    testPageID  @accessors;
    CPArray     pages       @accessors;
    BOOL        cancelled   @accessors;
}

+ (CPArray)remoteProperties
{
    return [
        ['pk', 'url'],
        ['uuid', 'uuid'],
        ['workflowURL', 'workflow'],
        ['pages', 'pages', [WLForeignObjectsTransformer forObjectClass:Page]],
        ['runCreator', 'creator', [WLForeignObjectTransformer forObjectClass:User]],
        ['run', 'run'],
        ['created', 'created', [[WLDateTransformer alloc] init], true],
        ['updated', 'updated', [[WLDateTransformer alloc] init], true],
        ['testRun', 'test_run'],
        ['cancelled', 'cancelled']
    ];
}

/**
 * This modifies the request path so that we can launch a test run.
 */
- (CPString)postPath
{
    var pathComponents = @"";
    if (testRun)
        pathComponents = "?test=true&page_id=" + testPageID;
    return [self remotePath] + pathComponents;
}

/**
 * Returns the remote path.
 */
- (CPString)remotePath
{
    if ([self pk])
    {
        return [self pk]
    }
    else
    {
        return @"/workflowruns/";
    }
}

/* This modifies the request path so that we can launch a test run */
- (CPString)postPath
{
    var pathComponents = @"";
    if (testRun)
        pathComponents = "?test=true&page_id=" + testPageID;
    return [self remotePath] + pathComponents;
}

/**
 * We override WLRemoteObject::isEqual to make sure that other WLRemoteObjects that have this class as a member (e.g. Workflow)
 * don't just look at the PK and class (which is what isEqual does by default).
 *
 * We can create a custom list of fields that override WLRemoteObject equality, but for now it's just the 'updated' member.
 */
- (BOOL)isEqual:(id)aObject
{
    if ([super isEqual:aObject])
    {
        if ([self updated] === [aObject updated])
        {
            return YES;
        }
    }
    return NO;
}

/**
 * Override for WLRemoteLink::remoteActionDidFail.
 * We need to cancel the action.
 */
- (void)remoteActionDidFail:(WLRemoteAction)aAction
{
    if (aAction != nil)
    {
        [aAction cancel];
    }
}

@end
