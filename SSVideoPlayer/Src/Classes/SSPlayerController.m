
#import "SSPlayerController.h"
#import "SSUpvoter.h"
#import "DSShareManager.h"
#import "SSStatistics.h"

@interface SSPlayerController ()
<SSPlayerDelegate,
SSPlayerSliderViewDelegate,
SSPlayerControlViewDelegate>

@property(nonatomic, strong) SSPlayer *player;
@property(nonatomic, strong) UIView *view;
@property(nonatomic, strong) SSPlayerControlView *controlView;
@end

@implementation SSPlayerController

- (void)dealloc {
  NSLog(@"SSPlayerController.dealloc()");
}

- (instancetype)init {
  self = [super init];
  if (self) {
    [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayback error:nil];
    [[AVAudioSession sharedInstance] setActive:YES error:nil];
    _scalingMode = SSPlayerScalingModeAspectFit;
    _muted = NO;
    _rate = 1.0;
    
    self.view = [[UIView alloc] initWithFrame:CGRectZero];
    self.view.backgroundColor = [UIColor clearColor];
    self.view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    self.controlView = [[SSPlayerControlView alloc] init];
    self.controlView.bottomBarShadowImage = UIImageMake(UIImagePhotoVideoBottomShadow);
    self.controlView.playButtonPauseStateImage = UIImageMake(UIImageVideoPlayerPlay);
    self.controlView.playButtonPlayingStateImage = UIImageMake(UIImageVideoPlayerPause);
    self.controlView.enterFullScreenButtonImage = UIImageMake(UIImageVideoPlayerHorizontalScreen);
    self.controlView.leaveFullScreenButtonImage = UIImageMake(UIImageVideoPlayerVerticalScreen);
    self.controlView.topBarShadowImage = UIImageMake(UIImagePhotoVideoTopShadow);
    self.controlView.backButtonImage = UIImageMake(UIImageDefaultNavBackArrow);
    self.controlView.likeButtonUnLikedStateImage = UIImageMake(UIImageResourceLikeNormall);
    self.controlView.likeButtonLikedStateImage = UIImageMake(UIImageResourceLikeHightlight);
    self.controlView.shareButtonImage = UIImageMake(UIImageContentsShare);
    self.controlView.delegate = self;
    
    [self.view addSubview:self.controlView];
    self.controlView.sliderView.delegate = self;
  }
  return self;
}

- (instancetype)initWithRichMedia:(RichElement *)richMedia {
  self = [self init];
  if (self) {
    self.richMedia = richMedia;
  }
  return self;
}

- (void)play {
  if (!self.player) return;
  [[SSStatistics shareInstance] visitVideoWithObjectId:self.richMedia.objectId];
  if (self.player.userInfo.playState == SSPlayerPlayStatePlayFinished ||
      self.player.userInfo.playState == SSPlayerPlayStatePlayStopped  ||
      self.player.userInfo.playState == SSPlayerPlayStatePlayFailed) {
    [self.player reloadPlayer];
  } else {
    [self.player play];
  }
}

- (void)pause {
  if (!self.player) return;
  [self.player pause];
}

- (void)stop {
  if (!self.player) return;
  [self.player stop];
  [self resetPlayerControlView];
}

- (void)seekToTime:(NSTimeInterval)time {
  if (!self.player) return;
  [self.player seekToTime:time];
}

- (void)seekToTime:(NSTimeInterval)time completionHandler:(void (^ __nullable)(BOOL finished))completionHandler {
  if (!self.player) return;
  [self.player seekToTime:time completionHandler:completionHandler];
}

#pragma mark -Private

- (void)resetPlayerControlView {
  [self.controlView setSliderValue:0];
  [self.controlView setSliderBufferValue:0];
  [self.controlView setCurrentTime:0];
  [self.controlView setDuration:0];
  [self.controlView setPlayState:SSPlayerPlayStateUnknown];
}

#pragma mark - SSPlayerDelegate

- (void)player:(SSAVPlayer *)player playStateChanged:(SSPlayerPlaybackState)state {
  if (state == SSPlayerPlayStatePlayFinished) {
    @weakify(self);
    [self seekToTime:0 completionHandler:^(BOOL finished) {
     @strongify(self);
     [self pause];
   }];
  } else if (state == SSPlayerPlayStatePlayFailed) {
    if (self.delegate && [self.delegate respondsToSelector:@selector(playerController:receiveError:)]) {
      [self.delegate playerController:self receiveError:self.player.userInfo.error];
    }
  }
  self.controlView.playState = state;
}

- (void)player:(SSAVPlayer *)player loadStateChanged:(SSPlayerLoadState)state {
  self.controlView.loadState = state;
}

- (void)player:(SSAVPlayer *)player updateDuration:(NSTimeInterval)duration {
  [self.controlView setDuration:player.userInfo.duration];
}

