#ifndef SwiftTryCatch_h
#define SwiftTryCatch_h

@interface SKTryCatch : NSObject

/**
 Provides try catch functionality for swift by wrapping around Objective-C
 */
+ (void)tryBlock:(void(^)(void))tryBlock catchBlock:(void(^)(NSException*exception))catchBlock finallyBlock:(void(^)(void))finallyBlock;
+ (void)throwString:(NSString*)s;
+ (void)throwException:(NSException*)e;
@end

#endif /* SwiftTryCatch_h */
