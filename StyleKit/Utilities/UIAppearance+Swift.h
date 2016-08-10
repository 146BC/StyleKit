#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface UIView (UIAppearance_Swift)
/// @param containers An array of Class<UIAppearanceContainer>
+ (instancetype)styleKitAppearanceWhenContainedWithin: (NSArray *)containers;
@end