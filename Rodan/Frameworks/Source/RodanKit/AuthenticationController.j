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
@import <Foundation/CPURL.j>
@import "../../Ratatosk/WLRemoteLink.j"
@import "RKController.j"
@import "User.j"

@global RodanDidLogInNotification
@global RodanDidLogOutNotification

activeUser = nil;

var _authenticationTokenValue = nil;
var _CSRFToken = nil;

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
                CPString            _authenticationHeader; // Either "Authorization" or "X-CSRFToken".

}

///////////////////////////////////////////////////////////////////////////////
// Public Static Methods
///////////////////////////////////////////////////////////////////////////////
#pragma mark Public Static Methods

/**
    Returns value of token authorization IFF it has been set (token authentication only).
 */
+ (CPString)tokenAuthorizationValue
{
    return _authenticationTokenValue;
}

/**
    Returns value of csrfmiddlewaretoken IFF it has been set (session authentication only).
 */
+ (CPString)csrfmiddlewaretokenValue
{
    if (_CSRFToken !== nil)
        return [_CSRFToken value];

    return nil;
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
        _urlLogout = [CPURL URLWithString:[self serverHost] + "/auth/logout/"];
        _urlCheckIsAuthenticated = [CPURL URLWithString:[self serverHost] + "/auth/status/"];
        _CSRFToken = nil;
        _authenticationTokenValue = nil;
        _authenticationHeader = nil;

        switch (_authenticationType)
        {
            case "token":
                _urlLogin = [CPURL URLWithString:[self serverHost] + "/auth/token/"];
                _authenticationHeader = @"Authorization";
                break;

            case "session":
                _CSRFToken = [[CPCookie alloc] initWithName:@"csrftoken"];
                _authenticationHeader = @"X-CSRFToken";
                _urlLogin = [CPURL URLWithString:[self serverHost] + "/auth/session/"];
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
            _authenticationTokenValue = "Token " + data.token;
            [[CPNotificationCenter defaultCenter] postNotificationName:RodanDidLogInNotification
                                                  object:nil];
        }
        else if (data.hasOwnProperty('username') && _authenticationType == "session")
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
        password = [passwordField objectValue],
        request = [self _createRequestWithAuthenticationHeaders:_urlLogin];

    [request setValue:@"application/json" forHTTPHeaderField:@"Accept"];
    [request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"]
    [request setHTTPBody:@"username=" + username + "&password=" + password];
    [request setHTTPMethod:@"POST"];
    var conn = [CPURLConnection connectionWithRequest:request delegate:self withCredentials:YES];
}

- (void)_logOut
{
    activeUser = nil;

    var request = [self _createRequestWithAuthenticationHeaders:_urlLogout];
    [request setValue:@"application/json" forHTTPHeaderField:@"Accept"];
    [request setHTTPMethod:@"POST"];
    var conn = [CPURLConnection connectionWithRequest:request delegate:self withCredentials:YES];
    [[CPNotificationCenter defaultCenter] postNotificationName:RodanDidLogOutNotification
                                          object:nil];
}

- (CPURLRequest)_createRequestWithAuthenticationHeaders:(CPURL)aUrl
{
    var request = [CPURLRequest requestWithURL:aUrl];
    return [self _addAuthenticationHeaders:request];
}

- (CPURLRequest)_addAuthenticationHeaders:(CPURLRequest)aRequest
{
    if (_authenticationType == "session")
    {
        switch ([[aRequest HTTPMethod] uppercaseString])
        {
            case "POST":
            case "PUT":
            case "PATCH":
            case "DELETE":
                [aRequest setValue:[_CSRFToken value] forHTTPHeaderField:_authenticationHeader];
        }
    }
    else if (_authenticationType == "token")
    {
        if (_authenticationTokenValue != nil)
        {
            [aRequest setValue:_authenticationTokenValue forHTTPHeaderField:_authenticationHeader];
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