@import <AppKit/AppKit.j>

/**
 * Base "abstract" controller for convenience.
 */
@implementation AbstractController : CPObject
{
    CPString _serverHost @accessors(readonly, property=serverHost);
}

///////////////////////////////////////////////////////////////////////////////
// Public Methods
///////////////////////////////////////////////////////////////////////////////
#pragma mark Public Methods
- (id)init
{
    if (self = [super init])
    {
        _serverHost = [[CPBundle mainBundle] objectForInfoDictionaryKey:"ServerHost"];
    }
    return self;
}
@end