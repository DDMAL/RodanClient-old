/**
 * This class handles User-related functionality.
 */
@import <AppKit/AppKit.j>

var RodanClientAdminUserTimerNotification = @"RodanClientAdminUserTimerNotification";

@implementation UserController : RKController
{
    @outlet CPArrayController   userArrayController;
    @outlet CPTextField         selectedUserUsername;
    @outlet CPTextField         selectedUserFirstName;
    @outlet CPTextField         selectedUserLastName;
    @outlet CPTextField         selectedUserEmail;
    @outlet CPCheckBox          selectedUserActive;
    @outlet CPCheckBox          selectedUserStaffStatus;
    @outlet CPCheckBox          selectedUserSuperuserStatus;
    @outlet CPTextField         newPassword;
    @outlet CPTextField         newPasswordConfirm;
    @outlet CPTextField         newUsername;
    @outlet CPWindow            windowConfirmDeleteUser;
    @outlet CPWindow            windowResetPassword;
    @outlet CPWindow            windowCreateUser;
            User                _selectedUser;
}

///////////////////////////////////////////////////////////////////////////////
// Public Methods
///////////////////////////////////////////////////////////////////////////////
#pragma mark Public Methods
- (void)awakeFromCib
{
    _selectedUser = nil;
    [self _clearSelectedUserInfo];
    [[CPNotificationCenter defaultCenter] addObserver:self
                                          selector:@selector(handleTimerNotification:)
                                          name:RodanClientAdminUserTimerNotification
                                          object:nil];
    [RKNotificationTimer setTimedNotification:[self refreshRate]
                         notification:RodanClientAdminUserTimerNotification];
}

///////////////////////////////////////////////////////////////////////////////
// Public Notification Methods
///////////////////////////////////////////////////////////////////////////////
- (void)handleTimerNotification:(CPNotification)aNotification
{
    [self _fetchUsers];
}

///////////////////////////////////////////////////////////////////////////////
// Public Delegate Methods
///////////////////////////////////////////////////////////////////////////////
#pragma mark Public Delegate Methods
- (void)remoteActionDidFinish:(WLRemoteAction)anAction
{
    if ([anAction result])
    {
        var users = [User objectsFromJson:[anAction result]];
        [userArrayController setContent:users];
    }
}

- (void)didEndSheet:(CPWindow)aSheet returnCode:(int)returnCode contextInfo:(id)contextInfo
{
    [aSheet orderOut:self];
    [RKNotificationTimer setTimedNotification:[self refreshRate]
                         notification:RodanClientAdminUserTimerNotification];
}

- (void)tableViewSelectionIsChanging:(CPNotification)aNotification
{
    [self _setSelectedUserInfo];
}

- (BOOL)tableView:(CPTableView)aTableView shouldSelectRow:(int)rowIndex
{
    _selectedUser = [[userArrayController contentArray] objectAtIndex:rowIndex];
    [self _setSelectedUserInfo];
    return YES;
}

///////////////////////////////////////////////////////////////////////////////
// Public Action Methods - Buttons
///////////////////////////////////////////////////////////////////////////////
#pragma mark Public Action Methods - Buttons
- (@action)handleButtonAdd:(id)aSender
{
    [CPApp beginSheet:windowCreateUser
           modalForWindow:[CPApp mainWindow]
           modalDelegate:self
           didEndSelector:@selector(didEndSheet:returnCode:contextInfo:)
           contextInfo:nil];
}

- (@action)handleButtonDelete:(id)aSender
{
    if (_selectedUser != nil)
    {
        [CPApp beginSheet:windowConfirmDeleteUser
               modalForWindow:[CPApp mainWindow]
               modalDelegate:self
               didEndSelector:@selector(didEndSheet:returnCode:contextInfo:)
               contextInfo:nil];
    }
}

- (@action)handleButtonResetPassword:(id)aSender
{
    if (_selectedUser != nil)
    {
        [CPApp beginSheet:windowResetPassword
               modalForWindow:[CPApp mainWindow]
               modalDelegate:self
               didEndSelector:@selector(didEndSheet:returnCode:contextInfo:)
               contextInfo:nil];
    }
}

