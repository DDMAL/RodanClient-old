@import "RKModel.j"
@import "Resource.j"
@import "OutputPort.j"
@import "RunJob.j"

@implementation Output : RKModel
{
    OutputPort      outputPort      @accessors;
    RunJob          runJob          @accessors;
    Resource        resource        @accessors;
}

+ (CPArray)remoteProperties
{
    return [
        ['pk', 'url'],
        ['uuid', 'uuid'],
        ['outputPort', 'output_port', [WLForeginObjectTransformer forObjectClass:OutputPort]],
        ['runJob', 'run_job', [WLForeginObjectTransformer forObjectClass:RunJob]],
        ['resource', 'resource', [WLForeginObjectTransformer forObjectClass:Resource]]
    ];
}


- (CPString)remotePath
{
    if ([self pk])
        return [self pk]
    else
        return [[CPBundle mainBundle] objectForInfoDictionaryKey:"ServerHost"] + @"/output/";
}

@end