
#import "SSPlayerControlView.h"

@interface SSPlayerControlView ()

@property(nonatomic, strong) UIView<SSPlayerActivityIndicatorViewProtocol> *indicatorView;
@property(nonatomic, strong) UIView *bottomToolBar;
@property(nonatomic, strong) UIImageView *bottomToolBarBackgroundView;
@property(nonatomic, strong) UIButton *playButton;
@property(nonatomic, strong) UILabel *timeLable;
@property(nonatomic, strong) SSPlayerSliderView *sliderView;
@property(nonatomic, strong) UILabel *durationLable;
@property(nonatomic, strong) UIButton *fullScreenButton;
@property(nonatomic, strong) UIView *topToolBar;
@property(nonatomic, strong) UIImageView *topToolBarBackgroundView;
@property(nonatomic, strong) UIButton *backButton;
@property(nonatomic, strong) UILabel *titleLable;
@property(nonatomic, strong) UIButton *likeButton;
@property(nonatomic, strong) UILabel *likeCountLable;
@property(nonatomic, strong) UIButton *shareButton;
@property(nonatomic, strong) UIView *gestureContentView;
@property(nonatomic, assign) BOOL isPlaying;
@property(nonatomic, assign) BOOL isFullScreen;
@property(nonatomic, assign) BOOL isHidenToolBar;
@property(nonatomic, assign) BOOL isToolBarButtonActive;
@property(nonatomic, assign) BOOL toolBarAnimationLock;
@property(nonatomic, strong) dispatch_block_t toolBarHidenBlock;
@end

@implementation SSPlayerControlView

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
  if (self = [super initWithCoder:aDecoder]) {
    [self didInitialized];
  }
  return self;
}

- (instancetype)initWithFrame:(CGRect)frame {
  self = [super initWithFrame:frame];
  if (self) {
    [self didInitialized];
  }
  return self;
}

- (void)didInitialized {
  self.isPlaying = NO;
  self.isFullScreen = NO;
  self.isHidenToolBar = NO;
  self.toolBarAnimationLock = NO;
  self.backgroundColor = [UIColor clearColor];
  self.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
}

- (void)layoutSubviews {
  [super layoutSubviews];
  [self placeSubviews];
}

- (void)willMoveToSuperview:(UIView *)newSuperview {
  [super willMoveToSuperview:newSuperview];
  [self.subviews enumerateObjectsUsingBlock:^(__kindof UIView * _Nonnull obj,
                                              NSUInteger idx,
                                              BOOL * _Nonnull stop) {
    [obj removeFromSuperview];
  }];
  [self.layer.sublayers enumerateObjectsUsingBlock:^(__kindof CALayer * _Nonnull obj,
                                                     NSUInteger idx,
                                                     BOOL * _Nonnull stop) {
    [obj removeAllAnimations];
    [obj removeFromSuperlayer];
  }];
  [self initSubviews];
}

