@import "../../Ratatosk/WLRemoteTransformers.j"
@import "RKModel.j"
@import "User.j"
@import "Workflow.j"

/* a full representation of a project, including arrays for the pages and workflows */
@implementation Project : RKModel
{
    CPString    projectName         @accessors;
    CPString    projectCreator      @accessors;
    CPString    projectDescription  @accessors;
    CPObject    projectOwner        @accessors;
    CPString    resourceURI         @accessors;
    CPArray     pages               @accessors;
    CPDate      created             @accessors;
    CPDate      updated             @accessors;
}

- (id)init
{
    if (self = [super init])
    {
        projectName = @"Untitled Project";
    }

    return self;
}

- (id)initWithCreator:(User)aCreator
{
    var self = [self init];
    [self setProjectCreator:aCreator];
    return self;
}

+ (CPArray)remoteProperties
{
    return [
        ['uuid', 'uuid'],
        ['pk', 'url'],
        ['projectName', 'name'],
        ['projectDescription', 'description'],
        ['projectCreator', 'creator'],
     //   ['pages', 'pages', [WLForeignObjectsTransformer forObjectClass:Page]],
        ['created', 'created', [[WLDateTransformer alloc] init], true],
        ['updated', 'updated', [[WLDateTransformer alloc] init], true]
    ];
}

- (CPString)remotePath
{
    if ([self pk])
        return [self pk];
    else
        return [[CPBundle mainBundle] objectForInfoDictionaryKey:"ServerHost"] + @"/projects/";
}
@end


/* A minimal representation of a project */
@implementation MinimalProject : WLRemoteObject
{
    CPString projectName        @accessors;
    CPString projectDescription @accessors;
    CPNumber pageCount          @accessors;
    CPNumber workflowCount      @accessors;
    CPString projectCreator     @accessors;
    CPDate   created            @accessors;
    CPDate   updated            @accessors;
}

- (id)init
{
    if (self = [super init])
    {
        projectName = @"Untitled Project";
    }

    return self;
}

- (CPString)remotePath
{
    if ([self pk])
        return [self pk];
    else
        return [[CPBundle mainBundle] objectForInfoDictionaryKey:"ServerHost"] + @"/projects/";
}

- (id)initWithCreator:(User)aCreator
{
    var self = [self init];
    [self setProjectCreator:aCreator];

    return self;
}

+ (CPArray)remoteProperties
{
    return [
        ['pk', 'url'],
        ['projectName', 'name'],
        ['projectDescription', 'description'],
        ['projectCreator', 'creator'],
        ['pageCount', 'page_count'],
        ['workflowCount', 'workflow_count'],
        ['created', 'created', [[WLDateTransformer alloc] init], true],
        ['updated', 'updated', [[WLDateTransformer alloc] init], true]
    ];
}

@end
