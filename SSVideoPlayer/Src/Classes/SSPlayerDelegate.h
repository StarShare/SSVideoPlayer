
#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@class SSAVPlayer;

@protocol SSPlayerDelegate <NSObject>
@optional
- (void)player:(SSAVPlayer *)player playStateChanged:(SSPlayerPlaybackState)state;
- (void)player:(SSAVPlayer *)player loadStateChanged:(SSPlayerLoadState)state;
- (void)player:(SSAVPlayer *)player updateDuration:(NSTimeInterval)duration;
- (void)player:(SSAVPlayer *)player updateCurrentDuration:(NSTimeInterval)duration;
- (void)player:(SSAVPlayer *)player updateBufferDuration:(NSTimeInterval)duration;
@end

NS_ASSUME_NONNULL_END
