
#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
#import "SSPlayerUserInfo.h"
#import "SSPlayerDelegate.h"

NS_ASSUME_NONNULL_BEGIN

@class AVPlayer;
@class SSPlayerLayer;
@class SSAsset;
@class SSPlayerItem;
@class SSPlayerLoader;
@class SSPlayerUserInfo;
@class SSBufferTimer;

@interface SSAVPlayer : NSObject

@property(nonatomic, weak  ) id<SSPlayerDelegate> delegate;
@property(nonatomic, strong, readonly) AVPlayer *player;
@property(nonatomic, strong, readonly) SSPlayerLayer *playerLayer;
@property(nonatomic, strong, readonly) SSPlayerItem *playerItem;
@property(nonatomic, strong, readonly) SSPlayerUserInfo *userInfo;
@property(nonatomic, assign) float volume;
@property(nonatomic, assign) BOOL muted;
@property(nonatomic, assign) float rate;
@property(nonatomic, assign) SSPlayerScalingMode scalingMode;
@property(nonatomic, assign) float timeout;

+ (instancetype)playerWithURL:(NSURL *)URL;
- (instancetype)initWithURL:(NSURL *)URL;
- (void)play;
- (void)pause;
- (void)stop;
- (void)reloadPlayer;
- (void)seekToTime:(NSTimeInterval)time;
- (void)seekToTime:(NSTimeInterval)time completionHandler:(void (^ __nullable)(BOOL finished))completionHandler;
@end

@interface SSPlayerLayer : UIView

@property(nonatomic, strong) SSAVPlayer *player;
@property(nonatomic, strong) AVLayerVideoGravity videoGravity;
@end

NS_ASSUME_NONNULL_END
