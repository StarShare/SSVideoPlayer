
#import "SSAVPlayer.h"
#import "SSPlayerUserInfo.h"
#import "SSPlayerItem.h"
#import "SSAsset.h"
#import "SSPlayerLoader.h"
#import "SSBufferTimer.h"
#import <objc/message.h>
#import <pthread/pthread.h>

#define SuppressPerformSelectorLeakWarning(Stuff) \
do { \
  _Pragma("clang diagnostic push") \
  _Pragma("clang diagnostic ignored \"-Warc-performSelector-leaks\"") \
  Stuff; \
  _Pragma("clang diagnostic pop") \
} while (0)

#define DeassignPropertyValueIfNeed(property,value)  property = value;

@interface SSPlayerUserInfo ()

@property(nonatomic, strong) NSError *error;
@property(nonatomic, assign) BOOL isPlaying;
@property(nonatomic, assign) BOOL isBuffering;
@property(nonatomic, assign) BOOL isSeeking;
@property(nonatomic, assign) BOOL isObserving;
@property(nonatomic, assign) SSPlayerPlaybackState playState;
@property(nonatomic, assign) SSPlayerLoadState loadState;
@property(nonatomic, assign) NSTimeInterval lastStalledTime;
@property(nonatomic, assign) NSTimeInterval duration;
@property(nonatomic, assign) NSTimeInterval currentDuration;
@property(nonatomic, assign) NSTimeInterval bufferDuration;
@property(nonatomic, assign) CGSize presentationSize;
@property(nonatomic, assign) SSPlayerScalingMode scalingMode;
@property(nonatomic, assign) float volume;
@property(nonatomic, assign) BOOL isMuted;
@property(nonatomic, assign) float rate;
@end

@interface SSAVPlayerObserver : NSObject

@property(nonatomic, weak) SSAVPlayer *player;
@property(nonatomic, strong, readonly) SSPlayerUserInfo *userInfo;
@end

@implementation SSAVPlayerObserver

- (void)observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(id)object
                        change:(NSDictionary<NSKeyValueChangeKey,id> *)change
                       context:(void *)context {
  @weakify(self);
  dispatch_async(dispatch_get_main_queue(), ^{
    @strongify(self);
    if (nil == object) return;
    if (nil == self.player) return;
    AVPlayerItem *playerItem = (AVPlayerItem *)object;
    
    if ([keyPath isEqualToString:@"status"]) {
      if (playerItem.status == AVPlayerItemStatusReadyToPlay) {
        if (playerItem.seekableTimeRanges.count > 0 &&
            playerItem.duration.timescale != 0) {
          [self.userInfo setDuration:CMTimeGetSeconds(playerItem.duration)];
        }
        self.userInfo.error = nil;
        DeassignPropertyValueIfNeed(self.userInfo.loadState,SSPlayerLoadStateReadyToPlay);
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)),
                       dispatch_get_main_queue(), ^{
                         @strongify(self);
                         SuppressPerformSelectorLeakWarning(
                           [self.player performSelector:NSSelectorFromString(@"readyToPlay")];
                         );
                       });
      } else if (playerItem.status == AVPlayerItemStatusFailed) {
        if (playerItem.error) {
          self.userInfo.error = playerItem.error;
        } else if (self.player.player.error) {
          self.userInfo.error = self.player.player.error;
        } else {
          self.userInfo.error = [NSError errorWithDomain:@"AVPlayerItemStatusFailed"
                                                    code:SSPlayerErrorItemFailed
                                                userInfo:nil];
        }
        if (self.userInfo.error) {
          SuppressPerformSelectorLeakWarning(
            [self.player performSelector:NSSelectorFromString(@"errorCallback")];
          );
        }
      } else if (playerItem.status == AVPlayerItemStatusUnknown) {
        NSLog(@"AVPlayerItemStatusUnknown");
      }
    } else
    
    if ([keyPath isEqualToString:@"playbackBufferEmpty"]) {
      if (playerItem.isPlaybackBufferEmpty &&
          self.userInfo.error == nil) {
        DeassignPropertyValueIfNeed(self.userInfo.loadState,SSPlayerLoadStateStalled);
        if (@available(iOS 10.0, *)) {
          if (self.player.player.automaticallyWaitsToMinimizeStalling == NO) {
            SuppressPerformSelectorLeakWarning(
              [self.player performSelector:NSSelectorFromString(@"stalledWithPlaybackBufferEmpty")];
            );
          }
        } else {
          SuppressPerformSelectorLeakWarning(
            [self.player performSelector:NSSelectorFromString(@"stalledWithPlaybackBufferEmpty")];
          );
        }
      }
    } else
      
    if ([keyPath isEqualToString:@"playbackLikelyToKeepUp"]) {
      if (playerItem.isPlaybackLikelyToKeepUp &&
          self.userInfo.error == nil) {
        DeassignPropertyValueIfNeed(self.userInfo.loadState,SSPlayerLoadStatePlayable);
        SuppressPerformSelectorLeakWarning(
          [self.player performSelector:NSSelectorFromString(@"continueWithPlaybackLikelyToKeepUp")];
        );
      }
    } else
      
    if ([keyPath isEqualToString:@"playbackBufferFull"]) {
      if (playerItem.isPlaybackBufferFull) {
        /// PlaybackBufferFull
      }
    } else
      
    if ([keyPath isEqualToString:@"loadedTimeRanges"]) {
      SuppressPerformSelectorLeakWarning(
        [self.player performSelector:NSSelectorFromString(@"updateBufferDuration")];
      );
    } else
      
    if ([keyPath isEqualToString:@"presentationSize"]) {
      self.userInfo.presentationSize = playerItem.presentationSize;
    } else {
      [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    }
  });
}

