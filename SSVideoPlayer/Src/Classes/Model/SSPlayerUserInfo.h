
#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSUInteger, SSPlayerPlaybackState) {
  SSPlayerPlayStateUnknown = 0,
  SSPlayerPlayStatePlaying,
  SSPlayerPlayStatePaused,
  SSPlayerPlayStatePlayFinished,
  SSPlayerPlayStatePlayStopped,
  SSPlayerPlayStatePlayFailed
};

typedef NS_ENUM(NSUInteger, SSPlayerLoadState) {
  SSPlayerLoadStateUnknown = 0,
  SSPlayerLoadStatePrepare,
  SSPlayerLoadStatePlayable,
  SSPlayerLoadStateReadyToPlay,
  SSPlayerLoadStateStalled,
};

typedef NS_ENUM(NSInteger, SSPlayerScalingMode) {
  SSPlayerScalingModeNone,
  SSPlayerScalingModeAspectFit,
  SSPlayerScalingModeAspectFill,
  SSPlayerScalingModeFill
};

typedef NS_ENUM(NSInteger, SSPlayerErrorCode) {
  SSPlayerErrorItemFailed = 10001,
  SSPlayerErrorItemBufferingTimeOut
};

@class SSPlayerUserInfo;
@protocol SSPlayerUserInfoDelegate <NSObject>
@optional
- (void)userinfo:(SSPlayerUserInfo *)userinfo playStateChanged:(SSPlayerPlaybackState)state;
- (void)userinfo:(SSPlayerUserInfo *)userinfo loadStateChanged:(SSPlayerLoadState)state;
- (void)userinfo:(SSPlayerUserInfo *)userinfo durationUpdate:(NSTimeInterval)duration;
- (void)userinfo:(SSPlayerUserInfo *)userinfo currentDurationUpdate:(NSTimeInterval)currentDuration;
- (void)userinfo:(SSPlayerUserInfo *)userinfo bufferDurationUpdate:(NSTimeInterval)bufferDuration;
@end

@interface SSPlayerUserInfo : NSObject {
  @public
  NSError *_error;
  BOOL _isPlaying;
  BOOL _isBuffering;
  BOOL _isSeeking;
  BOOL _isObserving;
  SSPlayerPlaybackState _playState;
  SSPlayerLoadState _loadState;
  NSTimeInterval _lastStalledTime;
  NSTimeInterval _duration;
  NSTimeInterval _currentDuration;
  NSTimeInterval _bufferDuration;
  CGSize _presentationSize;
  SSPlayerScalingMode _scalingMode;
  float _volume;
  BOOL _isMuted;
  float _rate;
}

@property(nonatomic, weak) id<SSPlayerUserInfoDelegate> delegate;
@property(nonatomic, strong, readonly) NSError *error;
@property(nonatomic, assign, readonly) BOOL isPlaying;
@property(nonatomic, assign, readonly) BOOL isBuffering;
@property(nonatomic, assign, readonly) BOOL isSeeking;
@property(nonatomic, assign, readonly) BOOL isObserving;
@property(nonatomic, assign, readonly) SSPlayerPlaybackState playState;
@property(nonatomic, assign, readonly) SSPlayerLoadState loadState;
@property(nonatomic, assign, readonly) NSTimeInterval lastStalledTime;
@property(nonatomic, assign, readonly) NSTimeInterval duration;
@property(nonatomic, assign, readonly) NSTimeInterval currentDuration;
@property(nonatomic, assign, readonly) NSTimeInterval bufferDuration;
@property(nonatomic, assign, readonly) CGSize presentationSize;
@property(nonatomic, assign, readonly) SSPlayerScalingMode scalingMode;
@property(nonatomic, assign, readonly) float volume;
@property(nonatomic, assign, readonly) BOOL isMuted;
@property(nonatomic, assign, readonly) float rate;
@end

NS_ASSUME_NONNULL_END
