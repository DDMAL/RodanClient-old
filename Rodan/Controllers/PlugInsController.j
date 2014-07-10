/**
 * This class handles plugin bundle related code.
 */
 @import "../PlugIns.j"

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
    if (bundle != nil)
    {
        CPLog("bundle '" + [bundle objectForInfoDictionaryKey:"CPBundleName"] + "' found");
        [[PlugInsController _getInstance] _addBundle:bundle];
    }
    else
    {
        CPLog("bundle '" + [bundle objectForInfoDictionaryKey:"CPBundleName"] + "' NOT found");
    }
}

+ (void)setMenu:(CPMenu)aMenu
{
    [PlugInsController _getInstance]._menu = aMenu;
}

///////////////////////////////////////////////////////////////////////////////
// Public Delegate Methods
///////////////////////////////////////////////////////////////////////////////
#pragma mark Public Delegate Methods
- (@action)selectedPlugIn:(id)aSender
{
    var bundle = [_bundleMap objectForKey:aSender],
        sharedApplication = [CPApplication sharedApplication];
    var controller = [[CPViewController alloc] initWithCibName:[bundle objectForInfoDictionaryKey:"CPCibName"]
                                               bundle:bundle];
    [[sharedApplication mainWindow] setContentView:[controller view]];
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
