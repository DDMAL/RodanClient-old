@import <Foundation/CPObject.j>

@implementation JobView : CPObject
{
    @outlet     CPString        name;
    @outlet     CPString        description;
    @outlet     BOOL            isEnabled;

    //settings of job

}

//entry in table view - implement controller


@end