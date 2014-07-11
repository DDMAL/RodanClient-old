#import <Cocoa/Cocoa.h>
#import "xcc_general_include.h"

@interface Job : NSObject

@property (assign) IBOutlet NSString* name;
@property (assign) IBOutlet NSString* description;
@property (assign) IBOutlet BOOL* isEnabled;

@end
