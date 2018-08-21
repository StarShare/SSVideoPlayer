
#import <Foundation/Foundation.h>
#import "SSAVPlayer.h"
#import "SSPlayerItem.h"
#import "SSPlayerUserInfo.h"

NS_ASSUME_NONNULL_BEGIN

@class SSAVPlayer;
@class SSPlayerItem;
@class SSPlayerUserInfo;

@interface SSPlayer : NSObject

@property(nonatomic, weak  ) id<SSPlayerDelegate> delegate;
@property(nonatomic, strong, readonly) SSAVPlayer *avPlayer;
@property(nonatomic, strong, readonly) UIView *view;
@property(nonatomic, strong, readonly) SSPlayerItem *playerItem;
@property(nonatomic, strong, readonly) SSPlayerUserInfo *userInfo;
@property(nonatomic, assign) float volume;
@property(nonatomic, assign) BOOL muted;
@property(nonatomic, assign) float rate;
@property(nonatomic, assign) SSPlayerScalingMode scalingMode;

+ (instancetype)playerWithURL:(NSURL *)URL;
- (instancetype)initWithURL:(NSURL *)URL;
- (void)play;
- (void)pause;
- (void)stop;
- (void)reloadPlayer;
- (void)seekToTime:(NSTimeInterval)time;
- (void)seekToTime:(NSTimeInterval)time completionHandler:(void (^ __nullable)(BOOL finished))completionHandler;
@end

NS_ASSUME_NONNULL_END
