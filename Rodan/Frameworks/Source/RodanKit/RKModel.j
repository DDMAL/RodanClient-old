@import "../../Ratatosk/WLRemoteObject.j"
@import "../../Ratatosk/WLRemoteTransformers.j"

@global RodanModelCreatedNotification
@global RodanModelDeletedNotification
@global RodanModelLoadedNotification

/**
 * Base RodanKit model for convenience.
 */
@implementation RKModel : WLRemoteObject
{
    CPString    pk      @accessors;
    CPString    uuid    @accessors;
}

///////////////////////////////////////////////////////////////////////////////
// Public Methods
///////////////////////////////////////////////////////////////////////////////
#pragma mark Public Methods
- (id)init
{
    if (self = [super init])
    {
        [self setDelegate:self];
    }
    return self;
}

///////////////////////////////////////////////////////////////////////////////
// Public Delegate Methods
///////////////////////////////////////////////////////////////////////////////
#pragma mark Public Delegate Methods
- (void)remoteObjectWasCreated:(WLRemoteObject)aRemoteObject
{
    [[CPNotificationCenter defaultCenter] postNotificationName:RodanModelCreatedNotification
                                          object:aRemoteObject];
}

- (void)remoteObjectWasDeleted:(WLRemoteObject)aRemoteObject
{
    [[CPNotificationCenter defaultCenter] postNotificationName:RodanModelDeletedNotification
                                          object:aRemoteObject];
}

- (void)remoteObjectWasLoaded:(WLRemoteObject)aRemoteObject
{
    [[CPNotificationCenter defaultCenter] postNotificationName:RodanModelLoadedNotification
                                          object:aRemoteObject];
}
@end