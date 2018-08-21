
#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface SSBufferTimer : NSObject

+ (SSBufferTimer *)repeatingTimerWithTimeInterval:(NSTimeInterval)seconds
                                            block:(void (^ __nullable)(SSBufferTimer *timer))block;
- (void)fire;
- (void)invalidate;
@end

NS_ASSUME_NONNULL_END