#pragma mark - Getter

- (SSPlayerUserInfo *)userInfo {
  return self.player.userInfo;
}
@end

@interface SSAVPlayer () <SSPlayerUserInfoDelegate>

@property(nonatomic, strong) AVPlayer *player;
@property(nonatomic, strong) NSURL *assetURL;
@property(nonatomic, strong) SSPlayerLayer *playerLayer;
@property(nonatomic, strong) SSPlayerItem *playerItem;
@property(nonatomic, strong) SSPlayerUserInfo *userInfo;
@property(nonatomic, strong) SSAVPlayerObserver *observer;
@property(nonatomic, assign) BOOL playerPrepared;
@property(nonatomic, assign, readonly) NSTimeInterval preferredBufferDurationBeforePlayback;
@property(nonatomic, assign, readonly) BOOL seekEnable;
@property(nonatomic, assign) float seekTime;
@property(nonatomic, assign) void (^seekCompletionHandler)(BOOL finished);
@end

@implementation SSAVPlayer {
  id _palyerTimeObserver;
  id _palyerItemDidPlayToEndTimeObserver;
  id _palyerItemFailedPlayToEndTimeObserver;
  SSBufferTimer *_seekingLoopTimer;
  SSBufferTimer *_bufferingLoopTimer;
  BOOL _isPlayingBeforeEnterBackground;
}

- (void)dealloc {
  [self forceStop];
  if (_seekingLoopTimer) {
    [_seekingLoopTimer invalidate];
    _seekingLoopTimer = nil;
  }
  if (_bufferingLoopTimer) {
    [_bufferingLoopTimer invalidate];
    _bufferingLoopTimer = nil;
  }
  [self.playerItem destroy];
  [self setPlayerItem:nil];
  [self.playerLayer removeFromSuperview];
  [self setUserInfo:nil];
  [self setObserver:nil];
  [self setSeekCompletionHandler:NULL];
}

+ (instancetype)playerWithURL:(NSURL *)URL {
  return [[self alloc] initWithURL:URL];
}

- (instancetype)initWithURL:(NSURL *)URL {
  self = [super init];
  if (self) {
    self.assetURL    = URL;
    self.userInfo    = [[SSPlayerUserInfo alloc] init];
    self.observer    = [[SSAVPlayerObserver alloc] init];
    self.playerLayer = [[SSPlayerLayer alloc] init];
    self.playerLayer.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    self.seekTime    = -1;
    self.timeout     = 60;
    self.userInfo.delegate = self;
  }
  return self;
}

- (void)play {
  if (self.playerPrepared == NO) {
    [self prepareToPlay];
  } else {
    [self playIfNeed];
    DeassignPropertyValueIfNeed(self.userInfo.isPlaying,YES);
    DeassignPropertyValueIfNeed(self.userInfo.playState,SSPlayerPlayStatePlaying);
  }
}

- (void)playIfNeed {
  if (self.userInfo.loadState == SSPlayerLoadStateReadyToPlay ||
      self.userInfo.loadState == SSPlayerLoadStatePlayable) {
    [self.player play];
    if (self.userInfo.rate != self.player.rate) self.player.rate = self.userInfo.rate;
    if (self.userInfo.volume != self.player.volume) self.player.volume = self.userInfo.volume;
    if (self.userInfo.isMuted != self.player.muted) self.player.muted = self.userInfo.isMuted;
  }
}

