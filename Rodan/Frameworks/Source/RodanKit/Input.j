@import "RKModel.j"
@import "InputPort.j"
@import "Resource.j"
@import "RunJob.j"

@implementation Input : RKModel
{
    InputPort       inputPort   @accessors;
    RunJob          runJob      @accessors;
    Resource        resource    @accessors;
}

+ (CPArray)remoteProperties
{
    return [
        ['pk', 'url'],
        ['uuid', 'uuid'],
        ['inputPort', 'input_port', [WLForeignObjectTransformer forObjectClass:InputPort]],
        ['runJob', 'run_job', [WLForeignObjectTransformer forObjectClass:RunJob]],
        ['resource', 'resource', [WLForeignObjectTransformer forObjectClass:Resource]]
    ];
}

- (CPString)remotePath
{
    if ([self pk])
    {
        return [self pk]
    }
    else
    {
        return [[CPBundle mainBundle] objectForInfoDictionaryKey:"ServerHost"] + @"/input/";
    }
}

@end