- (void)player:(SSAVPlayer *)player updateCurrentDuration:(NSTimeInterval)duration {
  [self.controlView setCurrentTime:player.userInfo.currentDuration];
  if (self.controlView.sliderView.isdragging == NO) {
    if (player.userInfo.duration > 0) {
      [self.controlView setSliderValue:duration/player.userInfo.duration];
    }
  }
}

- (void)player:(SSAVPlayer *)player updateBufferDuration:(NSTimeInterval)duration {
  if (player.userInfo.duration > 0) {
    [self.controlView setSliderBufferValue:duration/player.userInfo.duration];
  }
}

#pragma mark - <SSPlayerSliderViewDelegate>

- (void)sliderTouchBegan:(float)value {
  self.controlView.sliderView.isdragging = YES;
}

- (void)sliderValueChanged:(float)value {
  self.controlView.sliderView.isdragging = YES;
  if (self.player && self.player.userInfo.duration <= 0) {
    [self resetPlayerControlView];
    return;
  }
  [self.controlView setCurrentTime:self.player.userInfo.duration * value];
}

- (void)sliderTouchEnded:(float)value {
  self.controlView.sliderView.isdragging = YES;
  if (self.player && self.player.userInfo.duration > 0) {
    @weakify(self);
    [self.player seekToTime:self.player.userInfo.duration*value
          completionHandler:^(BOOL finished) {
            @strongify(self);
            self.controlView.sliderView.isdragging = NO;
            [self.controlView autoHidenToolBar];
          }];
  } else {
    self.controlView.sliderView.isdragging = NO;
    [self.controlView autoHidenToolBar];
  }
}

- (void)sliderTapped:(float)value {
  self.controlView.sliderView.isdragging = YES;
  if (self.player && self.player.userInfo.duration > 0) {
    @weakify(self);
    [self.player seekToTime:self.player.userInfo.duration*value
          completionHandler:^(BOOL finished) {
            @strongify(self);
            self.controlView.sliderView.isdragging = NO;
            [self.controlView autoHidenToolBar];
          }];
  } else {
    self.controlView.sliderView.isdragging = NO;
    [self.controlView autoHidenToolBar];
  }
}

#pragma mark - <SSPlayerControlViewDelegate>

- (void)playerControlView:(SSPlayerControlView *)view playButtonDidSelected:(UIButton *)button isPlaying:(BOOL)isPlaying {
  if (isPlaying) {
    [self pause];
  } else {
    [self play];
  }
}

- (void)playerControlView:(SSPlayerControlView *)view fullScreenButtonDidSelected:(UIButton *)button isFullScreen:(BOOL)isFullScreen animated:(BOOL)animated {
  [self setFullscreen:!isFullScreen animated:animated];
}

- (void)playerControlView:(SSPlayerControlView *)view backButtonDidSelected:(UIButton *)button isFullScreen:(BOOL)isFullScreen {
  [self stop];
  if (self.delegate && [self.delegate respondsToSelector:@selector(playerControllerDidStop:)]) {
    [self.delegate playerControllerDidStop:self];
  }
}

- (void)playerControlView:(SSPlayerControlView *)view likeButtonDidSelected:(UIButton *)button {
  if (self.richMedia && self.richMedia.objectId.isNotBlank) {
    view.isLike = !view.isLike;
    self.richMedia.isUpvote = view.isLike;
  } else {
    return;
  }
  @weakify(self);
  if (view.isLike) {
    view.likeCount += 1;
    self.richMedia.upvoteNum = view.likeCount;
    [[SSUpvoter shareInstance] upvoteResourceVideoWithObjectId:self.richMedia.objectId
                                                    completion:^(BOOL success, NSError *error) {
                                                      @strongify(self);
                                                      if (success) {
                                                        if (self.delegate && [self.delegate respondsToSelector:@selector(playerController:likeStateChanged:objectId:)]) {
                                                          [self.delegate playerController:self likeStateChanged:YES objectId:self.richMedia.objectId];
                                                        }
                                                      } else {
                                                        view.isLike = NO;
                                                        view.likeCount -= 1;
                                                        self.richMedia.isUpvote = view.isLike;
                                                        self.richMedia.upvoteNum = view.likeCount;
                                                        if (self.delegate && [self.delegate respondsToSelector:@selector(playerController:likeRequestError:originalState:objectId:)]) {
                                                          [self.delegate playerController:self likeRequestError:error originalState:NO objectId:self.richMedia.objectId];
                                                        }
                                                      }
                                                    }];
  } else {
    view.likeCount -= 1;
    self.richMedia.upvoteNum = view.likeCount;
    [[SSUpvoter shareInstance] cancleUpvoteResourceVideoWithObjectId:self.richMedia.objectId
                                                          completion:^(BOOL success, NSError *error) {
                                                            @strongify(self);
                                                            if (success) {
                                                              if (self.delegate && [self.delegate respondsToSelector:@selector(playerController:likeStateChanged:objectId:)]) {
                                                                [self.delegate playerController:self likeStateChanged:NO objectId:self.richMedia.objectId];
                                                              }
                                                            } else {
                                                              view.isLike = YES;
                                                              view.likeCount += 1;
                                                              self.richMedia.isUpvote = view.isLike;
                                                              self.richMedia.upvoteNum = view.likeCount;
                                                              if (self.delegate && [self.delegate respondsToSelector:@selector(playerController:likeRequestError:originalState:objectId:)]) {
                                                                [self.delegate playerController:self likeRequestError:error originalState:YES objectId:self.richMedia.objectId];
                                                              }
                                                            }
                                                          }];
  }
}