- (void)prepareToPlay {
  if (self.assetURL == nil) return;
  [self initializePlayer];
  [self play];
}

- (void)reloadPlayer {
  [self prepareToPlay];
}

- (void)readyToPlay {
  if(self.seekTime >= 0) {
    [self seekToTime:self.seekTime completionHandler:^(BOOL finished) {
      if (self.seekCompletionHandler) {
        self.seekCompletionHandler(finished);
        self.seekCompletionHandler = NULL;
      }
    }];
  } else {
    if (self.userInfo.isPlaying) {
      [self play];
    }
  }
}

- (void)pause {
  if (self.playerPrepared && self.userInfo.isPlaying) {
    [self.player pause];
    DeassignPropertyValueIfNeed(self.userInfo.isPlaying,NO);
    DeassignPropertyValueIfNeed(self.userInfo.playState,SSPlayerPlayStatePaused);
  }
}

- (void)stop {
  if (self.playerPrepared) {
    [self forceStop];
  }
}

- (void)forceStop {
  [self beginStop];
  DeassignPropertyValueIfNeed(self.userInfo.playState,SSPlayerPlayStatePlayStopped);
}

- (void)errorStop {
  [self beginStop];
  DeassignPropertyValueIfNeed(self.userInfo.playState,SSPlayerPlayStatePlayFailed);
}

- (void)beginStop {
  [self.player pause];
  [self.player cancelPendingPrerolls];
  [self.player setRate:0.0f];
  [self remPlayerObserverIfNeed];
  DeassignPropertyValueIfNeed(self.userInfo.isPlaying,NO);
  DeassignPropertyValueIfNeed(self.userInfo.isBuffering,NO);
  DeassignPropertyValueIfNeed(self.userInfo.isObserving,NO);
  DeassignPropertyValueIfNeed(self.userInfo.isSeeking,NO);
  self.player = nil;
  self.playerPrepared = NO;
}

- (void)seekToTime:(NSTimeInterval)time {
  [self seekToTime:time completionHandler:NULL];
}

- (void)seekToTime:(NSTimeInterval)time completionHandler:(void (^ __nullable)(BOOL finished))completionHandler {
  if (self.seekEnable) {
    @weakify(self);
    DeassignPropertyValueIfNeed(self.userInfo.isSeeking,YES);
    self.seekTime = -1;
    [self.player pause];
    [self.player seekToTime:CMTimeMake(time, 1)
            toleranceBefore:CMTimeMake(1,1)
             toleranceAfter:CMTimeMake(1,1)
          completionHandler:^(BOOL finished) {
            @strongify(self);
            DeassignPropertyValueIfNeed(self.userInfo.isSeeking,NO);
            [self play];
            if (completionHandler) {
              completionHandler(finished);
            }
          }];
  } else {
    self.seekCompletionHandler = completionHandler;
    self.seekTime = time;
  }
}

#pragma mark Player SetUp

- (BOOL)initializePlayer {
  self.playerItem = [[SSPlayerItem alloc] initWithURL:self.assetURL];
  self.player = [AVPlayer playerWithPlayerItem:[self.playerItem avPlayerItem]];
  self.player.actionAtItemEnd = AVPlayerActionAtItemEndPause;
  if (@available(iOS 10.0, *)) {
    self.player.automaticallyWaitsToMinimizeStalling = NO;
  }
  self.userInfo.volume = self.player.volume;
  self.scalingMode = self.userInfo.scalingMode;
  [self.playerLayer setPlayer:self];
  [self.observer setPlayer:self];
  [self addPlayerObserverIfNeed];
  DeassignPropertyValueIfNeed(self.playerPrepared,YES);
  DeassignPropertyValueIfNeed(self.userInfo.loadState,SSPlayerLoadStatePrepare);
  
  return YES;
}

