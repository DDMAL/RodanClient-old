@import "RKModel.j"
@import "../../Ratatosk/WLRemoteTransformers.j"

JOBSETTING_TYPE_INT = @"int",
JOBSETTING_TYPE_REAL = @"real",
JOBSETTING_TYPE_UUIDWORKFLOWJOB = @"uuid_workflowjob",
JOBSETTING_TYPE_CHOICE = @"choice",
JOBSETTING_TYPE_UUIDCLASSIFIER = @"uuid_classifier";

@implementation Job : RKModel
{
    CPString        jobName             @accessors;
    CPString        shortJobName        @accessors;
    CPArray         settings            @accessors;

    CPArray         inputPortTypes      @accessors;
    CPArray         outputPortTypes     @accessors;

    CPString        description         @accessors;
    CPString        category            @accessors;


    BOOL            isEnabled           @accessors;
    BOOL            isInteractive       @accessors;

    CPImage         sourceListIcon      @accessors;
}

- (id)init
{
    if (self = [super init])
    {
        sourceListIcon = [[CPImage alloc] initWithContentsOfFile:[[CPBundle mainBundle] pathForResource:@"job-sourcelist-icon.png"]
                                  size:CGSizeMake(16.0, 16.0)];

        shortJobName = [self shortJobName];

    }
    return self;
}

- (CPString)shortJobName
{
    var shortName = jobName,
        splitString = [shortName componentsSeparatedByString:"."];
    if ([splitString count] > 1)
    {
        shortName = [[splitString lastObject] stringByReplacingOccurrencesOfString:@"_" withString:@" "];
        return [shortName capitalizedString];
    }
    return shortName;
}


+ (CPArray)remoteProperties
{
    return [
        ['pk', 'url'],
        ['jobName', 'job_name'],
        ['settings', 'settings'],
        ['inputPortTypes', 'input_port_types'],
        ['outputPortTypes', 'output_port_types'],
        ['description', 'description'],
        ['isEnabled', 'enabled'],
        ['category', 'category'],
        ['isInteractive', 'interactive']
    ];
}

- (CPString)remotePath
{
    if ([self pk])
        return [self pk]
    else
        return [[CPBundle mainBundle] objectForInfoDictionaryKey:"ServerHost"] + @"/jobs/";
}

@end