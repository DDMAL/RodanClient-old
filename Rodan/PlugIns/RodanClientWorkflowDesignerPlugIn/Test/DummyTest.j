// NOTE: class name must be the same as the file name (without .j extension)

@implementation DummyTest : OJTestCase
{
}

- (void)setUp
{
    // implement testing setup here
}

- (void)tearDown
{
    // implement testing tear down here
}

// this should pass
- (void)testOneEqualsOne
{
    [self assert:1 equals:1];
}

// this should fail
- (void)testOneEqualsTwo
{
    [self assert:1 equals:1];
}

@end