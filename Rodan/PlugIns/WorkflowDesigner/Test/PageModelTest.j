@import "../../Rodan/Models/Page.j"
@import <Foundation/CPDate.j>

//example JSONObject to test RemoteProperties
 var jsonTest = {"url":"http://localhost:8000/page/5a1a0fe9f6644c1da684105e1f74b77b/",
                     "uuid":"5a1a0fe9f6644c1da684105e1f74b77b",
                     "project":"http://localhost:8000/project/6926998bb30d430bbb01267f29323207/",
                     "name":"url.jpg",
                     "page_image":"/uploads/projects/6926998bb30d430bbb01267f29323207/pages/5a1a0fe9f6644c1da684105e1f74b77b/original_file.jpg",
                     "compat_image":null,
                     "creator":{"url":"http://localhost:8000/user/1/",
                            "username":"HMSimmonds",
                            "first_name":"Harry",
                            "last_name":"Simmonds"},
                     "image_file_size":8745,
                     "compat_image_file_size":null,
                     "small_thumb_url":"/uploads/projects/6926998bb30d430bbb01267f29323207/pages/5a1a0fe9f6644c1da684105e1f74b77b/thumbnails/original_file_150.jpg",
                     "medium_thumb_url":"/uploads/projects/6926998bb30d430bbb01267f29323207/pages/5a1a0fe9f6644c1da684105e1f74b77b/thumbnails/original_file_400.jpg",
                     "large_thumb_url":"/uploads/projects/6926998bb30d430bbb01267f29323207/pages/5a1a0fe9f6644c1da684105e1f74b77b/thumbnails/original_file_1500.jpg",
                     "page_order":1,"created":"2014-05-23T17:23:22.778Z",
                     "processed":true,
                     "updated":"2014-05-23T17:23:22.783Z"};

@implementation PageModelTest : OJTestCase
{
    Page         pageTestObject       @accessors;
    User         userTestObject         @accessors;
}

- (void)setUp 
{
    //init. Page Model object w/ JSONObject
    pageTestObject = [[Page alloc] initWithJson:jsonTest];
    userTestObject = [[User alloc] initWithJson:jsonTest.creator];

    [self assertNotNull:pageTestObject];
}

- (void)testRemoteProperties
{
    //test if JSONObject  values are equal to Page Model Values
    [self assert:[pageTestObject pk] equals:jsonTest.url message:"pk"];
    [self assert:[pageTestObject uuid] equals:jsonTest.uuid message:"uuid"];
    [self assert:[pageTestObject projectURI] equals:jsonTest.project message:"projectURI"];
    [self assert:[pageTestObject pageName] equals:jsonTest.name message:"pageName"];
    [self assert:[pageTestObject imageFileSize] equals:jsonTest.image_file_size message:"imageFileSize"];
    [self assert:[pageTestObject compatFileSize] equals:jsonTest.compat_image_file_size message:"compatFileSize"];
    [self assert:[pageTestObject pageImage] equals:jsonTest.page_image message:"pageImage"];
    [self assert:[pageTestObject pageOrder] equals:jsonTest.page_order message:"pageOrder"];
    [self assert:[pageTestObject smallThumbURL] equals:jsonTest.small_thumb_url message:"smallThumbURL"];
    [self assert:[pageTestObject mediumThumbURL] equals:jsonTest.medium_thumb_url message:"mediumThumbURL"];
    [self assert:[pageTestObject largeThumbURL] equals:jsonTest.large_thumb_url message:"largeThumbURL"];
    [self assertTrue:[[pageTestObject created] isEqualToDate:jsonTest.created] message:"created"];
    [self assertTrue:[[pageTestObject updated] isEqualToDate:jsonTest.updated] message:"updated"];        
    [self assert:[pageTestObject creator] equals:userTestObject message:"creator"];
    [self assert:[pageTestObject processed] equals:jsonTest.processed message:"processed"];
}

- (void)testRemotePath
{    
    var returnValue;
    returnValue = [pageTestObject remotePath];
    if (returnValue != "/pages/") 
    {
        [self assert:[pageTestObject pk] equals:returnValue];
    }

}
@end