- (void)addPlayerObserverIfNeed {
  if (self.userInfo.isObserving) [self remPlayerObserverIfNeed];
  DeassignPropertyValueIfNeed(self.userInfo.isObserving,YES);
  
  [[self avPlayerItem] addObserver:self.observer
                        forKeyPath:@"status"
                           options:NSKeyValueObservingOptionNew
                           context:nil];
  [[self avPlayerItem] addObserver:self.observer
                        forKeyPath:@"loadedTimeRanges"
                           options:NSKeyValueObservingOptionNew
                           context:nil];
  [[self avPlayerItem] addObserver:self.observer
                        forKeyPath:@"playbackBufferEmpty"
                           options:NSKeyValueObservingOptionNew
                           context:nil];
  [[self avPlayerItem] addObserver:self.observer
                        forKeyPath:@"playbackBufferFull"
                           options:NSKeyValueObservingOptionNew
                           context:nil];
  [[self avPlayerItem] addObserver:self.observer
                        forKeyPath:@"playbackLikelyToKeepUp"
                           options:NSKeyValueObservingOptionNew
                           context:nil];
  [[self avPlayerItem] addObserver:self.observer
                        forKeyPath:@"presentationSize"
                           options:NSKeyValueObservingOptionNew
                           context:nil];
  
  CMTime interval = CMTimeMakeWithSeconds(0.5, NSEC_PER_SEC);
  @weakify(self);
  _palyerTimeObserver =
  [self.player addPeriodicTimeObserverForInterval:interval
                                            queue:dispatch_get_main_queue()
                                       usingBlock:^(CMTime time) {
                                         @strongify(self);
                                         if(nil == self) return;
                                         AVPlayerItem *playerItem = [self avPlayerItem];
                                         if(nil == playerItem) return;
                                         
                                         if (playerItem.seekableTimeRanges.count > 0 &&
                                             playerItem.duration.timescale != 0) {
                                           DeassignPropertyValueIfNeed(self.userInfo.duration,CMTimeGetSeconds(playerItem.duration));
                                           DeassignPropertyValueIfNeed(self.userInfo.currentDuration,CMTimeGetSeconds(time));
                                         }
                                       }];
  
  _palyerItemDidPlayToEndTimeObserver =
  [[NSNotificationCenter defaultCenter] addObserverForName:AVPlayerItemDidPlayToEndTimeNotification
                                                    object:[self avPlayerItem]
                                                     queue:[NSOperationQueue mainQueue]
                                                usingBlock:^(NSNotification * _Nonnull note) {
                                                  @strongify(self);
                                                  if(nil == self) return;
                                                  DeassignPropertyValueIfNeed(self.userInfo.playState,SSPlayerPlayStatePlayFinished);
                                                }];
  _palyerItemFailedPlayToEndTimeObserver =
  [[NSNotificationCenter defaultCenter] addObserverForName:AVPlayerItemFailedToPlayToEndTimeNotification
                                                    object:[self avPlayerItem]
                                                     queue:[NSOperationQueue mainQueue]
                                                usingBlock:^(NSNotification * _Nonnull note) {
                                                  @strongify(self);
                                                  if(nil == self) return;
                                                  NSError *error = note.userInfo[AVPlayerItemFailedToPlayToEndTimeErrorKey];
                                                  if (error) [self errorCallback];
                                                }];
  [[NSNotificationCenter defaultCenter] addObserver:self
                                           selector:@selector(applicationWillEnterForeground)
                                               name:UIApplicationWillEnterForegroundNotification
                                             object:nil];
  [[NSNotificationCenter defaultCenter] addObserver:self
                                           selector:@selector(applicationDidEnterBackground)
                                               name:UIApplicationDidEnterBackgroundNotification
                                             object:nil];
}

- (void)remPlayerObserverIfNeed {
  if (self.userInfo.isObserving == NO) {return;}
  DeassignPropertyValueIfNeed(self.userInfo.isObserving,NO);
  
  @try {
    [[self avPlayerItem] removeObserver:self.observer forKeyPath:@"status" context:nil];
    [[self avPlayerItem] removeObserver:self.observer forKeyPath:@"loadedTimeRanges" context:nil];
    [[self avPlayerItem] removeObserver:self.observer forKeyPath:@"playbackBufferEmpty" context:nil];
    [[self avPlayerItem] removeObserver:self.observer forKeyPath:@"playbackBufferFull" context:nil];
    [[self avPlayerItem] removeObserver:self.observer forKeyPath:@"playbackLikelyToKeepUp" context:nil];
    [[self avPlayerItem] removeObserver:self.observer forKeyPath:@"presentationSize" context:nil];
    
    [self.player removeTimeObserver:_palyerTimeObserver];
    _palyerTimeObserver = nil;
    [[NSNotificationCenter defaultCenter] removeObserver:_palyerItemDidPlayToEndTimeObserver
                                                    name:AVPlayerItemDidPlayToEndTimeNotification
                                                  object:[self avPlayerItem]];
    [[NSNotificationCenter defaultCenter] removeObserver:_palyerItemFailedPlayToEndTimeObserver
                                                    name:AVPlayerItemFailedToPlayToEndTimeNotification
                                                  object:[self avPlayerItem]];
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIApplicationWillEnterForegroundNotification
                                                  object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIApplicationDidEnterBackgroundNotification
                                                  object:nil];
    _palyerItemDidPlayToEndTimeObserver = nil;
    _palyerItemFailedPlayToEndTimeObserver = nil;
  } @catch (NSException *exception) {
    NSLog(@"SSAVPlayer: AVPlayer.removeObserver() Error.");
  }
}

