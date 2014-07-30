/**
 * This class handles plugin bundle related code.
 */
 @import "../PlugIns.j"

@implementation PlugInsController : AbstractController
{
    @outlet CPMenuItem          menuItem;
    @outlet WorkspaceController workspaceController;
            CPMenu              _menu;
            CPDictionary        _bundleMap;
}

///////////////////////////////////////////////////////////////////////////////
// Public Methods
///////////////////////////////////////////////////////////////////////////////
#pragma mark Public Methods
- (id)init
{
    if (self = [super init])
    {
        _bundleMap = [[CPDictionary alloc] init];
        _menu = [[CPMenu alloc] init];
    }
    return self;
}

- (void)awakeFromCib
{
    [menuItem setTarget:_menu];
    [menuItem setAction:@selector(submenuAction:)];
    [menuItem setSubmenu:_menu];
}

- (void)loadPlugIns
{
    var bundleString = [[CPBundle mainBundle] objectForInfoDictionaryKey:"PlugIns"];
    if (bundleString != nil)
    {
        var pluginStringArray = [bundleString componentsSeparatedByString:","],
            enumerator = [pluginStringArray objectEnumerator],
            pluginString = nil;
        while (pluginString = [enumerator nextObject])
        {
            [self loadPlugIn:pluginString];
        }
    }
}

- (void)loadPlugIn:(CPString)aString
{
    var bundle = [CPBundle bundleWithPath:"PlugIns/" + aString];
    if (bundle != nil)
    {
        CPLog("bundle '" + [bundle objectForInfoDictionaryKey:"CPBundleName"] + "' found");
        [self _addBundle:bundle];
    }
    else
    {
        CPLog("bundle '" + [bundle objectForInfoDictionaryKey:"CPBundleName"] + "' NOT found");
    }
}

///////////////////////////////////////////////////////////////////////////////
// Public Delegate Methods
///////////////////////////////////////////////////////////////////////////////
#pragma mark Public Delegate Methods
- (@action)selectedPlugIn:(id)aSender
{
    // Get bundle info.
    var bundle = [_bundleMap objectForKey:aSender],
        sharedApplication = [CPApplication sharedApplication],
        principalClass = [bundle principalClass];
    var controller = [[principalClass alloc] initWithCibName:[bundle objectForInfoDictionaryKey:"CPCibName"]
                                             bundle:bundle];

    // Clear all timers.
    [RKNotificationTimer clearTimedNotification];

    // Load.  Check for toolbar.
    if ([controller respondsToSelector:@selector(toolbar)])
    {
        [workspaceController setView:[controller view] withToolbar:[controller toolbar]];
    }
    else
    {
        [workspaceController setView:[controller view]];
    }
}

///////////////////////////////////////////////////////////////////////////////
// Private Methods
///////////////////////////////////////////////////////////////////////////////
#pragma mark Private Methods
- (void)_addBundle:(CPBundle)aBundle
{
    var newMenuItem = [_menu addItemWithTitle:[aBundle objectForInfoDictionaryKey:"CPBundleName"]
                          action:@selector(selectedPlugIn:)
                          keyEquivalent:""];
    [newMenuItem setTarget:self];
    [_bundleMap setValue:aBundle forKey:newMenuItem];
    CPLog("bundle '" + [aBundle objectForInfoDictionaryKey:"CPBundleName"] + "' added to menu");
}
@end
