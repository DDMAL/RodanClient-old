@import <AppKit/AppKit.j>
@import "RKController.j"
@import "InputPort.j"

RodanDidLoadInputPortNotification = @"RodanDidLoadInputPortNotification"

@implementation InputPortController : RKController
{
    @outlet     CPArrayController   currentInputPortController;
}

- (void)awakeFromCib
{
    currentInputPortController = [[CPArrayController alloc] init];
}


- (void)remoteActionDidFinish:(WLRemoteAction)anAction
{
    //fetch inputport response
    var inputPort = [InputPort objectsFromJson:[anAction result]];
    [currentInputPortController addObject:inputPort];
    [[CPNotificationCenter defaultCenter] postNotificationName:RodanDidLoadInputPortNotification
                                                    object:[anAction result]];
}

- (void)fetchInputPort:(CPString)aUUID
{
    [WLRemoteAction schedule:WLRemoteActionGetType
                        path:[self serverHost] + "/inputport" + aUUID + "/"
                        delegate:self
                         message:"Loading InputPort"
                 withCredentials:YES];
}



@end