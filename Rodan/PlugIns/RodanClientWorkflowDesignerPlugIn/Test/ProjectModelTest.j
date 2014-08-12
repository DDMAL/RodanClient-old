@import "../../Rodan/Models/Project.j"
@import <Foundation/CPDate.j>

//example JSONObject to test RemoteProperties
 var jsonTest = {"url":"http://localhost:8000/project/6926998bb30d430bbb01267f29323207/",
                 "name":"Test1",
                 "page_count":1,
                 "workflow_count":1,
                 "description":null,
                 "creator":"http://localhost:8000/user/1/",
                 "created":"2014-05-23T15:35:52.733Z",
                 "updated":"2014-05-23T15:36:02.298Z"};

@implementation ProjectModelTest : OJTestCase
{
    Project         projectTestObject       @accessors;
    Project         projectTestObject2      @accessors;
    Project         projectTestObject3      @accessors;
    User            userTestObject          @accessors;
}

- (void)setUp 
{
    //init. Project Model object w/ JSONObject
    projectTestObject = [[Project alloc] initWithJson:jsonTest];


    [self assertNotNull:projectTestObject];
}

- (void)testInit
{
    projectTestObject2 = [[Project alloc] init];
    [self assert:[projectTestObject2 projectName] equals:"Untitled Project"]
}

- (void)testInitWithCreator
{
    userTestObject = [[User alloc] init];
    [userTestObject setUsername:"HMSimmonds"];
    [userTestObject setFirstName:"Harry"];
    [userTestObject setLastName:"Simmonds"];

    projectTestObject3 = [[Project alloc] initWithCreator:userTestObject];
    [self assert:[projectTestObject3 projectCreator] equals:userTestObject];

}

- (void)testRemoteProperties
{
    //test if JSONObject  values are equal to Project Model Values
    [self assert:[projectTestObject pk] equals:jsonTest.url message:"pk"];
    [self assert:[projectTestObject projectName] equals:jsonTest.name message:"projectName"];
    [self assert:[projectTestObject projectDescription] equals:jsonTest.description message:"projectDescription"];
    [self assert:[projectTestObject projectCreator] equals:jsonTest.creator message:"projectCreator"];
    [self assertTrue:[[projectTestObject created] isEqualToDate:jsonTest.created] message:"created"];
    [self assertTrue:[[projectTestObject updated] isEqualToDate:jsonTest.updated] message:"updated"];  
}

- (void)testRemotePath
{    
    var returnValue;
    returnValue = [projectTestObject remotePath];
    if (returnValue != "/projects/") 
    {
        [self assert:[projectTestObject pk] equals:returnValue];
    }

}

@end

//test for minimal project
@implementation MinimalProjectModelTest : OJTestCase
{
    MinimalProject          minimalProjectTestObject        @accessors;
    MinimalProject          minimalProjectTestObject2       @accessors;
    User                    userTestObject                  @accessors;
    Page                    pageTestObject                  @accessors;
}

- (void)setUp 
{
    //init. MinimalProject Model object w/ JSONObject
    minimalProjectTestObject = [[MinimalProject alloc] initWithJson:jsonTest];
    // userTestObject = [[User alloc] initWithJson:jsonTest.creator]; --> creator is string
    // pageTestObject = [[Page alloc] initWithJson:jsonTest.pages]; --> No Page object in JSON


    [self assertNotNull:minimalProjectTestObject];
}


//No mapped projectOwner Field in JSONObject 
// - (void)testInitWithCreator
// {
//     // projectTestObject2 = [[MinimalProject alloc] iniWithCreator:userTestObject];

// }

- (void)testRemoteProperties
{
    //test if JSONObject  values are equal to MinimalProject Model Values
    [self assert:[minimalProjectTestObject pk] equals:jsonTest.url message:"pk"];
    [self assert:[minimalProjectTestObject projectName] equals:jsonTest.name message:"projectName"];
    [self assert:[minimalProjectTestObject projectDescription] equals:jsonTest.description message:"projectDescription"];
    [self assert:[minimalProjectTestObject projectCreator] equals:jsonTest.creator message:"projectCreator"];
    [self assertTrue:[[minimalProjectTestObject created] isEqualToDate:jsonTest.created] message:"created"];
    [self assertTrue:[[minimalProjectTestObject updated] isEqualToDate:jsonTest.updated] message:"updated"];  
}

- (void)testRemotePath
{    
    var returnValue;
    returnValue = [minimalProjectTestObject remotePath];
    if (returnValue != "/projects/") 
    {
        [self assert:[minimalProjectTestObject pk] equals:returnValue];
    }

}

@end