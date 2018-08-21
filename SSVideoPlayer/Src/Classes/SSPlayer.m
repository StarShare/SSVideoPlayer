
#import "SSPlayer.h"

@interface SSPlayer ()

@property(nonatomic, strong) SSAVPlayer *avPlayer;
@property(nonatomic, strong) UIView *view;
@property(nonatomic, strong) SSPlayerItem *playerItem;
@property(nonatomic, strong) SSPlayerUserInfo *userInfo;
@end

@implementation SSPlayer

+ (instancetype)playerWithURL:(NSURL *)URL {
  return [[self alloc] initWithURL:URL];
}

- (instancetype)initWithURL:(NSURL *)URL {
  if (URL == nil) {
    return nil;
  }
  self = [super init];
  if (self) {
    self.avPlayer = [SSAVPlayer playerWithURL:URL];
  }
  return self;
}

- (void)play {
  [self.avPlayer play];
}

- (void)reloadPlayer {
  [self.avPlayer reloadPlayer];
}

- (void)pause {
  [self.avPlayer pause];
}

- (void)stop {
  [self.avPlayer stop];
}

- (void)seekToTime:(NSTimeInterval)time {
  [self.avPlayer seekToTime:time];
}

- (void)seekToTime:(NSTimeInterval)time completionHandler:(void (^ __nullable)(BOOL finished))completionHandler {
  [self.avPlayer seekToTime:time completionHandler:completionHandler];
}

#pragma mark - Getter

- (id)delegate {
  return self.avPlayer.delegate;
}

- (UIView *)view {
  return self.avPlayer.playerLayer;
}

- (SSPlayerItem *)playerItem {
  return self.avPlayer.playerItem;
}

- (SSPlayerUserInfo *)userInfo {
  return self.avPlayer.userInfo;
}

- (float)volume {
  return self.avPlayer.volume;
}

- (BOOL)muted {
  return self.avPlayer.muted;
}

- (float)rate {
  return self.avPlayer.rate;
}

- (SSPlayerScalingMode)scalingMode {
  return self.avPlayer.scalingMode;
}

#pragma mark - Setter

- (void)setDelegate:(id)delegate {
  [self.avPlayer setDelegate:delegate];
}

- (void)setVolume:(float)volume {
  [self.avPlayer setVolume:volume];
}

- (void)setMuted:(BOOL)muted {
  [self.avPlayer setMuted:muted];
}

- (void)setRate:(float)rate {
  [self.avPlayer setRate:rate];
}

- (void)setScalingMode:(SSPlayerScalingMode)scalingMode {
  [self.avPlayer setScalingMode:scalingMode];
}
@end
