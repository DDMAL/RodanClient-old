@import <AppKit/AppKit.j>
@import <Foundation/Foundation.j>
@import "Controllers/UserController.j"

@implementation PlugInViewController : CPViewController
{
    @outlet CPToolbar   toolbar @accessors(property=toolbar); // REQUIRED to enable toolbar
}
@end