- (void)applicationWillEnterForeground {
  if (self -> _isPlayingBeforeEnterBackground) {
    [self play];
  }
}

- (void)applicationDidEnterBackground {
  self -> _isPlayingBeforeEnterBackground = self.userInfo.isPlaying;
  [self pause];
}

#pragma mark - <SSPlayerUserInfoDelegate>

- (void)userinfo:(SSPlayerUserInfo *)userinfo playStateChanged:(SSPlayerPlaybackState)state {
  if (self.delegate && [self.delegate respondsToSelector:@selector(player:playStateChanged:)]) {
    [self.delegate player:self playStateChanged:self.userInfo.playState];
  }
}

- (void)userinfo:(SSPlayerUserInfo *)userinfo loadStateChanged:(SSPlayerLoadState)state {
  if (self.delegate && [self.delegate respondsToSelector:@selector(player:loadStateChanged:)]) {
    [self.delegate player:self loadStateChanged:self.userInfo.loadState];
  }
}

- (void)userinfo:(SSPlayerUserInfo *)userinfo durationUpdate:(NSTimeInterval)duration {
  if (self.delegate && [self.delegate respondsToSelector:@selector(player:updateDuration:)]) {
    [self.delegate player:self updateDuration:self.userInfo.duration];
  }
}

- (void)userinfo:(SSPlayerUserInfo *)userinfo currentDurationUpdate:(NSTimeInterval)currentDuration {
  if (self.delegate && [self.delegate respondsToSelector:@selector(player:updateCurrentDuration:)]) {
    [self.delegate player:self updateCurrentDuration:self.userInfo.currentDuration];
  }
}

- (void)userinfo:(SSPlayerUserInfo *)userinfo bufferDurationUpdate:(NSTimeInterval)bufferDuration {
  if (self.delegate && [self.delegate respondsToSelector:@selector(player:updateBufferDuration:)]) {
    [self.delegate player:self updateBufferDuration:self.userInfo.bufferDuration];
  }
}

#pragma mark - Observer Action

- (void)stalledWithPlaybackBufferEmpty {
  if (self.userInfo.isPlaying == NO) return;
  if (self.userInfo.isBuffering == YES) return;
  if (self.userInfo.isSeeking == YES) return;
  
  [self.player pause];
  DeassignPropertyValueIfNeed(self.userInfo.lastStalledTime,[[NSDate date] timeIntervalSinceNow]);
  DeassignPropertyValueIfNeed(self.userInfo.isBuffering,YES);
  
  @weakify(self);
  __block NSTimeInterval timeofloop = 0.0;
  _bufferingLoopTimer =
  [SSBufferTimer repeatingTimerWithTimeInterval:1.0
                                          block:^(SSBufferTimer * _Nonnull timer) {
                                            @strongify(self);
                                            if (self.userInfo.isPlaying == NO) {
                                              [timer invalidate];timer = nil;
                                              return;
                                            }
                                            if (self.userInfo.isBuffering == NO) {
                                              [timer invalidate];timer = nil;
                                              return;
                                            }
                                            
                                            timeofloop += 1;
                                            if (timeofloop > self.timeout) {
                                              [timer invalidate];timer = nil;
                                              DeassignPropertyValueIfNeed(self.userInfo.isBuffering,NO);
                                              self.userInfo.error = [NSError errorWithDomain:@"BufferingTimeout"
                                                                                        code:SSPlayerErrorItemBufferingTimeOut
                                                                                    userInfo:nil];
                                              [self errorCallback];
                                              return;
                                            }
                                          }];
  [_bufferingLoopTimer fire];
}

