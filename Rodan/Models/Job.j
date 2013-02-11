@implementation Job : WLRemoteObject
{
    CPString    pk              @accessors;
    CPString    jobName         @accessors;
    JSObject    arguments       @accessors;
    JSObject    inputTypes      @accessors;
    JSObject    outputTypes     @accessors;
    CPString    category        @accessors;
    BOOL        isEnabled       @accessors;

    CPImage     sourceListIcon  @accessors;
}

- (id)init
{
    if (self = [super init])
    {
        sourceListIcon = [[CPImage alloc] initWithContentsOfFile:[[CPBundle mainBundle] pathForResource:@"job-sourcelist-icon.png"]
                                  size:CGSizeMake(16.0, 16.0)];

    }
    return self;
}

+ (CPArray)remoteProperties
{
    return [
        ['pk', 'url'],
        ['jobName', 'name'],
        ['arguments', 'arguments'],
        ['inputTypes', 'input_types'],
        ['outputTypes', 'output_types'],
        ['category', 'category'],
        ['isEnabled', 'enabled']
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
        return @"/jobs/";
    }
}
@end
