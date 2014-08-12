@import <Foundation/Foundation.j>

//import models
@import <RodanKit/RodanKit.j>
@import <RodanKit/Models/Connection.j>
@import <RodanKit/Models/Workflow.j>
@import <RodanKit/Models/WorkflowJob.j>
@import <RodanKit/Models/OutputPort.j>
@import <RodanKit/Models/InputPort.j>

@implementation DeleteCache : CPObject 
{
    CPArrayController     connectionsToDelete     @accessors;

}

- (id)init 
{
    self = [super init];

    connectionsToDelete = [[CPArrayController alloc] init];

    return self;
}


- (CPInteger)_hasConnection:(Connection)aConnection 
{
    var i,
        loopCount = [[connectionsToDelete contentArray] count],
        contentArray = [connectionsToDelete contentArray];

    for (i = 0; i < loopCount; i++) 
    {
        if (aConnection == contentArray[i]) 
            return i; //return index at which it exists
    };

    return -1; //no connection
}

//returns true if connection existed and deleted, otherwise false, connection did not exist in cache
- (BOOL)shouldDeleteConnection:(Connection)aConnection
{
    var connectionExists = [self _hasConnection:aConnection];
    
    if (connectionExists != -1)
    {
        console.log([aConnection pk]);
        [aConnection ensureDeleted]; //remove from server
        [connectionsToDelete removeObjectAtArrangedObjectIndex:connectionExists];
    }
    
    else {
        return false;
    }
}



@end