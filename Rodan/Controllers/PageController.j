@import <AppKit/AppKit.j>
@import <FileUpload/FileUpload.j>
@import <Ratatosk/Ratatosk.j>
@import <RodanKit/Models/Page.j>
@import <RodanKit/Tools/RKNotificationTimer.j>

@global activeProject
@global RodanHasFocusPagesViewNotification
@global RodanShouldLoadPagesNotification

/**
 * Handles control of all Page-related tasks.
 */
@implementation PageController : AbstractController
{
    @outlet     CPMenuItem          menuItem;
    @outlet     UploadButton        imageUploadButton;
    @outlet     CPImageView         imageView;
    @outlet     CPArrayController   pageArrayController;
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
                                          name:RodanHasFocusPagesViewNotification
                                          object:nil];
    [[CPNotificationCenter defaultCenter] addObserver:self
                                          selector:@selector(handleShouldLoadNotification:)
                                          name:RodanShouldLoadPagesNotification
                                          object:nil];
}

- (id)initWithCoder:(CPCoder)aCoder
{
    var self = [super initWithCoder:aCoder];
    if (self)
    {
    }

    return self;
}

- (void)emptyPageArrayController
{
    [pageArrayController setContent:nil];
}

///////////////////////////////////////////////////////////////////////////////
// Public Delegate Methods
///////////////////////////////////////////////////////////////////////////////
#pragma mark Public Delegate Methods
- (void)uploadButton:(UploadButton)button didChangeSelection:(CPArray)selection
{
    var nextPageOrder = [[pageArrayController contentArray] valueForKeyPath:@"@max.pageOrder"] + 1;
    [imageUploadButton setBordered:YES];
    [imageUploadButton setFileKey:@"files"];
    [imageUploadButton allowsMultipleFiles:YES];
    [imageUploadButton setDelegate:self];
    [imageUploadButton setURL:@"/pages/"];
    [imageUploadButton setValue:[activeProject pk] forParameter:@"project"];
    [imageUploadButton setValue:nextPageOrder forParameter:@"page_order"];

    [button submit];
}

- (void)uploadButton:(UploadButton)button didFailWithError:(CPString)anError
{
    CPLog.error(anError);
}

- (void)uploadButton:(UploadButton)button didFinishUploadWithData:(CPString)response
{
    [button resetSelection];
    var data = JSON.parse(response);
    [self _createObjectsWithJSONResponse:data];
}

- (void)uploadButtonDidBeginUpload:(UploadButton)button
{
    CPLog("Did Begin Upload");
}

- (IBAction)removePage:(id)aSender
{
    var selectedObjects = [pageArrayController selectedObjects];
    [selectedObjects makeObjectsPerformSelector:@selector(ensureDeleted)];
    [self handleShouldLoadNotification:null];
}

- (void)receiveHasFocusEvent:(CPNotification)aNotification
{
    [RKNotificationTimer setTimedNotification:[self refreshRate]
                         notification:RodanShouldLoadPagesNotification];
}

- (void)handleShouldLoadNotification:(CPNotification)aNotification
{
    [self _sendLoadRequest];
}

- (void)remoteActionDidFinish:(WLRemoteAction)aAction
{
    if ([aAction result])
    {
        [WLRemoteObject setDirtProof:YES];
        var pageArray = [Page objectsFromJson:[aAction result]];
        [pageArrayController setContent:pageArray];
        [WLRemoteObject setDirtProof:NO];
    }
}

- (@action)viewOriginal:(id)aSender
{
    var selectedObjects = [pageArrayController selectedObjects];
    if ([selectedObjects count] == 1)
    {
        window.open([[selectedObjects objectAtIndex:0] pageImage], "_blank");
    }
}

///////////////////////////////////////////////////////////////////////////////
// Private Methods
///////////////////////////////////////////////////////////////////////////////
#pragma mark Private Methods
- (void)_sendLoadRequest
{
    [WLRemoteAction schedule:WLRemoteActionGetType
                    path:[self serverHost] + @"/pages/?project=" + [activeProject uuid]
                    delegate:self
                    message:"Loading Workflow Run Results"
                    withCredentials:YES];
}

- (void)createObjectsWithJSONResponse:(id)aResponse
{
    [WLRemoteObject setDirtProof:YES];  // turn off auto-creation of pages since we've already done it.
    var pages = [Page objectsFromJson:aResponse.pages];
    [pageArrayController addObjects:pages];
    [WLRemoteObject setDirtProof:NO];
}
@end
