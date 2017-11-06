#import <Foundation/Foundation.h>
#import "SKTryCatch.h"

@implementation SKTryCatch

/**
 Provides try catch functionality for swift by wrapping around Objective-C
 */
+ (void)tryBlock:(void(^)(void))tryBlock catchBlock:(void(^)(NSException*exception))catchBlock finallyBlock:(void(^)(void))finallyBlock {
    @try {
        tryBlock ? tryBlock() : nil;
    }

    @catch (NSException *exception) {
        catchBlock ? catchBlock(exception) : nil;
    }
    @finally {
        finallyBlock ? finallyBlock() : nil;
    }
}

+ (void)throwString:(NSString*)s
{
    @throw [NSException exceptionWithName:s reason:s userInfo:nil];
}

+ (void)throwException:(NSException*)e
{
    @throw e;
}

@end
