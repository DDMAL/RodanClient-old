/**
 * This class handles plugin bundle related code. It is its own delegate.
 */

var instance = nil;

@implementation PlugInsController : AbstractController
{
    CPMenu          _menu;
    CPDictionary    _bundleMap;
}

///////////////////////////////////////////////////////////////////////////////
// Public Static Methods
///////////////////////////////////////////////////////////////////////////////
+ (void)loadPlugIns
{
    var bundleString = [[CPBundle mainBundle] objectForInfoDictionaryKey:"PlugIns"];
    if (bundleString != nil)
    {
        var pluginStringArray = [bundleString componentsSeparatedByString:","],
            enumerator = [pluginStringArray objectEnumerator];
        while (pluginString = [enumerator nextObject])
        {
            [PlugInsController loadPlugIn:pluginString];
        }
    }
}

+ (void)loadPlugIn:(CPString)aString
{
    var bundle = [CPBundle bundleWithPath:"PlugIns/" + aString];
    [bundle loadWithDelegate:[PlugInsController _getInstance]];
}

+ (void)setMenu:(CPMenu)aMenu
{
    [PlugInsController _getInstance]._menu = aMenu;
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
        [self _addBundle:aBundle];
    }
    else
    {
        CPLog("bundle failed to load: " + [aBundle bundlePath]);
    }
}

- (@action)selectedPlugIn:(id)aSender
{
    var bundle = [_bundleMap objectForKey:aSender],sharedApplication = [CPApplication sharedApplication];
   // var controller = [[CPViewController alloc] initWithCibName:"test" bundle:bundle];
    //[[sharedApplication mainWindow] setContentView:[controller view]];
}

///////////////////////////////////////////////////////////////////////////////
// Private Static Methods
///////////////////////////////////////////////////////////////////////////////
#pragma mark Private Static Methods
+ (PlugInsController)_getInstance
{
    if (instance == nil)
    {
        instance = [[PlugInsController alloc] init];
    }
    return instance;
}

///////////////////////////////////////////////////////////////////////////////
// Private Methods
///////////////////////////////////////////////////////////////////////////////
#pragma mark Private Methods
- (id)init
{
    if (self = [super init])
    {
        _bundleMap = [[CPDictionary alloc] init];
    }
    return self;
}

- (void)_addBundle:(CPBundle)aBundle
{
    var menuItem = [_menu addItemWithTitle:[aBundle objectForInfoDictionaryKey:"CPBundleName"]
                          action:@selector(selectedPlugIn:)
                          keyEquivalent:""];
    [menuItem setTarget:self];
    [_bundleMap setValue:aBundle forKey:menuItem];
    CPLog("bundle '" + [aBundle objectForInfoDictionaryKey:"CPBundleName"] + "' added to menu");
}
@end
