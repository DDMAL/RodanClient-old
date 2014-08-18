@import <Foundation/CPBundle.j>
@import <Foundation/CPObject.j>

var refreshRate = nil,
    serverHost = nil;

/**
 * Base RodanKit controller for convenience.
 */
@implementation RKController : CPObject
{
    CPString    _serverHost    @accessors(property=serverHost);
    CPNumber    _refreshRate   @accessors(property=refreshRate);
}

///////////////////////////////////////////////////////////////////////////////
// Public Methods
///////////////////////////////////////////////////////////////////////////////
#pragma mark Public Methods

- (id)init
{
    if (refreshRate == nil)
        refreshRate = [[CPBundle mainBundle] objectForInfoDictionaryKey:"RefreshRate"];

    if (serverHost == nil)
        serverHost = [[CPBundle mainBundle] objectForInfoDictionaryKey:"ServerHost"];

    if (self = [super init])
    {
        _serverHost = serverHost;
        _refreshRate = refreshRate;
    }

    return self;
}
@end