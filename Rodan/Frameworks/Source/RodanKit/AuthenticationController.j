/**
 * This class handles all authentication to the remote server. Two types of
 * authentication are supported: "token" and "session" (see Rodan wiki).
 * The type of authentication can be set in the root Info.plist.
 *
 * This controller also offers the minimum requirements for a UI login
 * via its outlets.
 *
 * This also acts as a delegate for WLRemoteLink so it can add the
 * appropriate headers for REST calls.
 */

@import <AppKit/AppKit.j>
@import "../../Ratatosk/WLRemoteLink.j"
@import "RKController.j"
@import "User.j"

@global RodanDidLogInNotification
@global RodanDidLogOutNotification

activeUser = nil;

@implementation AuthenticationController : RKController
{
    @outlet     CPTextField         usernameField;
    @outlet     CPSecureTextField   passwordField;
    @outlet     CPButton            submitButton;
    @outlet     CPWindow            logInWindow;
                CPString            _authenticationType;
                CPString            _urlLogout;
                CPString            _urlLogin;
                CPString            _urlCheckIsAuthenticated;
                CPCookie            _CSRFToken;
                CPString            _authenticationToken;
}

///////////////////////////////////////////////////////////////////////////////
// Public Methods
///////////////////////////////////////////////////////////////////////////////
#pragma mark Public Methods
- (id)init
{
    if (self = [super init])
    {
        _authenticationType = [[CPBundle mainBundle] objectForInfoDictionaryKey:"AuthenticationType"];
        _urlLogout = [self serverHost] + "/auth/logout/";
        _urlCheckIsAuthenticated = [self serverHost] + "/auth/status/";
        _CSRFToken = nil;
        _authenticationToken = nil;

        switch (_authenticationType)
        {
            case "token":
                _urlLogin = [self serverHost] + "/auth/token/";
                break;

            case "session":
                _CSRFToken = [[CPCookie alloc] initWithName:@"csrftoken"];
                _urlLogin = [self serverHost] + "/auth/session/";
                break;

            default:
                //TODO: default auth or error?
                break;
        }
        [[WLRemoteLink sharedRemoteLink] setDelegate:self];
    }
    return self;
}

- (void)checkIsAuthenticated
{
    var request = [CPURLRequest requestWithURL:_urlCheckIsAuthenticated];
    [request setHTTPMethod:@"GET"];
    var conn = [CPURLConnection connectionWithRequest:request delegate:self withCredentials:YES];
}

- (void)runLogInSheet
{
    [logInWindow setDefaultButton:submitButton];
    [CPApp beginSheet:logInWindow
           modalForWindow:[CPApp mainWindow]
           modalDelegate:self
           didEndSelector:@selector(didEndSheet:returnCode:contextInfo:)
           contextInfo:nil];
}

- (void)didEndSheet:(CPWindow)aSheet returnCode:(int)returnCode contextInfo:(id)contextInfo
{
    [logInWindow orderOut:self];
    [self _logIn];
}

///////////////////////////////////////////////////////////////////////////////
// Public Action Methods
///////////////////////////////////////////////////////////////////////////////
#pragma mark Public Action Methods
- (@action)closeSheet:(id)aSender
{
    [CPApp endSheet:logInWindow returnCode:[aSender tag]];
}

- (@action)logOut:(id)aSender
{
    [self _logOut];
}

///////////////////////////////////////////////////////////////////////////////
// Public Delegate Methods
///////////////////////////////////////////////////////////////////////////////
#pragma mark Public Delegate Methods
- (void)connection:(CPURLConnection)connection didFailWithError:(id)error
{
    [connection cancel];
    CPLog("Failed with Error");
}

- (void)connection:(CPURLConnection)connection didReceiveResponse:(CPURLResponse)response
{
    CPLog("received a status code of " + [response statusCode]);

    switch ([response statusCode])
    {
        case 400:
            [connection cancel];
            [self _runAlert:[response statusCode] withMessage:"bad request"];
            break;

        case 401:
            [connection cancel];
            [self runLogInSheet];
            break;

        case 403:
            [connection cancel];
            break;

        default:
            break;
    }
}

