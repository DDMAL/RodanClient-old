@import <AppKit/AppKit.j>
@import <Ratatosk/Ratatosk.j>
@import <RodanKit/Models/Project.j>
@import "../AppController.j"

@global RodanHasFocusProjectListViewNotification
@global RodanDidLoadProjectNotification
@global RodanDidCloseProjectNotification
@global activeUser

activeProject = nil;  // URI to the currently open project

@implementation ProjectController : AbstractController
{
    @outlet CPMenuItem                  workspaceMenuItem;
    @outlet CPArrayController           projectArrayController;
    @outlet LoadActiveProjectDelegate   activeProjectDelegate;
    @outlet CPButtonBar                 projectAddRemoveButtonBar;
    @outlet CPView                      selectProjectView;
    @outlet PageController              pageController;
    @outlet CPArrayController           pageArrayController;
    @outlet WorkflowController          workflowController;
    @outlet CPArrayController           workflowArrayController;
    @outlet JobController               jobController;
    @outlet WorkspaceController         workspaceController;
            CPValueTransformer          projectCountTransformer;
}

- (void)awakeFromCib
{
    [[CPNotificationCenter defaultCenter] addObserver:self
                                          selector:@selector(receiveHasFocusEvent:)
                                          name:RodanHasFocusProjectListViewNotification
                                          object:nil];

    [[CPNotificationCenter defaultCenter] addObserver:self
                                          selector:@selector(didLoadProject:)
                                          name:RodanDidLoadProjectNotification
                                          object:nil];

    [[CPNotificationCenter defaultCenter] addObserver:self
                                          selector:@selector(didCloseProject:)
                                          name:RodanDidCloseProjectNotification
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
                    message:"Loading projects"
                    withCredentials:YES];
}

- (void)remoteActionDidFinish:(WLRemoteAction)anAction
{
    var p = [MinimalProject objectsFromJson:[anAction result]];
    [projectArrayController addObjects:p];
}

- (@action)newProject:(id)aSender
{
    var newProject = [[MinimalProject alloc] initWithCreator:[activeUser pk]];
    [projectArrayController addObject:newProject];
    [newProject ensureCreated];
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

- (IBAction)openProject:(id)aSender
{
    [workspaceMenuItem setEnabled:YES];
    var selectedProject = [[projectArrayController selectedObjects] objectAtIndex:0];
    [WLRemoteAction schedule:WLRemoteActionGetType
                    path:[selectedProject pk]
                    delegate:activeProjectDelegate
                    message:"Loading Project"
                    withCredentials:YES];
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

#pragma mark -
#pragma mark Project Opening and Closing

- (void)showProjectsChooser:(id)aNotification
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

    [workspaceController setView:selectProjectView];
}

- (void)didCloseProject:(CPNotification)aNotification
{
    [self showProjectsChooser:nil];
}

- (IBAction)closeProject:(id)aSender
{
    [workspaceMenuItem setEnabled:NO];
    [[CPNotificationCenter defaultCenter] postNotificationName:RodanDidCloseProjectNotification
                                          object:nil];
}

- (void)didLoadProject:(CPNotification)aNotification
{
    [workspaceMenuItem setEnabled:YES];
    [workspaceController clearView];
}
@end


@implementation LoadActiveProjectDelegate : CPObject
{
    @outlet     CPArrayController       pageArrayController;
    @outlet     CPArrayController       workflowArrayController;
}

- (void)remoteActionDidFinish:(WLRemoteAction)anAction
{
    [WLRemoteObject setDirtProof:YES];
    activeProject = [[Project alloc] initWithJson:[anAction result]];
    [WLRemoteObject setDirtProof:NO];
    [[CPNotificationCenter defaultCenter] postNotificationName:RodanDidLoadProjectNotification
                                          object:nil];

}
@end
