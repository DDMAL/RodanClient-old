@import "../../Rodan/Models/User.j"

//example JSONObject to test RemoteProperties
 var jsonTest = {"url":"http://localhost:8000/user/1/",
                 "username": "ahankins", 
                 "first_name": "", 
                 "last_name": "", 
                 "is_active": true, 
                 "is_superuser": true, 
                 "is_staff": true, 
                 "last_login": "2014-05-17T19:30:37.735Z", 
                 "groups": [], 
                 "user_permissions": [], 
                 "email": "a@h.com", };

@implementation UserModelTest : OJTestCase
{
    User         userTestObject       @accessors;

}

- (void)setUp 
{
    //init. User Model object w/ JSONObject
    userTestObject = [[User alloc] initWithJson:jsonTest];

    [self assertNotNull:userTestObject];
}

- (void)testRemoteProperties
{
    //test if JSONObject  values are equal to User Model Values
    [self assert:[userTestObject pk] equals:jsonTest.url message:"pk"];
    [self assert:[userTestObject username] equals:jsonTest.username message:"username"];
    [self assert:[userTestObject firstName] equals:jsonTest.first_name message:"firstName"];
    [self assert:[userTestObject lastName] equals:jsonTest.last_name message:"lastName"];
    [self assert:[userTestObject isActive] equals:jsonTest.is_active message:"isActive"];
    [self assert:[userTestObject isStaff] equals:jsonTest.is_staff message:"isStaff"];
    [self assert:[userTestObject isSuperuser] equals:jsonTest.is_superuser message:"isSuperuser"];
    [self assert:[userTestObject email] equals:jsonTest.email message:"email"];
    [self assert:[userTestObject groups] equals:jsonTest.groups message:"groups"];
}

@end