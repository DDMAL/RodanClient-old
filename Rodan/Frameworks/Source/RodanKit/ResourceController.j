@import <AppKit/CPButton.j>
@import "../../FileUpload/FileUpload.j"
@import "AuthenticationController.j"
@import "RKController.j"
@import "Resource.j"
@import "RKNotificationTimer.j"

@global activeProject
@global RodanHasFocusResourcesViewNotification
@global RodanRequestResourcesNotification

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
    // Subscriptions for self.
    [[CPNotificationCenter defaultCenter] addObserver:self
                                          selector:@selector(receiveHasFocusEvent:)
                                          name:RodanHasFocusResourcesViewNotification
                                          object:nil];

    [[CPNotificationCenter defaultCenter] addObserver:self
                                          selector:@selector(handleShouldLoadNotification:)
                                          name:RodanRequestResourcesNotification
                                          object:nil];

    // Initialize the upload button.
    // NOTE: we may want to use Cup in the future.
    [resourceUploadButton setBordered:YES];
    [resourceUploadButton allowsMultipleFiles:YES];
    [resourceUploadButton setDelegate:self];
    [resourceUploadButton setFileKey:@"files"];
    [resourceUploadButton setURL:[self serverHost] + @"/resources/"];
}

///////////////////////////////////////////////////////////////////////////////
// Public Delegate Methods
///////////////////////////////////////////////////////////////////////////////
#pragma mark Public Delegate Methods

- (void)uploadButton:(UploadButton)aButton didChangeSelection:(CPArray)selection
{
    // If we're using token authorization, we have to do a custom upload
    if ([AuthenticationController tokenAuthorizationValue] !== nil)
    {
        [self _uploadFilesUsingToken:aButton];
    }
    else
    {
        [self _uploadFilesUsingSession:aButton];
    }
}

- (void)uploadButton:(UploadButton)aButton didFailWithError:(CPString)anError
{
    CPLog.error(anError);
}

- (void)uploadButton:(UploadButton)aButton didFinishUploadWithData:(CPString)response
{
    [aButton resetSelection];
}

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
    var selectedObjects = [arrayController selectedObjects];

    if ([selectedObjects count] === 1)
        window.open([[selectedObjects objectAtIndex:0] resourceFile], "_blank");

}

- (@action)removeResource:(id)aSender
{
    var selectedObjects = [arrayController selectedObjects];

    [selectedObjects makeObjectsPerformSelector:@selector(ensureDeleted)];
    [self handleShouldLoadNotification:null];
}

- (void)receiveHasFocusEvent:(CPNotification)aNotification
{
    [RKNotificationTimer setTimedNotification:[self refreshRate]
                         notification:RodanRequestResourcesNotification];
}

- (void)handleShouldLoadNotification:(CPNotification)aNotification
{
    [self _sendLoadRequest];
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

- (void)_uploadFilesUsingToken:(UploadButton)aButton
{
    var client = new XMLHttpRequest(),
        fileUploadElement = aButton._fileUploadElement,
        formData = new FormData(),
        arrayLength = fileUploadElement.files.length;

    for (var i = 0; i < arrayLength; i++)
        formData.append("files", fileUploadElement.files[i]);

    formData.append("project", [activeProject pk]);
    client.open("post", [self serverHost] + @"/resources/");
    client.setRequestHeader("Authorization", [AuthenticationController tokenAuthorizationValue]);
    client.send(formData);
}

- (void)_uploadFilesUsingSession:(UploadButton)aButton
{
    [aButton setValue:[activeProject pk] forParameter:@"project"];
    [aButton submit];
}
@end
