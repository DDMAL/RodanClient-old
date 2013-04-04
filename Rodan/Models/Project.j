@import <Ratatosk/WLRemoteTransformers.j>


@implementation Project : WLRemoteObject
{
    CPString    pk                  @accessors;
    CPString    projectName         @accessors;
    CPString    projectCreator      @accessors;
    CPString    projectDescription  @accessors;
    CPObject    projectOwner        @accessors;
    CPString    resourceURI         @accessors;
    CPArray     pages               @accessors;
    CPArray     workflows           @accessors;
    CPDate      created             @accessors;
    CPDate      updated             @accessors;
}

- (id)init
{
    if (self = [super init])
    {
        CPLog("Initializing Project model");
    }
    return self;
}

+ (CPArray)remoteProperties
{
    return [
        ['pk', 'url'],
        ['projectName', 'name'],
        ['projectDescription', 'description'],
        ['projectCreator', 'creator'],
        ['pages', 'pages'],
        ['workflows', 'workflows'],
        ['created', 'created', [WLDateTransformer alloc], true],
        ['updated', 'updated', [WLDateTransformer alloc], true]
    ];
}

- (CPString)remotePath
{
    if ([self pk])
    {
        return [self pk];
    }
    else
    {
        return @"/projects/";
    }
}

- (CPString)remoteAction:(WLRemoteAction)anAction decodeResponseBody:(Object)aResponseBody
{

    var response = JSON.parse(aResponseBody);
    console.log(response);
    /*
        setDirtProof ensures that updating this object does
        not kick off a PATCH request for a change.
    */
    [WLRemoteObject setDirtProof:YES];
    [self setPk:response.url];
    [self setResourceURI:response.url];
    [self setProjectOwner:response.creator];
    [self setPages:response.pages];
    [self setWorkflows:response.workflows];
    [WLRemoteObject setDirtProof:NO];

    CPLog("Done updating object");
    console.log(self);

    return aResponseBody;
}
@end
