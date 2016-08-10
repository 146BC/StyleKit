#import "UIAppearance+Swift.h"

@implementation UIView (UIAppearance_Swift)

+ (instancetype)styleKitAppearanceWhenContainedWithin: (NSArray *)containers
{
    //Refer to: http://stackoverflow.com/a/28765193
    
    NSUInteger count = containers.count;
    NSAssert(count <= 10, @"Nested style levels greater than 10 is only supported from iOS 9+");
    
    return [self appearanceWhenContainedIn:
            count > 0 ? containers[0] : nil,
            count > 1 ? containers[1] : nil,
            count > 2 ? containers[2] : nil,
            count > 3 ? containers[3] : nil,
            count > 4 ? containers[4] : nil,
            count > 5 ? containers[5] : nil,
            count > 6 ? containers[6] : nil,
            count > 7 ? containers[7] : nil,
            count > 8 ? containers[8] : nil,
            count > 9 ? containers[9] : nil,
            nil];
}
@end