- (void)playerControlView:(SSPlayerControlView *)view shareButtonDidSelected:(UIButton *)button {
  [DSShareManager showShareControlWithScene:ShareSceneResourceVideo
                                 shareInfos:nil
                                      title:nil
                                     source:nil];
}

- (void)playerControlView:(SSPlayerControlView *)view singleTapGesture:(UITapGestureRecognizer *)tap isHidenToolBar:(BOOL)isHidenToolBar {
  if (isHidenToolBar) {
    [self.controlView showToolBarIfNeedWithAnimated:YES];
  } else {
    [self.controlView hideToolBarIfNeedWithAnimated:YES];
  }
}

- (void)playerControlView:(SSPlayerControlView *)view doubleTapGesture:(UITapGestureRecognizer *)tap isPlaying:(BOOL)isPlaying {
  if (isPlaying) {
    [self pause];
  } else {
    [self play];
  }
}

#pragma mark - Setter

- (void)setRichMedia:(RichElement *)richMedia {
  _richMedia = richMedia;
  if (self.player) {
    [self.player setDelegate:nil];
    [self.player stop];
    [self.player.view removeFromSuperview];
    [self setPlayer:nil];
    [self resetPlayerControlView];
  }
  if (self.richMedia && self.richMedia.video) {
    NSURL *contentURL = [NSURL URLWithString:self.richMedia.video.mediaUrl];
    self.player = [[SSPlayer alloc] initWithURL:contentURL];
    self.player.delegate = self;
    self.player.scalingMode = self.scalingMode;
    self.player.muted = self.muted;
    self.player.rate = self.rate;
    [self.view insertSubview:self.player.view atIndex:0];
    [self.player.view setFrame:self.view.bounds];
    [self resetPlayerControlView];
    NSString *source = self.richMedia.source;
    if (source.isNotBlank) source = [NSString stringWithFormat:@"摄影来自:%@",source];
    if (source.isNotBlank) self.controlView.title = source;
    self.controlView.isLike = self.richMedia.isUpvote;
    self.controlView.likeCount = self.richMedia.upvoteNum;
    if (self.shouldAutoplay) [self play];
    IMGElement *coverImage = self.richMedia.video.coverImage;
    if (coverImage && coverImage.mediumImage && coverImage.mediumImage.imageUrl.isNotBlank) {
      ///< [self.controlView.placeholderView remoteImageWithURL:coverImage.mediumImage.imageUrl];
    }
  } else {
    NSError *error = [NSError errorWithDomain:@"SSPlayerController"
                                         code:0
                                     userInfo:@{NSLocalizedDescriptionKey:@"Cannot Find Video"}];
    if (self.delegate && [self.delegate respondsToSelector:@selector(playerController:receiveError:)]) {
      [self.delegate playerController:self receiveError:error];
    }
  }
}

- (void)setScalingMode:(SSPlayerScalingMode)scalingMode {
  _scalingMode = scalingMode;
  if (self.player) {
    self.player.scalingMode = scalingMode;
  }
}

- (void)setMuted:(BOOL)muted {
  _muted = muted;
  if (self.player) {
    self.player.muted = muted;
  }
}

- (void)setRate:(float)rate {
  _rate = rate;
  if (self.player) {
    self.player.rate = rate;
  }
}

- (void)setFullScreen:(BOOL)fullScreen {
  [self setFullscreen:fullScreen animated:NO];
}

- (void)setFullscreen:(BOOL)fullscreen animated:(BOOL)animated {
  _fullScreen = fullscreen;
  [self reloadInterfaceOrientation];
}

- (void)setShouldAutoplay:(BOOL)shouldAutoplay {
  _shouldAutoplay = shouldAutoplay;
  if (shouldAutoplay) [self play];
}

#pragma mark - Getter

- (SSPlayerPlaybackState)state {
  if (self.player) {
    return self.player.userInfo.playState;
  } else {
    return SSPlayerPlayStateUnknown;
  }
}

#pragma mark - FullScreen

- (void)reloadInterfaceOrientation {
  self.controlView.isFullScreen = self.isFullScreen;
  if (self.delegate && [self.delegate respondsToSelector:@selector(playerController:fullScreenChanged:)]) {
    [self.delegate playerController:self fullScreenChanged:self.isFullScreen];
  }
}
@end
