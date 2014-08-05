@import <Ratatosk/WLRemoteObject.j>
@import "RKModel.j"
@import "Result.j"
@import "Resource.j"
@import "../Transformers/JobArgumentsTransformer.j"
@import "../Transformers/RunJobSettingsTransformer.j"

RUNJOB_STATUS_FAILED = -1,
RUNJOB_STATUS_NOTRUNNING = 0,
RUNJOB_STATUS_RUNNING = 1,
RUNJOB_STATUS_WAITINGFORINPUT = 2,
RUNJOB_STATUS_RUNONCEWAITING = 3,
RUNJOB_STATUS_HASFINISHED = 4,
RUNJOB_STATUS_CANCELLED = 9;

@implementation RunJob : RKModel
{
    CPString            jobName             @accessors;
    CPString            workflowName        @accessors;
    CPString            workflowRun         @accessors;
    CPString            workflowJob         @accessors;

    CPArray             inputs              @accessors;
    CPArray             outputs             @accessors;

    CPNumber            sequence            @accessors;
    CPArray             result              @accessors;
    CPMutableDictionary jobSettings         @accessors;
    CPArray             jobSettingsArray    @accessors;
    
    BOOL                needsInput          @accessors;
    CPNumber            status              @accessors;

    // this uses a simplified page object instead of the full one via Ratatosk. It's just the page name and url.
    CPArray             resources           @accessors; //need to change to resource? 
    CPDate              created             @accessors;
    CPDate              updated             @accessors;
    CPString            errorSummary        @accessors;
    CPString            errorDetails        @accessors;
}

+ (CPArray)remoteProperties
{
    return [
        ['pk', 'url', nil, true],
        ['uuid', 'uuid'],
        ['jobName', 'job_name'],
        ['sequence', 'sequence'],
        ['status', 'status'],
        ['needsInput', 'needs_input'],
        ['workflowName', 'workflow_name'],
        ['jobSettings', 'job_settings', [[RunJobSettingsTransformer alloc] init]],
        ['jobSettingsArray', 'job_settings', [[JobArgumentsTransformer alloc] init]],
        ['result', 'result', [WLForeignObjectsTransformer forObjectClass:Result]],
        ['resources', 'resources'],
        ['created', 'created', [[WLDateTransformer alloc] init], true],
        ['updated', 'updated', [[WLDateTransformer alloc] init], true],
        ['errorSummary', 'error_summary'],
        ['errorDetails', 'error_details']
    ];
}

/**
 * Returns the last component of the pk URL, which is the UUID of the RunJob.
 * If pk is nil, returns nil.
 */
- (CPString)getUUID
{
    var runJobUUID = nil;
    if ([self pk])
    {
        runJobUUID = [pk lastPathComponent];
    }
    return runJobUUID;
}

/**
 * Convenience method for enabling/disabling "View Error Details" button.
 */
- (BOOL)didFail
{
    return [self status] == -1;
}

- (CPString)remotePath
{
    if ([self pk])
        return [self pk]
    else
        return [[CPBundle mainBundle] objectForInfoDictionaryKey:"ServerHost"] + @"/runjobs/";
}

- (BOOL)canRunInteractive
{
    return [self status] == 2 || [self status] == 3;
}

@end