- (void)initSubviews {
  self.indicatorView = [[SSPlayerActivityIndicatorView alloc] initWithFrame:CGRectZero];
  [self addSubview:self.indicatorView];
  
  self.bottomToolBar = [[UIView alloc] initWithFrame:CGRectZero];
  self.bottomToolBar.backgroundColor = [UIColor clearColor];
  
  self.bottomToolBarBackgroundView = [[UIImageView alloc] initWithFrame:CGRectZero];
  self.bottomToolBarBackgroundView.backgroundColor = [UIColor clearColor];
  self.bottomToolBarBackgroundView.image = self.bottomBarShadowImage;
  
  self.playButton = [[UIButton alloc] initWithFrame:CGRectZero];
  self.playButton.backgroundColor = [UIColor clearColor];
  self.playButton.outsideEdge = UIEdgeInsetsMake(-10, -10, -10, -10);
  [self.playButton setImage:self.playButtonPauseStateImage forState:UIControlStateNormal];
  
  self.timeLable = [[UILabel alloc] initWithFrame:CGRectZero];
  self.timeLable.backgroundColor = [UIColor clearColor];
  self.timeLable.font = [UIFont systemFontOfSize:12];
  self.timeLable.textColor = [UIColor whiteColor];
  self.timeLable.textAlignment = NSTextAlignmentRight;
  self.timeLable.text = @"00:00";
  
  self.sliderView = [[SSPlayerSliderView alloc] initWithFrame:CGRectZero];
  self.sliderView.backgroundColor = [UIColor clearColor];
  self.sliderView.sliderHeight = 3;
  self.sliderView.maximumTrackTintColor = [UIColorWhite colorWithAlphaComponent:0.4];
  self.sliderView.minimumTrackTintColor = [UIColor colorFromHexString:@"FF2BA3"];
  self.sliderView.bufferTrackTintColor = [UIColor colorFromHexString:@"BBBBBB"];
  
  self.durationLable = [[UILabel alloc] initWithFrame:CGRectZero];
  self.durationLable.backgroundColor = [UIColor clearColor];
  self.durationLable.font = [UIFont systemFontOfSize:12];
  self.durationLable.textColor = [UIColor whiteColor];
  self.durationLable.textAlignment = NSTextAlignmentLeft;
  self.durationLable.text = @"00:00";
  
  self.fullScreenButton = [[UIButton alloc] initWithFrame:CGRectZero];
  self.fullScreenButton.backgroundColor = [UIColor clearColor];
  self.fullScreenButton.outsideEdge = UIEdgeInsetsMake(-10, -10, -10, -10);
  [self.fullScreenButton setImage:self.enterFullScreenButtonImage forState:UIControlStateNormal];
  
  self.topToolBar = [[UIView alloc] initWithFrame:CGRectZero];
  self.topToolBar.backgroundColor = [UIColor clearColor];
  
  self.topToolBarBackgroundView = [[UIImageView alloc] initWithFrame:CGRectZero];
  self.topToolBarBackgroundView.backgroundColor = [UIColor clearColor];
  self.topToolBarBackgroundView.image = self.topBarShadowImage;
  
  self.backButton = [[UIButton alloc] initWithFrame:CGRectZero];
  self.backButton.backgroundColor = [UIColor clearColor];
  self.backButton.outsideEdge = UIEdgeInsetsMake(-10, -10, -10, -10);
  [self.backButton setImage:UIImageMake(UIImageDefaultNavBackArrow) forState:UIControlStateNormal];
  
  self.titleLable = [[UILabel alloc] initWithFrame:CGRectZero];
  self.titleLable.backgroundColor = [UIColor clearColor];
  self.titleLable.font = [UIFont systemFontOfSize:14];
  self.titleLable.textColor = [UIColor whiteColor];
  self.titleLable.textAlignment = NSTextAlignmentLeft;
  self.titleLable.text = @"";
  
  self.likeButton = [[UIButton alloc] initWithFrame:CGRectZero];
  self.likeButton.backgroundColor = [UIColor clearColor];
  self.likeButton.outsideEdge = UIEdgeInsetsMake(-10, -10, -10, -10);
  [self.likeButton setImage:self.likeButtonUnLikedStateImage forState:UIControlStateNormal];
  
  self.likeCountLable = [[UILabel alloc] initWithFrame:CGRectZero];
  self.likeCountLable.backgroundColor = [UIColor clearColor];
  self.likeCountLable.font = [UIFont systemFontOfSize:14];
  self.likeCountLable.textColor = [UIColor whiteColor];
  self.likeCountLable.textAlignment = NSTextAlignmentLeft;
  self.likeCountLable.text = @"";
  
  self.shareButton = [[UIButton alloc] initWithFrame:CGRectZero];
  self.shareButton.backgroundColor = [UIColor clearColor];
  self.shareButton.outsideEdge = UIEdgeInsetsMake(-10, -10, -10, -10);
  [self.shareButton setImage:self.shareButtonImage forState:UIControlStateNormal];
  
  self.gestureContentView = [[UIView alloc] initWithFrame:CGRectZero];
  self.gestureContentView.backgroundColor = [UIColor clearColor];
  
  [self.bottomToolBar addSubview:self.bottomToolBarBackgroundView];
  [self.bottomToolBar addSubview:self.playButton];
  [self.bottomToolBar addSubview:self.timeLable];
  [self.bottomToolBar addSubview:self.sliderView];
  [self.bottomToolBar addSubview:self.durationLable];
  [self.bottomToolBar addSubview:self.fullScreenButton];
  
  [self.topToolBar addSubview:self.topToolBarBackgroundView];
  [self.topToolBar addSubview:self.backButton];
  [self.topToolBar addSubview:self.titleLable];
  [self.topToolBar addSubview:self.likeButton];
  [self.topToolBar addSubview:self.likeCountLable];
  [self.topToolBar addSubview:self.shareButton];
  
  [self addSubview:self.topToolBar];
  [self addSubview:self.bottomToolBar];
  [self addSubview:self.gestureContentView];
  
  [self.playButton addTarget:self
                      action:@selector(playButtonDidSelected:)
            forControlEvents:UIControlEventTouchUpInside];
  [self.playButton addTarget:self
                      action:@selector(toolbarButtonTouchDown:)
            forControlEvents:UIControlEventTouchDown];
  [self.playButton addTarget:self
                      action:@selector(toolbarButtonTouchUpOutside:)
            forControlEvents:UIControlEventTouchUpOutside];
  [self.playButton addTarget:self
                      action:@selector(toolbarButtonTouchCancel:)
            forControlEvents:UIControlEventTouchCancel];
  [self.fullScreenButton addTarget:self
                            action:@selector(fullScreenButtonDidSelected:)
                  forControlEvents:UIControlEventTouchUpInside];
  [self.fullScreenButton addTarget:self
                            action:@selector(toolbarButtonTouchDown:)
                  forControlEvents:UIControlEventTouchDown];
  [self.fullScreenButton addTarget:self
                            action:@selector(toolbarButtonTouchUpOutside:)
                  forControlEvents:UIControlEventTouchUpOutside];
  [self.fullScreenButton addTarget:self
                            action:@selector(toolbarButtonTouchCancel:)
                  forControlEvents:UIControlEventTouchCancel];
  [self.backButton addTarget:self
                      action:@selector(backButtonDidSelected:)
            forControlEvents:UIControlEventTouchUpInside];
  [self.backButton addTarget:self
                      action:@selector(toolbarButtonTouchDown:)
            forControlEvents:UIControlEventTouchDown];
  [self.backButton addTarget:self
                      action:@selector(toolbarButtonTouchUpOutside:)
            forControlEvents:UIControlEventTouchUpOutside];
  [self.backButton addTarget:self
                      action:@selector(toolbarButtonTouchCancel:)
            forControlEvents:UIControlEventTouchCancel];
  [self.likeButton addTarget:self
                      action:@selector(likeButtonDidSelected:)
            forControlEvents:UIControlEventTouchUpInside];
  [self.likeButton addTarget:self
                      action:@selector(toolbarButtonTouchDown:)
            forControlEvents:UIControlEventTouchDown];
  [self.likeButton addTarget:self
                      action:@selector(toolbarButtonTouchUpOutside:)
            forControlEvents:UIControlEventTouchUpOutside];
  [self.likeButton addTarget:self
                      action:@selector(toolbarButtonTouchCancel:)
            forControlEvents:UIControlEventTouchCancel];
  [self.shareButton addTarget:self
                       action:@selector(shareButtonDidSelected:)
             forControlEvents:UIControlEventTouchUpInside];
  [self.shareButton addTarget:self
                       action:@selector(toolbarButtonTouchDown:)
             forControlEvents:UIControlEventTouchDown];
  [self.shareButton addTarget:self
                       action:@selector(toolbarButtonTouchUpOutside:)
             forControlEvents:UIControlEventTouchUpOutside];
  [self.shareButton addTarget:self
                       action:@selector(toolbarButtonTouchCancel:)
             forControlEvents:UIControlEventTouchCancel];
  
  @weakify(self)
  UITapGestureRecognizer *singleTapGesture = [[UITapGestureRecognizer alloc] initWithActionBlock:^(id  _Nonnull sender) {
    @strongify(self)
    if (self.delegate && [self.delegate respondsToSelector:@selector(playerControlView:singleTapGesture:isHidenToolBar:)]) {
      [self.delegate playerControlView:self singleTapGesture:sender isHidenToolBar:self.isHidenToolBar];
    }
  }];
  singleTapGesture.numberOfTapsRequired = 1;
  singleTapGesture.numberOfTouchesRequired  = 1;
  [self.gestureContentView addGestureRecognizer:singleTapGesture];
  
  UITapGestureRecognizer *doubleTapGesture = [[UITapGestureRecognizer alloc] initWithActionBlock:^(id  _Nonnull sender) {
    @strongify(self)
    if (self.delegate && [self.delegate respondsToSelector:@selector(playerControlView:doubleTapGesture:isPlaying:)]) {
      [self.delegate playerControlView:self doubleTapGesture:sender isPlaying:self.isPlaying];
    }
  }];
  doubleTapGesture.numberOfTapsRequired = 2;
  doubleTapGesture.numberOfTouchesRequired  = 1;
  [self.gestureContentView addGestureRecognizer:doubleTapGesture];
  [singleTapGesture requireGestureRecognizerToFail:doubleTapGesture];
  
  [self autoHidenToolBar];
}

