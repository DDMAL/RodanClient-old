@import <AppKit/AppKit.j>
@import "RKController.j"
@import "OutputPort.j"

RodanDidLoadOutputPortNotification = @"RodanDidLoadOutputPortNotification"

@implementation OutputPortController : RKController
{
    @outlet     CPArrayController   currentOutputPortController;
}

- (void)awakeFromCib
{
    currentOutputPortController = [[CPArrayController alloc] init];
}


- (void)remoteActionDidFinish:(WLRemoteAction)anAction
{
    //fetch outputPort response
    var outputPort = [OutputPort objectsFromJson:[anAction result]];
    [currentOutputPortController addObject:outputPort];
    [[CPNotificationCenter defaultCenter] postNotificationName:RodanDidLoadOutputPortNotification
                                                    object:[anAction result]];
}

- (void)fetchOutputPort:(CPString)aUUID
{
    [WLRemoteAction schedule:WLRemoteActionGetType
                        path:[self serverHost] + "/outputport" + aUUID + "/"
                        delegate:self
                         message:"Loading OutputPort"
                 withCredentials:YES];
}



@end