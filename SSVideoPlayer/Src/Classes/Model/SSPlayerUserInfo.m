
#import "SSPlayerUserInfo.h"

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

@implementation SSPlayerUserInfo

@synthesize error            = _error;
@synthesize isPlaying        = _isPlaying;
@synthesize isBuffering      = _isBuffering;
@synthesize isSeeking        = _isSeeking;
@synthesize isObserving      = _isObserving;
@synthesize playState        = _playState;
@synthesize loadState        = _loadState;
@synthesize lastStalledTime  = _lastStalledTime;
@synthesize duration         = _duration;
@synthesize currentDuration  = _currentDuration;
@synthesize bufferDuration   = _bufferDuration;
@synthesize presentationSize = _presentationSize;
@synthesize scalingMode      = _scalingMode;
@synthesize volume           = _volume;
@synthesize isMuted          = _isMuted;
@synthesize rate             = _rate;

- (instancetype)init {
  self = [super init];
  if (self) {
    _error = nil;
    _isPlaying = NO;
    _playState = SSPlayerPlayStateUnknown;
    _loadState = SSPlayerLoadStateUnknown;
    _lastStalledTime = 0.0;
    _duration = 0.0;
    _currentDuration = 0.0;
    _bufferDuration = 0.0;
    _presentationSize = CGSizeZero;
    _scalingMode = SSPlayerScalingModeAspectFit;
    _isMuted = NO;
    _rate = 1.0;
  }
  return self;
}

- (void)setPlayState:(SSPlayerPlaybackState)playState {
  _playState = playState;
  if (self.delegate && [self.delegate respondsToSelector:@selector(userinfo:playStateChanged:)]) {
    [self.delegate userinfo:self playStateChanged:playState];
  }
}

- (void)setLoadState:(SSPlayerLoadState)loadState {
  _loadState = loadState;
  if (self.delegate && [self.delegate respondsToSelector:@selector(userinfo:loadStateChanged:)]) {
    [self.delegate userinfo:self loadStateChanged:loadState];
  }
}

- (void)setDuration:(NSTimeInterval)duration {
  _duration = duration;
  if (self.delegate && [self.delegate respondsToSelector:@selector(userinfo:durationUpdate:)]) {
    [self.delegate userinfo:self durationUpdate:duration];
  }
}

- (void)setCurrentDuration:(NSTimeInterval)currentDuration {
  _currentDuration = currentDuration;
  if (self.delegate && [self.delegate respondsToSelector:@selector(userinfo:currentDurationUpdate:)]) {
    [self.delegate userinfo:self currentDurationUpdate:currentDuration];
  }
}

- (void)setBufferDuration:(NSTimeInterval)bufferDuration {
  _bufferDuration = bufferDuration;
  if (self.delegate && [self.delegate respondsToSelector:@selector(userinfo:bufferDurationUpdate:)]) {
    [self.delegate userinfo:self bufferDurationUpdate:bufferDuration];
  }
}
@end