- (void)placeSubviews {
  if (self.isFullScreen) {
    self.indicatorView.size = CGSizeMake(40, 40);
    self.indicatorView.center = self.center;
    self.bottomToolBar.width = self.width;
    self.bottomToolBar.height = 75;
    self.bottomToolBar.left = 0;
    if (self.isHidenToolBar) {
      self.bottomToolBar.top = self.height;
    } else {
      self.bottomToolBar.bottom = self.height;
    }
    self.bottomToolBarBackgroundView.frame = self.bottomToolBar.bounds;
    self.playButton.size = CGSizeMake(25, 25);
    self.playButton.left = 15;
    self.playButton.bottom = self.bottomToolBar.height - 20;
    self.timeLable.left = self.playButton.right + 10;
    self.timeLable.size = CGSizeMake(45, self.playButton.height);
    self.timeLable.centerY = self.playButton.centerY;
    self.sliderView.left = self.timeLable.right + 10;
    self.sliderView.width = self.width - self.sliderView.left * 2.0;
    self.sliderView.height = 45;
    self.sliderView.centerY = self.playButton.centerY;
    self.durationLable.left = self.sliderView.right + 10;
    self.durationLable.size = CGSizeMake(45, self.playButton.height);
    self.durationLable.centerY = self.playButton.centerY;
    self.fullScreenButton.size = CGSizeMake(25, 25);
    self.fullScreenButton.right = self.width - 15;
    self.fullScreenButton.centerY = self.playButton.centerY;
    self.topToolBar.width = self.width;
    self.topToolBar.height = 75;
    self.topToolBar.left = 0;
    self.topToolBar.top = 0;
    if (self.isHidenToolBar) {
      self.topToolBar.bottom = 0;
    } else {
      self.topToolBar.top = 0;
    }
    self.topToolBarBackgroundView.frame = self.topToolBar.bounds;
    self.backButton.left = 15;
    self.backButton.size = CGSizeMake(25, 25);
    self.backButton.top = 20;
    self.shareButton.size = CGSizeMake(25, 25);
    self.shareButton.right = self.width - 15;
    self.shareButton.centerY = self.backButton.centerY;
    [self.likeCountLable sizeToFit];
    self.likeCountLable.size = CGSizeMake(self.likeCountLable.width, self.shareButton.height);
    self.likeCountLable.right = self.shareButton.left - 30;
    self.likeCountLable.centerY = self.backButton.centerY;
    self.likeButton.size = CGSizeMake(25, 25);
    self.likeButton.right = self.likeCountLable.left - 4;
    self.likeButton.centerY = self.backButton.centerY;
    self.titleLable.width = self.likeButton.left - self.backButton.right - 20;
    self.titleLable.height = self.shareButton.height;
    self.titleLable.centerY = self.backButton.centerY;
    self.titleLable.left = self.backButton.right + 10;
    if (self.isHidenToolBar) {
      self.gestureContentView.width = self.width;
      self.gestureContentView.left = 0;
      self.gestureContentView.top = 0;
      self.gestureContentView.height = self.height;
    } else {
      self.gestureContentView.width = self.width;
      self.gestureContentView.left = 0;
      self.gestureContentView.top = self.topToolBar.height;
      self.gestureContentView.height = self.height - self.topToolBar.height - self.bottomToolBar.height;
    }
  } else {
    self.indicatorView.size = CGSizeMake(40, 40);
    self.indicatorView.center = self.center;
    self.bottomToolBar.width = self.width;
    self.bottomToolBar.height = IS_58INCH_SCREEN ? 109 : 75;
    self.bottomToolBar.left = 0;
    if (self.isHidenToolBar) {
      self.bottomToolBar.top = self.height;
    } else {
      self.bottomToolBar.bottom = self.height;
    }
    self.bottomToolBarBackgroundView.frame = self.bottomToolBar.bounds;
    self.playButton.size = CGSizeMake(25, 25);
    self.playButton.left = 15;
    self.playButton.bottom = self.bottomToolBar.height - (IS_58INCH_SCREEN ? 54 : 20);
    self.timeLable.left = self.playButton.right + 10;
    self.timeLable.size = CGSizeMake(45, self.playButton.height);
    self.timeLable.centerY = self.playButton.centerY;
    self.sliderView.left = self.timeLable.right + 10;
    self.sliderView.width = self.width - self.sliderView.left * 2.0;
    self.sliderView.height = 45;
    self.sliderView.centerY = self.playButton.centerY;
    self.durationLable.left = self.sliderView.right + 10;
    self.durationLable.size = CGSizeMake(45, self.playButton.height);
    self.durationLable.centerY = self.playButton.centerY;
    self.fullScreenButton.size = CGSizeMake(25, 25);
    self.fullScreenButton.right = self.width - 15;
    self.fullScreenButton.centerY = self.playButton.centerY;
    self.topToolBar.width = self.width;
    self.topToolBar.height = IS_58INCH_SCREEN ? 99 : 75;
    self.topToolBar.left = 0;
    if (self.isHidenToolBar) {
      self.topToolBar.bottom = 0;
    } else {
      self.topToolBar.top = 0;
    }
    self.topToolBarBackgroundView.frame = self.topToolBar.bounds;
    self.backButton.left = 15;
    self.backButton.size = CGSizeMake(25, 25);
    self.backButton.top = IS_58INCH_SCREEN ? 44 : 20;
    self.shareButton.size = CGSizeMake(25, 25);
    self.shareButton.right = self.width - 15;
    self.shareButton.centerY = self.backButton.centerY;
    [self.likeCountLable sizeToFit];
    self.likeCountLable.size = CGSizeMake(self.likeCountLable.width, self.shareButton.height);
    self.likeCountLable.right = self.shareButton.left - 30;
    self.likeCountLable.centerY = self.backButton.centerY;
    self.likeButton.size = CGSizeMake(25, 25);
    self.likeButton.right = self.likeCountLable.left - 4;
    self.likeButton.centerY = self.backButton.centerY;
    self.titleLable.width = self.likeButton.left - self.backButton.right - 20;
    self.titleLable.height = self.shareButton.height;
    self.titleLable.centerY = self.backButton.centerY;
    self.titleLable.left = self.backButton.right + 10;
    if (self.isHidenToolBar) {
      self.gestureContentView.width = self.width;
      self.gestureContentView.left = 0;
      self.gestureContentView.top = 0;
      self.gestureContentView.height = self.height;
    } else {
      self.gestureContentView.width = self.width;
      self.gestureContentView.left = 0;
      self.gestureContentView.top = self.topToolBar.height;
      self.gestureContentView.height = self.height - self.topToolBar.height - self.bottomToolBar.height;
    }
  }
}

