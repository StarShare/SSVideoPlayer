
#import <UIKit/UIKit.h>
#import "SSPlayerActivityIndicatorView.h"
#import "SSPlayerSliderView.h"
#import "SSPlayerUserInfo.h"

NS_ASSUME_NONNULL_BEGIN

@class SSPlayerControlView;

@protocol SSPlayerControlViewDelegate <NSObject>
@optional
- (void)playerControlView:(SSPlayerControlView *)view playButtonDidSelected:(UIButton *)button isPlaying:(BOOL)isPlaying;
- (void)playerControlView:(SSPlayerControlView *)view fullScreenButtonDidSelected:(UIButton *)button isFullScreen:(BOOL)isFullScreen animated:(BOOL)animated;
- (void)playerControlView:(SSPlayerControlView *)view backButtonDidSelected:(UIButton *)button isFullScreen:(BOOL)isFullScreen;
- (void)playerControlView:(SSPlayerControlView *)view likeButtonDidSelected:(UIButton *)button;
- (void)playerControlView:(SSPlayerControlView *)view shareButtonDidSelected:(UIButton *)button;
- (void)playerControlView:(SSPlayerControlView *)view singleTapGesture:(UITapGestureRecognizer *)tap isHidenToolBar:(BOOL)isHidenToolBar;
- (void)playerControlView:(SSPlayerControlView *)view doubleTapGesture:(UITapGestureRecognizer *)tap isPlaying:(BOOL)isPlaying;
@end

@interface SSPlayerControlView : UIView

@property(nonatomic, weak) id<SSPlayerControlViewDelegate> delegate;
@property(nonatomic, assign) SSPlayerPlaybackState playState;
@property(nonatomic, assign) SSPlayerLoadState loadState;
@property(nonatomic, strong, readonly) UIView<SSPlayerActivityIndicatorViewProtocol> *indicatorView;
@property(nonatomic, strong, readonly) UIView *bottomToolBar;
@property(nonatomic, strong, readonly) UIImageView *bottomToolBarBackgroundView;
@property(nonatomic, strong, readonly) UIButton *playButton;
@property(nonatomic, strong, readonly) UILabel *timeLable;
@property(nonatomic, strong, readonly) SSPlayerSliderView *sliderView;
@property(nonatomic, strong, readonly) UILabel *durationLable;
@property(nonatomic, strong, readonly) UIButton *fullScreenButton;
@property(nonatomic, strong, readonly) UIView *topToolBar;
@property(nonatomic, strong, readonly) UIImageView *topToolBarBackgroundView;
@property(nonatomic, strong, readonly) UIButton *backButton;
@property(nonatomic, strong, readonly) UILabel *titleLable;
@property(nonatomic, strong, readonly) UIButton *likeButton;
@property(nonatomic, strong, readonly) UILabel *likeCountLable;
@property(nonatomic, strong, readonly) UIButton *shareButton;
@property(nonatomic, strong, readonly) UIView *gestureContentView;
@property(nonatomic, strong, readonly) UIImageView *placeholderView;

- (void)didInitialized NS_REQUIRES_SUPER;
- (void)initSubviews NS_REQUIRES_SUPER;
- (void)placeSubviews NS_REQUIRES_SUPER;
@end

@interface SSPlayerControlView (UIData)

@property(nonatomic, assign) BOOL isLike;
@property(nonatomic, assign) BOOL isFullScreen;
@property(nonatomic, assign) CGFloat sliderValue;
@property(nonatomic, assign) CGFloat sliderBufferValue;
@property(nonatomic, assign) NSTimeInterval currentTime;
@property(nonatomic, assign) NSTimeInterval duration;
@property(nonatomic, assign) NSInteger likeCount;
@property(nonatomic, strong) UIImage *placeholder;
@property(nonatomic, copy) NSString *title;
@end

@interface SSPlayerControlView (Control)

- (void)autoHidenToolBar;
- (void)enterFullScreenWithAnimated:(BOOL)animated;
- (void)leaveFullScreenWithAnimated:(BOOL)animated;
- (void)showToolBarIfNeedWithAnimated:(BOOL)animated;
- (void)hideToolBarIfNeedWithAnimated:(BOOL)animated;
@end

@interface SSPlayerControlView (UIStyle)

@property(nonatomic, strong) UIImage *playButtonPauseStateImage;
@property(nonatomic, strong) UIImage *playButtonPlayingStateImage;
@property(nonatomic, strong) UIImage *enterFullScreenButtonImage;
@property(nonatomic, strong) UIImage *leaveFullScreenButtonImage;
@property(nonatomic, strong) UIImage *backButtonImage;
@property(nonatomic, strong) UIImage *likeButtonUnLikedStateImage;
@property(nonatomic, strong) UIImage *likeButtonLikedStateImage;
@property(nonatomic, strong) UIImage *shareButtonImage;
@property(nonatomic, strong) UIImage *topBarShadowImage;
@property(nonatomic, strong) UIImage *bottomBarShadowImage;
@end

NS_ASSUME_NONNULL_END

