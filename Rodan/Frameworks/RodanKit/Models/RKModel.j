@import <Ratatosk/WLRemoteObject.j>

/**
 * Base RodanKit controller for convenience.
 */
@implementation RKModel : WLRemoteObject
{
    CPString    pk      @accessors;
    CPString    uuid    @accessors;
}

@end