#pragma mark -

- (void)resetControlValue {
  self.currentTime = 0;
  self.duration = 0;
  self.sliderValue = 0;
  self.sliderBufferValue = 0;
}

#pragma mark - Loading

- (void)starLoading {
  if ([self.indicatorView isLoading]) {
    return;
  } else {
    @weakify(self);
    [self.indicatorView startLoading];
    [UIView animateWithDuration:.25
                     animations:^{
                       @strongify(self);
                       [self setBackgroundColor:[UIColor colorWithWhite:0 alpha:0.1]];
                     }];
  }
}

- (void)endLoading {
  if ([self.indicatorView isLoading]) {
    @weakify(self);
    [self.indicatorView stopLoading];
    [UIView animateWithDuration:.25
                     animations:^{
                       @strongify(self);
                       [self setBackgroundColor:[UIColor colorWithWhite:0 alpha:0.0]];
                     }];
  }
}

#pragma mark - <Button Action>

- (void)playButtonDidSelected:(UIButton *)sender {
  self.isToolBarButtonActive = NO;
  if (self.delegate && [self.delegate respondsToSelector:@selector(playerControlView:playButtonDidSelected:isPlaying:)]) {
    [self.delegate playerControlView:self playButtonDidSelected:sender isPlaying:self.isPlaying];
  }
}

