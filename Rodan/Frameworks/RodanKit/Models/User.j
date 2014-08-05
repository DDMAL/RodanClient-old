@import <Ratatosk/WLRemoteObject.j>
@import "RKModel.j"

@implementation User : RKModel
{
    CPString    username        @accessors;
    CPString    firstName       @accessors;
    CPString    lastName        @accessors;
    CPArray     groups          @accessors;
    BOOL        isActive        @accessors;
    BOOL        isStaff         @accessors;
    BOOL        isSuperuser     @accessors;
    CPString    email           @accessors;

    CPArray     projects        @accessors;
    CPArray     workflows       @accessors;
    CPArray     workflowRuns    @accessors;
}

+ (CPArray)remoteProperties
{
    return [
        ['pk', 'url'],
        ['username', 'username'],
        ['firstName', 'first_name'],
        ['lastName', 'last_name'],
        ['isActive', 'is_active'],
        ['isStaff', 'is_staff'],
        ['isSuperuser', 'is_superuser'],
        ['email', 'email'],
        ['groups', 'groups'],
        ['projects', 'projects'],
        ['workflows', 'workflows'],
        ['workflowRuns', 'workflow_runs']
    ];
}

- (CPString)postPath
{
    return [[CPBundle mainBundle] objectForInfoDictionaryKey:"ServerHost"] + @"/users/"
}

- (CPString)remotePath
{
    if ([self pk])
        return [self pk]
    else
        return [[CPBundle mainBundle] objectForInfoDictionaryKey:"ServerHost"] + @"/users/";
}
@end
