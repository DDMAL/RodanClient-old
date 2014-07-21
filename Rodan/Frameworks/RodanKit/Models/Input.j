@import "InputPort.j"
@import "RunJob."
@import "Resource.j"


@implementation Input : WLRemoteObject
{
    CPString        pk         @accessors;
    CPString        uuid        @accessors;
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
        return @"/input/";
    }
}

@end