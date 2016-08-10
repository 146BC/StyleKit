#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface UIView (UIAppearance_Swift)
/// @param containers An array of Class<UIAppearanceContainer>
+ (instancetype)appearanceWhenContainedWithin: (NSArray *)containers;
@end