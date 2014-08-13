@import <AppKit/AppKit.j>
@import "RKController.j"
@import "Connection.j"

RodanDidLoadConnectionNotification = @"RodanDidLoadConnectionNotification"

@implementation ConnectionController : RKController
{
    @outlet     CPArrayController   currentConnectionArrayController;
}

- (void)awakeFromCib
{
    currentConnectionArrayController = [[CPArrayController alloc] init];
}


- (void)remoteActionDidFinish:(WLRemoteAction)anAction
{
    //fetch inputport response
    var connection = [Connection objectsFromJson:[anAction result]];
    [currentConnectionArrayController addObject:connection];
    [[CPNotificationCenter defaultCenter] postNotificationName:RodanDidLoadConnectionNotification
                                                    object:[anAction result]];
}

- (void)fetchConnection:(CPString)aUUID
{
    [WLRemoteAction schedule:WLRemoteActionGetType
                        path:[self serverHost] + "/connection" + aUUID + "/"
                        delegate:self
                         message:"Loading Connection"
                 withCredentials:YES];
}



@end