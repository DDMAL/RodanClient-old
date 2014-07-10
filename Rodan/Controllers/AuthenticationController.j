/**
 * This class handles all authentication to the remote server. Two types of
 * authentication are supported: "token" and "session" (see Rodan wiki).
 * The type of authentication can be set in the root Info.plist.
 *
 * This also acts as a delegate for WLRemoteLink so it can add the
 * appropriate headers for REST calls.
 */

@import <AppKit/AppKit.j>
@import <Ratatosk/Ratatosk.j>
@import <RodanKit/Models/User.j>
@import "AbstractController.j"

@global RodanMustLogInNotification
@global RodanCannotLogInNotification
@global RodanDidLogInNotification
@global RodanDidLogOutNotification

@implementation AuthenticationController : AbstractController
{
    @outlet     CPTextField       usernameField;
    @outlet     CPSecureTextField passwordField;
    @outlet     CPButton          submitButton;
    @outlet     CPWindow          logInWindow;
                CPString          _authenticationType;
                CPString          _urlLogout;
                CPString          _urlLogin;
                CPString          _urlCheckIsAuthenticated;
                CPCookie          _CSRFToken;
                CPString          _authenticationToken;
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

- (void)logOut
{
    [self _logOut];
}

///////////////////////////////////////////////////////////////////////////////
// Public Action Methods
///////////////////////////////////////////////////////////////////////////////
#pragma mark Public Action Methods
- (@action)closeSheet:(id)aSender
{
    [CPApp endSheet:logInWindow returnCode:[aSender tag]];
}

///////////////////////////////////////////////////////////////////////////////
// Public Delegate Methods
///////////////////////////////////////////////////////////////////////////////
#pragma mark Public Delegate Methods
- (void)connection:(CPURLConnection)connection didFailWithError:(id)error
{
    CPLog("Failed with Error");
}

- (void)connection:(CPURLConnection)connection didReceiveResponse:(CPURLResponse)response
{
    CPLog("received a status code of " + [response statusCode]);

    switch ([response statusCode])
    {
        case 400:
            [self _runAlert:[response statusCode] withMessage:"bad request"];
            [connection cancel];
            break;

        case 401:
            [connection cancel];
            [[CPNotificationCenter defaultCenter] postNotificationName:RodanMustLogInNotification
                                                  object:nil];
            [connection cancel];
            break;

        case 403:
            [[CPNotificationCenter defaultCenter] postNotificationName:RodanCannotLogInNotification
                                                  object:nil];
            [connection cancel]
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

        if (data.hasOwnProperty('token'))
        {
            _authenticationToken = "Token " + data.token;
            [[CPNotificationCenter defaultCenter] postNotificationName:RodanDidLogInNotification
                                                  object:nil];
        }
        else
        {
            var user = [[User alloc] initWithJson:data];
            [[CPNotificationCenter defaultCenter] postNotificationName:RodanDidLogInNotification
                                                  object:user];
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
    var request = [CPURLRequest requestWithURL:_urlLogout];
    request = [self _addAuthenticationHeaders:request];
    [request setValue:@"application/json" forHTTPHeaderField:@"Accept"];
    [request setHTTPMethod:@"POST"];
    var conn = [CPURLConnection connectionWithRequest:request delegate:self withCredentials:YES];
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
@end