- (void)connection:(CPURLConnection)connection didReceiveData:(CPString)data
{
    if (data)
    {
        var data = JSON.parse(data);

        if (data.hasOwnProperty('token') && _authenticationType == "token")
        {
            _authenticationToken = "Token " + data.token;
            [[CPNotificationCenter defaultCenter] postNotificationName:RodanDidLogInNotification
                                                  object:nil];
        }
        else if (data.hasOwnProperty('user') && _authenticationType == "session")
        {
            activeUser = [[User alloc] initWithJson:data];
            [[CPNotificationCenter defaultCenter] postNotificationName:RodanDidLogInNotification
                                                  object:activeUser];
        }
        else
        {
            [self _runAlert:@"You are logged in to the server, but on a different client. Please logout from that client and try again."];
        }
    }
}

///////////////////////////////////////////////////////////////////////////////
// Public Delegate Methods
///////////////////////////////////////////////////////////////////////////////
#pragma mark Public WLRemoteLink Delegate Methods
- (void)remoteLink:(WLRemoteLink)aLink willSendRequest:(CPURLRequest)aRequest withDelegate:(id)aDelegate context:(id)aContext
{
    [self _addAuthenticationHeaders:aRequest];
}

///////////////////////////////////////////////////////////////////////////////
// Private Methods
///////////////////////////////////////////////////////////////////////////////
#pragma mark Private Methods
- (void)_logIn
{
    var username = [usernameField objectValue],
        password = [passwordField objectValue];
    var request = [CPURLRequest requestWithURL:_urlLogin];
    request = [self _addAuthenticationHeaders:request];
    [request setValue:@"application/json" forHTTPHeaderField:@"Accept"];
    [request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"]
    [request setHTTPBody:@"username=" + username + "&password=" + password];
    [request setHTTPMethod:@"POST"];
    var conn = [CPURLConnection connectionWithRequest:request delegate:self withCredentials:YES];
}

- (void)_logOut
{
    activeUser = nil;
    var request = [CPURLRequest requestWithURL:_urlLogout];
    request = [self _addAuthenticationHeaders:request];
    [request setValue:@"application/json" forHTTPHeaderField:@"Accept"];
    [request setHTTPMethod:@"POST"];
    var conn = [CPURLConnection connectionWithRequest:request delegate:self withCredentials:YES];
    [[CPNotificationCenter defaultCenter] postNotificationName:RodanDidLogOutNotification
                                          object:nil];
}

- (void)_addAuthenticationHeaders:(CPURLRequest)aRequest
{
    if (_authenticationType == "session")
    {
        switch ([[aRequest HTTPMethod] uppercaseString])
        {
            case "POST":
            case "PUT":
            case "PATCH":
            case "DELETE":
                [aRequest setValue:[_CSRFToken value] forHTTPHeaderField:"X-CSRFToken"];
        }
    }
    else if (_authenticationType == "token")
    {
        if (_authenticationToken != nil)
        {
            [aRequest setValue:_authenticationToken forHTTPHeaderField:"Authorization"];
        }
    }
    else
    {
        // some default action
    }
    return aRequest;
}

- (void)_runAlert:(CPInteger)aStatusCode withMessage:(CPString)aMessage
{
    var error = "Error " + aStatusCode + ": " + aMessage;
    alert = [[CPAlert alloc] init];
    [alert setMessageText:error];
    [alert setAlertStyle:CPWarningAlertStyle];
    [alert addButtonWithTitle:@"Try Again"];
    [alert runModal];
}

- (void)_runAlert:(CPString)aMessage
{
    var error = "Error : " + aMessage;
    alert = [[CPAlert alloc] init];
    [alert setMessageText:error];
    [alert setAlertStyle:CPWarningAlertStyle];
    [alert addButtonWithTitle:@"OK"];
    [alert runModal];
}
@end