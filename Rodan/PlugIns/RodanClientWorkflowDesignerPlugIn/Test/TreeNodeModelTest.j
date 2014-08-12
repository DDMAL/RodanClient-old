@import "../../Rodan/Models/TreeNode.j"


var anIcon = [[CPImage alloc] initWithContentsOfFile:[[CPBundle mainBundle] pathForResource:@"job-sourcelist-icon.png"]
                                  size:CGSizeMake(16.0, 16.0)];

@implementation TreeNodeModelTest : OJTestCase
{
    //to test different Init. methods
    TreeNode            treeNodeTestObject          @accessors;
    TreeNode            treeNodeTestObject2         @accessors;
    TreeNode            treeNodeTestObject3         @accessors;
    TreeNode            treeNodeTestObject4         @accessors;
    TreeNode            treeNodeTestObject5         @accessors;
    TreeNode            treeNodeTestObject6         @accessors;

    CPImage             anIcon;
}

- (void)setUp
{
    //init. TreeNode Model object
    treeNodeTestObject = [[TreeNode alloc] init];

    [self assertNotNull:treeNodeTestObject];
}


- (void)testInitWithName
{
    treeNodeTestObject2 = [[TreeNode alloc] initWithName:"Node A"];
    [self assert:[treeNodeTestObject2 name] equals:"Node A"];
}

//with anIcon
- (void)testInitWithName2
{
    //init. icon
    treeNodeTestObject3 = [[TreeNode alloc] initWithName:"Node B" icon:anIcon];
    [self assert:[treeNodeTestObject3 name] equals:"Node B"];
    [self assert:[treeNodeTestObject3 icon] equals:anIcon];
}


- (void)testNodeDataWithName
{
    treeNodeTestObject4 = [TreeNode nodeDataWithName:"Node C"];
    [self assert:[treeNodeTestObject4 name] equals:"Node C"];
}

- (void)testNodeDataWithName2
{
    treeNodeTestObject5 = [TreeNode nodeDataWithName:"Node_D.highest_level" icon:anIcon];
    [self assert:[treeNodeTestObject5 name] equals:"Node_D.highest_level"];
    [self assert:[treeNodeTestObject5 icon] equals:anIcon];
}

- (void)testHumanName
{
    treeNodeTestObject6 = [[TreeNode alloc] initWithName:"Node_D.highest_level"];
    var returnValue = [treeNodeTestObject6 humanName];
    [self assert:returnValue equals:"Highest Level"];
}


@end