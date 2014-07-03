var instance = nil;

/**
 * This class handles plugin bundle related code. It is its own delegate.
 */
@implementation PlugInsController : AbstractController
{
}

///////////////////////////////////////////////////////////////////////////////
// Public Static Methods
///////////////////////////////////////////////////////////////////////////////
#pragma mark Public Static Methods
+ (PlugInsController)getInstance
{
    if (instance == nil)
    {
        instance = [[PlugInsController alloc] init];
    }
    return instance;
}

+ (void)loadPlugIns
{

}

+ (void)loadPlugIn:(CPString)aString
{
    var bundle = [CPBundle bundleWithPath:"PlugIns/" + aString];
    [bundle loadWithDelegate:[PlugInsController getInstance]];
}

///////////////////////////////////////////////////////////////////////////////
// Public Delegate Methods
///////////////////////////////////////////////////////////////////////////////
#pragma mark Public Delegate Methods
- (void)bundleDidFinishLoading:(CPBundle)aBundle
{
    if ([aBundle isLoaded])
    {
        CPLog("bundle loaded: " + [aBundle bundlePath]);
    }
    else
    {
        CPLog("bundle failed to load: " + [aBundle bundlePath]);
    }
}

////////////////////////////////////////////////////////////////////////////////////////////
// Private Methods
////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark Private Methods
@end
