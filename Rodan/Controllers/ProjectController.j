/**
    This class handles loading/unloading projects.
**/

@global RodanHasFocusProjectListViewNotification
@global activeUser

activeProject = nil;  // URI to the currently open project

var _MESSAGE_PROJECTLOAD = "_MESSAGE_PROJECTLOAD",
    _MESSAGE_PROJECTSLOAD = "_MESSAGE_PROJECTSLOAD";

@implementation ProjectController : RKController
{
    @outlet CPMenuItem                  workspaceMenuItem;
    @outlet CPArrayController           projectArrayController;
    @outlet CPButtonBar                 projectAddRemoveButtonBar;
    @outlet CPView                      selectProjectView;
    @outlet WorkspaceController         workspaceController;
            CPValueTransformer          projectCountTransformer;
}

///////////////////////////////////////////////////////////////////////////////
// Public Methods
///////////////////////////////////////////////////////////////////////////////
#pragma mark Public Methods
- (void)awakeFromCib
{
    var addButton = [CPButtonBar plusPopupButton],
        removeButton = [CPButtonBar minusButton],
        addProjectTitle = @"Add Project...";

    [addButton addItemsWithTitles:[addProjectTitle]];
    [projectAddRemoveButtonBar setButtons:[addButton, removeButton]];

    var addProjectItem = [addButton itemWithTitle:addProjectTitle];

    [addProjectItem setAction:@selector(newProject:)];
    [addProjectItem setTarget:self];

    [removeButton setAction:@selector(shouldDeleteProjects:)];
    [removeButton setTarget:self];

    [removeButton bind:@"enabled"
                  toObject:projectArrayController
                  withKeyPath:@"selectedObjects.@count"
                  options:nil]

    [[CPNotificationCenter defaultCenter] addObserver:self
                                          selector:@selector(receiveHasFocusEvent:)
                                          name:RodanHasFocusProjectListViewNotification
                                          object:nil];

    var backgroundTexture = [[CPImage alloc] initWithContentsOfFile:[[CPBundle mainBundle] pathForResource:@"workflow-backgroundTexture.png"]
                                             size:CGSizeMake(200.0, 200.0)];

    [selectProjectView setBackgroundColor:[CPColor colorWithPatternImage:backgroundTexture]];
}

- (CPString)remoteActionContentType:(WLRemoteAction)anAction
{
    return @"application/json; charset=utf-8";
}

- (void)fetchProjects
{
    [WLRemoteAction schedule:WLRemoteActionGetType
                    path:[self serverHost] + "/projects/"
                    delegate:self
                    message:_MESSAGE_PROJECTSLOAD
                    withCredentials:YES];
}

- (void)remoteActionDidFinish:(WLRemoteAction)aAction
{
    switch ([aAction message])
    {
        case _MESSAGE_PROJECTLOAD:
            [WLRemoteObject setDirtProof:YES];
            activeProject = [[Project alloc] initWithJson:[aAction result]];
            [WLRemoteObject setDirtProof:NO];
            [workspaceMenuItem setEnabled:YES];
            [workspaceController clearView];
            break;

        case _MESSAGE_PROJECTSLOAD:
            var p = [MinimalProject objectsFromJson:[aAction result]];
            [projectArrayController addObjects:p];
            break;

        default:
            break;
    }
}


- (@action)shouldDeleteProjects:(id)aSender
{
    // get selected projects
    var numToBeDeleted = [[projectArrayController selectedObjects] count];
    if (numToBeDeleted > 1)
    {
        var plThis = "These",
            plProj = "projects";
    }
    else
    {
        var plThis = "This",
            plProj = "project";
    }

    var message = [CPString stringWithFormat:@"%@ %@ %@ and all associated files will be deleted! This cannot be undone. Are you sure?", plThis, numToBeDeleted, plProj];
    // pop up a warning
    alert = [[CPAlert alloc] init];
    [alert setMessageText:message];
    [alert setDelegate:self];
    [alert setAlertStyle:CPCriticalAlertStyle];
    [alert addButtonWithTitle:@"Delete"];
    [alert addButtonWithTitle:@"Cancel"];
    [alert runModal];
}

- (void)alertDidEnd:(CPAlert)theAlert returnCode:(int)returnCode
{
    if (returnCode == 0)
        [self deleteProjects];
}

- (void)deleteProjects
{
    var selectedObjects = [projectArrayController selectedObjects];
    [projectArrayController removeObjects:selectedObjects];
    [selectedObjects makeObjectsPerformSelector:@selector(ensureDeleted)];
}

- (void)emptyProjectArrayController
{
    [projectArrayController setContent:nil];
}

- (void)receiveHasFocusEvent:(CPNotification)aNotification
{
    [self emptyProjectArrayController];
    [self fetchProjects];
    [self showProjectsChooser:nil];
}

- (void)showProjectsChooser:(id)aNotification
{
    [workspaceController setView:selectProjectView];
}

- (void)didCloseProject:(CPNotification)aNotification
{
}

- (@action)closeProject:(id)aSender
{
    [workspaceMenuItem setEnabled:NO];
    [self showProjectsChooser:nil];
}

- (void)didLoadProject:(CPNotification)aNotification
{
    [workspaceMenuItem setEnabled:YES];
    [workspaceController clearView];
}

///////////////////////////////////////////////////////////////////////////////
// Public Action Methods
///////////////////////////////////////////////////////////////////////////////
#pragma mark Public Action Methods
- (@action)openProject:(id)aSender
{
    [workspaceMenuItem setEnabled:YES];

    var selectedProject = [[projectArrayController selectedObjects] objectAtIndex:0];

    [WLRemoteAction schedule:WLRemoteActionGetType
                    path:[selectedProject pk]
                    delegate:self
                    message:_MESSAGE_PROJECTLOAD
                    withCredentials:YES];
}

- (@action)newProject:(id)aSender
{
    var newProject = [[MinimalProject alloc] initWithCreator:[activeUser pk]];
    [projectArrayController addObject:newProject];
    [newProject ensureCreated];
}

///////////////////////////////////////////////////////////////////////////////
// Private Methods
///////////////////////////////////////////////////////////////////////////////
#pragma mark Private Methods
@end