- (void)fullScreenButtonDidSelected:(UIButton *)sender {
  self.isToolBarButtonActive = NO;
  if (self.delegate && [self.delegate respondsToSelector:@selector(playerControlView:fullScreenButtonDidSelected:isFullScreen:animated:)]) {
    [self.delegate playerControlView:self fullScreenButtonDidSelected:sender isFullScreen:self.isFullScreen animated:YES];
  }
}

- (void)backButtonDidSelected:(UIButton *)sender {
  self.isToolBarButtonActive = NO;
  if (self.delegate && [self.delegate respondsToSelector:@selector(playerControlView:backButtonDidSelected:isFullScreen:)]) {
    [self.delegate playerControlView:self backButtonDidSelected:sender isFullScreen:self.isFullScreen];
  }
}

- (void)likeButtonDidSelected:(UIButton *)sender {
  self.isToolBarButtonActive = NO;
  if (self.delegate && [self.delegate respondsToSelector:@selector(playerControlView:likeButtonDidSelected:)]) {
    [self.delegate playerControlView:self likeButtonDidSelected:sender];
  }
}

- (void)shareButtonDidSelected:(UIButton *)sender {
  self.isToolBarButtonActive = NO;
  if (self.delegate && [self.delegate respondsToSelector:@selector(playerControlView:shareButtonDidSelected:)]) {
    [self.delegate playerControlView:self shareButtonDidSelected:sender];
  }
}

- (void)toolbarButtonTouchDown:(UIButton *)sender {
  self.isToolBarButtonActive = YES;
}

- (void)toolbarButtonTouchUpOutside:(UIButton *)sender {
  self.isToolBarButtonActive = NO;
}

- (void)toolbarButtonTouchCancel:(UIButton *)sender {
  self.isToolBarButtonActive = NO;
}

#pragma mark - Setter

- (void)setPlayState:(SSPlayerPlaybackState)playState {
  _playState = playState;
  if (playState == SSPlayerPlayStateUnknown) {
    [self endLoading];
    [self resetControlValue];
    self.isPlaying = NO;
  } else if (playState == SSPlayerPlayStatePlaying) {
    self.isPlaying = YES;
    if (self.loadState == SSPlayerLoadStateStalled ||
        self.loadState == SSPlayerLoadStatePrepare) {
      [self starLoading];
    }
  } else if (playState == SSPlayerPlayStatePaused) {
    [self endLoading];
    self.isPlaying = NO;
  } else if (playState == SSPlayerPlayStatePlayFinished) {
    [self endLoading];
    [self showToolBarIfNeedWithAnimated:YES];
    self.isPlaying = NO;
  } else if (playState == SSPlayerPlayStatePlayStopped) {
    [self endLoading];
    [self resetControlValue];
    self.isPlaying = NO;
  } else if (playState == SSPlayerPlayStatePlayFailed) {
    [self endLoading];
    [self resetControlValue];
    self.isPlaying = NO;
  }
}

- (void)setLoadState:(SSPlayerLoadState)loadState {
  _loadState = loadState;
  if (loadState == SSPlayerLoadStateStalled ||
      loadState == SSPlayerLoadStatePrepare) {
    [self starLoading];
  } else {
    [self endLoading];
  }
}

- (void)setIsPlaying:(BOOL)isPlaying {
  _isPlaying = isPlaying;
  if (isPlaying) {
    [self.playButton setImage:self.playButtonPlayingStateImage forState:UIControlStateNormal];
  } else {
    [self.playButton setImage:self.playButtonPauseStateImage forState:UIControlStateNormal];
  }
}

- (void)setIsToolBarButtonActive:(BOOL)isToolBarButtonActive {
  _isToolBarButtonActive = isToolBarButtonActive;
  if (isToolBarButtonActive == NO && self.isHidenToolBar == NO) {
    [self autoHidenToolBar];
  }
}
@end

@implementation SSPlayerControlView (UIData)

static char kAssociatedObjectKey_isLike;
static char kAssociatedObjectKey_isFullScreen;
static char kAssociatedObjectKey_sliderValue;
static char kAssociatedObjectKey_sliderBufferValue;
static char kAssociatedObjectKey_currentTime;
static char kAssociatedObjectKey_duration;
static char kAssociatedObjectKey_likeCount;
static char kAssociatedObjectKey_placeholder;
static char kAssociatedObjectKey_title;