- (void)continueWithPlaybackLikelyToKeepUp {
  if (self.userInfo.isPlaying == NO) return;
  if (self.userInfo.isBuffering == NO) return;
  if (self.userInfo.isSeeking == YES) return;
  if (self.avPlayerItem.isPlaybackLikelyToKeepUp == NO) return;
  
  @weakify(self);
  dispatch_after(dispatch_time(self.userInfo.lastStalledTime, (int64_t)(3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
    @strongify(self);
    DeassignPropertyValueIfNeed(self.userInfo.isBuffering,NO);
    [self play];
  });
}

- (void)updateBufferDuration {
  CMTimeRange range = [self.avPlayerItem.loadedTimeRanges.firstObject CMTimeRangeValue];
  if (CMTIMERANGE_IS_VALID(range)) {
    NSTimeInterval start = CMTimeGetSeconds(range.start);
    NSTimeInterval duration = CMTimeGetSeconds(range.duration);
    DeassignPropertyValueIfNeed(self.userInfo.bufferDuration,start+duration);
  } else {
    DeassignPropertyValueIfNeed(self.userInfo.bufferDuration,0.0);
  }
}

#pragma mark - Callback

- (void)errorCallback {
  [self errorStop];
}

#pragma mark - Getter

- (SSAsset *)asset {
  return self.playerItem.asset;
}

- (AVPlayerItem *)avPlayerItem {
  return [self.playerItem avPlayerItem];
}

- (float)volume {
  return self.userInfo.volume;
}

- (BOOL)muted {
  return self.userInfo.isMuted;
}

- (float)rate {
  return self.userInfo.rate;
}

- (SSPlayerScalingMode)scalingMode {
  return self.userInfo.scalingMode;
}

- (NSTimeInterval)preferredBufferDurationBeforePlayback {
  if (@available(iOS 10.0, *)) {
    if (self.avPlayerItem) {
      return self.avPlayerItem.preferredForwardBufferDuration;
    }
  }
  return 0.0;
}

- (BOOL)seekEnable {
  if (self.playerPrepared == NO) {return NO;}
  if (self.avPlayerItem == nil) {return NO;
    
  }
  if (self.userInfo.duration <= 0 ||
      self.avPlayerItem.status != AVPlayerItemStatusReadyToPlay) {
    return NO;
  }
  return YES;
}

#pragma mark - Setter

- (void)setVolume:(float)volume {
  self.userInfo.volume = MIN(MAX(0, volume), 1);
  if (self.player) {
    self.player.volume = self.userInfo.volume;
  }
}

- (void)setMuted:(BOOL)muted {
  self.userInfo.isMuted = muted;
  if (self.player) {
    self.player.muted = self.userInfo.isMuted;
  }
}

- (void)setRate:(float)rate {
  if (fabsf(self.player.rate) > 0.00001f) {
    self.userInfo.rate = rate;
  }
  if (self.player) {
    self.player.rate = self.userInfo.rate;
  }
}

- (void)setScalingMode:(SSPlayerScalingMode)scalingMode {
  self.userInfo.scalingMode = scalingMode;
  switch (scalingMode) {
    case SSPlayerScalingModeNone:
      self.playerLayer.videoGravity = AVLayerVideoGravityResizeAspect;
      break;
    case SSPlayerScalingModeAspectFit:
      self.playerLayer.videoGravity = AVLayerVideoGravityResizeAspect;
      break;
    case SSPlayerScalingModeAspectFill:
      self.playerLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
      break;
    case SSPlayerScalingModeFill:
      self.playerLayer.videoGravity = AVLayerVideoGravityResize;
      break;
    default:
      break;
  }
}
@end

@implementation SSPlayerLayer

+ (Class)layerClass {
  return [AVPlayerLayer class];
}

- (AVPlayerLayer *)avLayer {
  return (AVPlayerLayer *)self.layer;
}

- (instancetype)initWithFrame:(CGRect)frame {
  self = [super initWithFrame:frame];
  if (self) {
    self.backgroundColor = [UIColor blackColor];
  }
  return self;
}

#pragma mark - Getter

- (AVLayerVideoGravity)videoGravity {
  return [self avLayer].videoGravity;
}

#pragma mark - Setter

- (void)setPlayer:(SSAVPlayer *)player {
  if (player == _player) return;
  self.avLayer.player = player.player;
}

- (void)setVideoGravity:(AVLayerVideoGravity)videoGravity {
  if (videoGravity == self.videoGravity) return;
  [self avLayer].videoGravity = videoGravity;
}
@end
