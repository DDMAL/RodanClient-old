@import <AppKit/CPButton.j>
@import "../../FileUpload/FileUpload.j"
@import "RKController.j"
@import "Resource.j"

@global activeProject

_MESSAGE_RESOURCES_LOAD = "_MESSAGE_RESOURCES_LOAD";

/**
 * Handles control of all Resource-related tasks.
 */
@implementation ResourceController : RKController
{
    @outlet CPArrayController   arrayController;
    @outlet CPImageView         imageView;
    @outlet UploadButton        resourceUploadButton;
}

///////////////////////////////////////////////////////////////////////////////
// Public Methods
///////////////////////////////////////////////////////////////////////////////
#pragma mark Public Methods
- (void)awakeFromCib
{
}

///////////////////////////////////////////////////////////////////////////////
// Public Delegate Methods
///////////////////////////////////////////////////////////////////////////////
#pragma mark Public Delegate Methods
- (void)remoteActionDidFinish:(WLRemoteAction)anAction
{
    if ([anAction result])
    {
        switch ([anAction message])
        {
            case _MESSAGE_RESOURCES_LOAD:
                [self _populateArrayFromAction:anAction];
                break;
        }
    }
}

- (@action)viewOriginal:(id)aSender
{
    console.log("view original");
 /*   var selectedObjects = [pageArrayController selectedObjects];
    if ([selectedObjects count] == 1)
    {
        window.open([[selectedObjects objectAtIndex:0] pageImage], "_blank");
    }*/
}

- (@action)removeResource:(id)aSender
{
    var selectedObjects = [arrayController selectedObjects];
    [selectedObjects makeObjectsPerformSelector:@selector(ensureDeleted)];
    [self handleShouldLoadNotification:null];
}

///////////////////////////////////////////////////////////////////////////////
// Private Methods
///////////////////////////////////////////////////////////////////////////////
#pragma mark Private Methods
- (void)_sendLoadRequest
{
    [WLRemoteAction schedule:WLRemoteActionGetType
                    path:[self serverHost] + @"/resources/?project=" + [activeProject uuid]
                    delegate:self
                    message:_MESSAGE_RESOURCES_LOAD
                    withCredentials:YES];
}

- (void)_populateArrayFromAction:(WLRemoteAction)aAction
{
    [WLRemoteObject setDirtProof:YES];
    var array = [Resource objectsFromJson:[aAction result]];
    [arrayController setContent:array];
    [WLRemoteObject setDirtProof:NO];
}
@end
