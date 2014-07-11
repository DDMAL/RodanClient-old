@import "../Transformers/JobArgumentsTransformer.j"

@implementation WorkflowJob : WLRemoteObject
{
    CPString    pk              @accessors;
    CPString    workflow        @accessors;

    CPString    job             @accessors;

    CPArray     settings        @accessors;
    CPArray     inputPorts      @accessors;
    CPArray     outputPorts     @accessors;

}

+ (CPArray)remoteProperties
{
    return [
        ['pk', 'url'],
        ['uuid', 'uuid'],
        ['job', 'job'],  // nil transformer, true read-only
        ['settings', 'settings'],  // nil transformer, true read-only
        ['inputPorts', 'input_ports'],
        ['outputPorts', 'output_ports']
    ];
}

- (CPString)remotePath
{
    if ([self pk])
        return [self pk]
    else
        return @"/workflowjobs/";
}

- (void)removeFromWorkflow
{
    [self setWorkflow:nil];
    [self ensureSaved];
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

@end