- (@action)handleButtonSave:(id)aSender
{
    [self _saveSelectedUserInfo];
}

///////////////////////////////////////////////////////////////////////////////
// Public Action Methods - Modal Window Buttons
///////////////////////////////////////////////////////////////////////////////
#pragma mark Public Action Methods - Modal Window Buttons
- (@action)handleButtonAddUserCancel:(id)aSender
{
    [CPApp endSheet:windowCreateUser returnCode:[aSender tag]];
}

- (@action)handleButtonAddUserSave:(id)aSender
{
    [self _createUser:[newUsername stringValue]];
    [CPApp endSheet:windowCreateUser returnCode:[aSender tag]];
}

- (@action)handleButtonConfirmDeleteYes:(id)aSender
{
    [self _deleteSelectedUser];
    [CPApp endSheet:windowConfirmDeleteUser returnCode:[aSender tag]];
}

- (@action)handleButtonConfirmDeleteNo:(id)aSender
{
    [CPApp endSheet:windowConfirmDeleteUser returnCode:[aSender tag]];
}

- (@action)handleButtonResetPasswordSave:(id)aSender
{
    console.log("TODO: set new password here");
    [CPApp endSheet:windowResetPassword returnCode:[aSender tag]];
}

- (@action)handleButtonResetPasswordCancel:(id)aSender
{
    [CPApp endSheet:windowResetPassword returnCode:[aSender tag]];
}

///////////////////////////////////////////////////////////////////////////////
// Private Methods
///////////////////////////////////////////////////////////////////////////////
- (void)_saveSelectedUserInfo
{
    if (_selectedUser != nil)
    {
       // [_selectedUser setUsername:selectedUserUsername];
        [_selectedUser setFirstName:[selectedUserFirstName stringValue]];
        [_selectedUser setLastName:[selectedUserLastName stringValue]];
        [_selectedUser setEmail:[selectedUserEmail stringValue]];
        [_selectedUser setIsActive:[selectedUserActive state]];
        [_selectedUser setIsStaff:[selectedUserStaffStatus state]];
        [_selectedUser setIsSuperuser:[selectedUserSuperuserStatus state]];
    }
}

- (void)_clearSelectedUserInfo
{
    [selectedUserUsername setStringValue:""];
    [selectedUserFirstName setStringValue:""];
    [selectedUserLastName setStringValue:""];
    [selectedUserEmail setStringValue:""];
    [selectedUserActive setState:0];
    [selectedUserStaffStatus setState:0];
    [selectedUserSuperuserStatus setState:0];
}

- (void)_createUser:(CPString)aUsername
{
    var newUser = [[User alloc] init];
    [newUser setUsername:aUsername];
    [newUser create];
}

- (void)_deleteSelectedUser
{
    var selectedObjects = [userArrayController selectedObjects];
    [selectedObjects makeObjectsPerformSelector:@selector(ensureDeleted)];
}

- (void)_fetchUsers
{
    [WLRemoteAction schedule:WLRemoteActionGetType
                    path:[self serverHost]+ "/users/"
                    delegate:self
                    message:"loading users"
                    withCredentials:YES];
}

- (void)_setSelectedUserInfo
{
    [self _clearSelectedUserInfo];
    if (_selectedUser != nil)
    {
        [selectedUserUsername setStringValue:[_selectedUser username]];
        [selectedUserFirstName setStringValue:[_selectedUser firstName]];
        [selectedUserLastName setStringValue:[_selectedUser lastName]];
        [selectedUserEmail setStringValue:[_selectedUser email]];
        [selectedUserActive setState:[_selectedUser isActive]];
        [selectedUserStaffStatus setState:[_selectedUser isStaff]];
        [selectedUserSuperuserStatus setState:[_selectedUser isSuperuser]];
    }
}

- (void)_isPasswordValid:(CPString)aPassword confirmedPassword:(CPString)aConfirmedPassword
{

}
@end