- (BOOL)isLike {
  return [((NSNumber *)objc_getAssociatedObject(self, &kAssociatedObjectKey_isLike)) boolValue];
}

- (void)setIsLike:(BOOL)isLike {
  if (isLike) {
    [self.likeButton setImage:self.likeButtonLikedStateImage forState:UIControlStateNormal];
  } else {
    [self.likeButton setImage:self.likeButtonUnLikedStateImage forState:UIControlStateNormal];
  }
  objc_setAssociatedObject(self, &kAssociatedObjectKey_isLike,
                           @(isLike),
                           OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (BOOL)isFullScreen {
  return [((NSNumber *)objc_getAssociatedObject(self, &kAssociatedObjectKey_isFullScreen)) boolValue];
}

- (void)setIsFullScreen:(BOOL)isFullScreen {
  if (isFullScreen) {
    [self.fullScreenButton setImage:self.leaveFullScreenButtonImage forState:UIControlStateNormal];
  } else {
    [self.fullScreenButton setImage:self.enterFullScreenButtonImage forState:UIControlStateNormal];
  }
  objc_setAssociatedObject(self, &kAssociatedObjectKey_isFullScreen,
                           @(isFullScreen),
                           OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (CGFloat)sliderValue{
  return [((NSNumber *)objc_getAssociatedObject(self, &kAssociatedObjectKey_sliderValue)) floatValue];
}

- (void)setSliderValue:(CGFloat)sliderValue {
  self.sliderView.value = MAX(sliderValue, 0);
  objc_setAssociatedObject(self, &kAssociatedObjectKey_sliderValue,
                           @(sliderValue),
                           OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (CGFloat)sliderBufferValue {
  return [((NSNumber *)objc_getAssociatedObject(self, &kAssociatedObjectKey_sliderBufferValue)) floatValue];
}

- (void)setSliderBufferValue:(CGFloat)sliderBufferValue {
  self.sliderView.bufferValue = MAX(sliderBufferValue, 0);
  objc_setAssociatedObject(self, &kAssociatedObjectKey_sliderBufferValue,
                           @(sliderBufferValue),
                           OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (NSTimeInterval)currentTime {
  return [((NSNumber *)objc_getAssociatedObject(self, &kAssociatedObjectKey_currentTime)) doubleValue];
}

- (void)setCurrentTime:(NSTimeInterval)currentTime {
  NSInteger timeLength = MAX(currentTime, 0);
  NSInteger seconds = timeLength % 60;
  NSInteger minutes = (timeLength / 60) % 60;
  NSString *time = [NSString stringWithFormat:@"%02li:%02li",(long)minutes, (long)seconds];
  self.timeLable.text = time;
  objc_setAssociatedObject(self, &kAssociatedObjectKey_currentTime,
                           @(currentTime),
                           OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (NSTimeInterval)duration {
  return [((NSNumber *)objc_getAssociatedObject(self, &kAssociatedObjectKey_duration)) doubleValue];
}

- (void)setDuration:(NSTimeInterval)duration {
  NSInteger timeLength = MAX(duration, 0);
  NSInteger seconds  = timeLength % 60;
  NSInteger minutes  = (timeLength / 60) % 60;
  NSString *time = [NSString stringWithFormat:@"%02li:%02li",(long)minutes, (long)seconds];
  self.durationLable.text = time;
  objc_setAssociatedObject(self, &kAssociatedObjectKey_duration,
                           @(duration),
                           OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (NSInteger)likeCount {
  return [((NSNumber *)objc_getAssociatedObject(self, &kAssociatedObjectKey_likeCount)) integerValue];
}

- (void)setLikeCount:(NSInteger)likeCount {
  NSString *count = @"0";
  if (likeCount >= 1000) {
    count = [NSString stringWithFormat:@"%.2f",likeCount/1000.0];
    count = [count stringByRemoveLastCharacter];
    count = [count stringByAppendingString:@"k"];
  } else if (likeCount == 0) {
    count = @"";
  } else {
    count = [NSString stringWithFormat:@"%@",@(likeCount)];
  }
  
  self.likeCountLable.text = count;
  [self setNeedsLayout];
  [self layoutIfNeeded];
  objc_setAssociatedObject(self, &kAssociatedObjectKey_likeCount,
                           @(likeCount),
                           OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (UIImage *)placeholder {
  return ((UIImage *)objc_getAssociatedObject(self, &kAssociatedObjectKey_placeholder));
}

- (void)setPlaceholder:(UIImage *)placeholder {
  objc_setAssociatedObject(self, &kAssociatedObjectKey_placeholder,
                           placeholder,
                           OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (NSString *)title {
  return ((NSString *)objc_getAssociatedObject(self, &kAssociatedObjectKey_title));
}

- (void)setTitle:(NSString *)title {
  if (title == nil) title = @"";
  self.titleLable.text = title;
  objc_setAssociatedObject(self, &kAssociatedObjectKey_title,
                           title,
                           OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}
@end

@implementation SSPlayerControlView (Control)

- (void)autoHidenToolBar {
  @weakify(self)
  if (self.toolBarHidenBlock) {
    dispatch_block_cancel(self.toolBarHidenBlock);
    self.toolBarHidenBlock = nil;
  }
  self.toolBarHidenBlock = dispatch_block_create(0, ^{
    @strongify(self)
    [self hideToolBarIfNeedWithAnimated:YES];
  });
  dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2.0 * NSEC_PER_SEC)),
                 dispatch_get_main_queue(),
                 self.toolBarHidenBlock);
}

- (void)enterFullScreenWithAnimated:(BOOL)animated {
  if (self.isFullScreen == YES) { return; }
  if (self.delegate && [self.delegate respondsToSelector:@selector(playerControlView:fullScreenButtonDidSelected:isFullScreen:animated:)]) {
    [self.delegate playerControlView:self fullScreenButtonDidSelected:self.fullScreenButton isFullScreen:self.isFullScreen animated:animated];
  }
}

- (void)leaveFullScreenWithAnimated:(BOOL)animated {
  if (self.isFullScreen == NO) { return; }
  if (self.delegate && [self.delegate respondsToSelector:@selector(playerControlView:fullScreenButtonDidSelected:isFullScreen:animated:)]) {
    [self.delegate playerControlView:self fullScreenButtonDidSelected:self.fullScreenButton isFullScreen:self.isFullScreen animated:animated];
  }
}

- (void)hideToolBarIfNeedWithAnimated:(BOOL)animated {
  if (self.toolBarAnimationLock == YES) { return; }  /// toolbar is animating
  if (self.sliderView.isdragging == YES) { return; } /// slider is dragging
  if (self.isToolBarButtonActive == YES) { return; } /// toolbar button is excuting
  if (self.playState == SSPlayerPlayStatePlayFinished) { return; } /// play finished
  if (!self.isHidenToolBar) {
    self.isHidenToolBar = YES;
    @weakify(self);
    self.toolBarAnimationLock = YES;
    [UIView animateWithDuration:.25
                     animations:^{
                       @strongify(self)
                       self.bottomToolBar.alpha = 0;
                       self.topToolBar.alpha = 0;
                       self.bottomToolBar.top = self.height;
                       self.topToolBar.bottom = 0;
                       self.gestureContentView.width = self.width;
                       self.gestureContentView.left = 0;
                       self.gestureContentView.top = 0;
                       self.gestureContentView.height = self.height;
                     } completion:^(BOOL finished) {
                       @strongify(self)
                       self.toolBarAnimationLock = NO;
                     }];
  }
}

- (void)showToolBarIfNeedWithAnimated:(BOOL)animated {
  if (self.toolBarAnimationLock == YES) { return; }
  if (self.isHidenToolBar) {
    self.isHidenToolBar = NO;
    @weakify(self);
    self.toolBarAnimationLock = YES;
    [UIView animateWithDuration:.25
                     animations:^{
                       @strongify(self)
                       self.bottomToolBar.alpha = 1;
                       self.topToolBar.alpha = 1;
                       self.bottomToolBar.bottom = self.height;
                       self.topToolBar.top = 0;
                       self.gestureContentView.width = self.width;
                       self.gestureContentView.left = 0;
                       self.gestureContentView.top = self.topToolBar.height;
                       self.gestureContentView.height = self.height - self.topToolBar.height - self.bottomToolBar.height;
                     } completion:^(BOOL finished) {
                       @strongify(self)
                       self.toolBarAnimationLock = NO;
                       [self autoHidenToolBar];
                     }];
  }
}
@end

@implementation SSPlayerControlView (UIStyle)

static char kAssociatedObjectKey_playButtonPauseStateImage;
static char kAssociatedObjectKey_playButtonPlayingStateImage;
static char kAssociatedObjectKey_enterFullScreenButtonImage;
static char kAssociatedObjectKey_leaveFullScreenButtonImage;
static char kAssociatedObjectKey_backButtonImage;
static char kAssociatedObjectKey_likeButtonLikedStateImage;
static char kAssociatedObjectKey_likeButtonUnLikedStateImage;
static char kAssociatedObjectKey_shareButtonImage;
static char kAssociatedObjectKey_topBarShadowImage;
static char kAssociatedObjectKey_bottomBarShadowImage;

- (UIImage *)playButtonPauseStateImage {
  return ((UIImage *)objc_getAssociatedObject(self, &kAssociatedObjectKey_playButtonPauseStateImage));
}

- (void)setPlayButtonPauseStateImage:(UIImage *)playButtonPauseStateImage {
  if (!self.isPlaying) {
    [self.playButton setImage:playButtonPauseStateImage forState:UIControlStateNormal];
  } else {
    [self.playButton setImage:self.playButtonPlayingStateImage forState:UIControlStateNormal];
  }
  objc_setAssociatedObject(self, &kAssociatedObjectKey_playButtonPauseStateImage,
                           playButtonPauseStateImage,
                           OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (UIImage *)playButtonPlayingStateImage {
  return ((UIImage *)objc_getAssociatedObject(self, &kAssociatedObjectKey_playButtonPlayingStateImage));
}

- (void)setPlayButtonPlayingStateImage:(UIImage *)playButtonPlayingStateImage {
  if (self.isPlaying) {
    [self.playButton setImage:playButtonPlayingStateImage forState:UIControlStateNormal];
  } else {
    [self.playButton setImage:self.playButtonPauseStateImage forState:UIControlStateNormal];
  }
  objc_setAssociatedObject(self, &kAssociatedObjectKey_playButtonPlayingStateImage,
                           playButtonPlayingStateImage,
                           OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (UIImage *)enterFullScreenButtonImage {
  return ((UIImage *)objc_getAssociatedObject(self, &kAssociatedObjectKey_enterFullScreenButtonImage));
}

- (void)setEnterFullScreenButtonImage:(UIImage *)enterFullScreenButtonImage {
  if (!self.isFullScreen) {
    [self.fullScreenButton setImage:enterFullScreenButtonImage forState:UIControlStateNormal];
  } else {
    [self.fullScreenButton setImage:self.leaveFullScreenButtonImage forState:UIControlStateNormal];
  }
  objc_setAssociatedObject(self, &kAssociatedObjectKey_enterFullScreenButtonImage,
                           enterFullScreenButtonImage,
                           OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (UIImage *)leaveFullScreenButtonImage {
  return ((UIImage *)objc_getAssociatedObject(self, &kAssociatedObjectKey_leaveFullScreenButtonImage));
}

- (void)setLeaveFullScreenButtonImage:(UIImage *)leaveFullScreenButtonImage {
  if (self.isFullScreen) {
    [self.fullScreenButton setImage:leaveFullScreenButtonImage forState:UIControlStateNormal];
  } else {
    [self.fullScreenButton setImage:self.enterFullScreenButtonImage forState:UIControlStateNormal];
  }
  objc_setAssociatedObject(self, &kAssociatedObjectKey_leaveFullScreenButtonImage,
                           leaveFullScreenButtonImage,
                           OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (UIImage *)backButtonImage {
  return ((UIImage *)objc_getAssociatedObject(self, &kAssociatedObjectKey_backButtonImage));
}

- (void)setBackButtonImage:(UIImage *)backButtonImage {
  [self.backButton setImage:backButtonImage forState:UIControlStateNormal];
  objc_setAssociatedObject(self, &kAssociatedObjectKey_backButtonImage,
                           backButtonImage,
                           OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (UIImage *)likeButtonLikedStateImage {
  return ((UIImage *)objc_getAssociatedObject(self, &kAssociatedObjectKey_likeButtonLikedStateImage));
}

- (void)setLikeButtonLikedStateImage:(UIImage *)likeButtonLikedStateImage {
  if (self.isLike) {
    [self.likeButton setImage:likeButtonLikedStateImage forState:UIControlStateNormal];
  } else {
    [self.likeButton setImage:self.likeButtonUnLikedStateImage forState:UIControlStateNormal];
  }
  objc_setAssociatedObject(self, &kAssociatedObjectKey_likeButtonLikedStateImage,
                           likeButtonLikedStateImage,
                           OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (UIImage *)likeButtonUnLikedStateImage {
  return ((UIImage *)objc_getAssociatedObject(self, &kAssociatedObjectKey_likeButtonUnLikedStateImage));
}

- (void)setLikeButtonUnLikedStateImage:(UIImage *)likeButtonUnLikedStateImage {
  if (!self.isLike) {
    [self.likeButton setImage:likeButtonUnLikedStateImage forState:UIControlStateNormal];
  } else {
    [self.likeButton setImage:self.likeButtonLikedStateImage forState:UIControlStateNormal];
  }
  objc_setAssociatedObject(self, &kAssociatedObjectKey_likeButtonUnLikedStateImage,
                           likeButtonUnLikedStateImage,
                           OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (UIImage *)shareButtonImage {
  return ((UIImage *)objc_getAssociatedObject(self, &kAssociatedObjectKey_shareButtonImage));
}

- (void)setShareButtonImage:(UIImage *)shareButtonImage {
  [self.shareButton setImage:shareButtonImage forState:UIControlStateNormal];
  objc_setAssociatedObject(self, &kAssociatedObjectKey_shareButtonImage,
                           shareButtonImage,
                           OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (UIImage *)topBarShadowImage {
  return ((UIImage *)objc_getAssociatedObject(self, &kAssociatedObjectKey_topBarShadowImage));
}

- (void)setTopBarShadowImage:(UIImage *)topBarShadowImage {
  [self.topToolBarBackgroundView setImage:topBarShadowImage];
  objc_setAssociatedObject(self, &kAssociatedObjectKey_topBarShadowImage,
                           topBarShadowImage,
                           OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (UIImage *)bottomBarShadowImage {
  return ((UIImage *)objc_getAssociatedObject(self, &kAssociatedObjectKey_bottomBarShadowImage));
}

- (void)setBottomBarShadowImage:(UIImage *)bottomBarShadowImage {
  [self.bottomToolBarBackgroundView setImage:bottomBarShadowImage];
  objc_setAssociatedObject(self, &kAssociatedObjectKey_bottomBarShadowImage,
                           bottomBarShadowImage,
                           OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}
@end
