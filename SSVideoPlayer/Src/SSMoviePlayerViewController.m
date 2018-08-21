
#import "SSMoviePlayerViewController.h"
#import "SSPlayerController.h"

@interface SSMoviePlayerViewController () <SSPlayerControllerDelegate>
@property(nonatomic, strong) SSPlayerController *playerController;
@end

@implementation SSMoviePlayerViewController

- (void)viewDidLoad {
  [super viewDidLoad];
  self.view.backgroundColor = [UIColor blackColor];
}

- (void)didInitialized {
  [super didInitialized];

  self.playerController = [[SSPlayerController alloc] init];
  self.playerController.delegate = self;
}

- (void)viewWillDisappear:(BOOL)animated {
  [super viewWillDisappear:animated];
  [UIHelper renderStatusBarShowAnimation:NO];
}

- (void)viewDidAppear:(BOOL)animated {
  [super viewDidAppear:animated];
  [UIHelper renderStatusBarHidenAnimation:YES];
}

- (void)initSubviews {
  [super initSubviews];
  
  /// 添加播放器视图到控制器上
  /// 包含播放视频的视图和播放器控制器视图
  [self.view addSubview:self.playerController.view];
  
  /// 可能设置 fullScreen 的时候 self.playerController.view 还没加载在父视图上
  /// 这里重新设置下是触发屏幕方向更新
  self.playerController.fullScreen = self.playerController.isFullScreen;
}

- (void)needLayoutSubviews {
  [super needLayoutSubviews];
  
  self.playerController.view.frame = self.view.bounds;
}

- (BOOL)shouldForceRotateDeviceOrientation {
  /// 开启强制屏幕旋转
  return YES;
}

#pragma mark - <SSPlayerControllerDelegate>

- (void)playerControllerDidStop:(SSPlayerController *)player {
  [self dismissViewControllerAnimated:YES
                           completion:NULL];
  [UBStatistics shared].resourceVisitVideoObjectId = nil;
}

- (void)playerController:(SSPlayerController *)controller receiveError:(NSError *)error {
  if (error) {
    [UITips showError:error.errorMessage hideAfterDelay:UITipsDelay];
  }
}

- (void)playerController:(SSPlayerController *)controller fullScreenChanged:(BOOL)fullScreen {
  if (fullScreen) {
    self.supportedOrientationMask = UIInterfaceOrientationMaskLandscapeRight;
  } else {
    self.supportedOrientationMask = UIInterfaceOrientationMaskPortrait;
  }
  /// 触发屏幕旋转
  [self viewWillAppear:YES];
}

- (void)playerController:(SSPlayerController *)controller
        likeStateChanged:(BOOL)like
                objectId:(NSString *)objectId {
  if (self.delegate && [self.delegate respondsToSelector:@selector(playerViewController:likeStateChanged:objectId:)]) {
    [self.delegate playerViewController:self likeStateChanged:like objectId:objectId];
  }
}

- (void)playerController:(SSPlayerController *)controller
        likeRequestError:(NSError *)error
           originalState:(BOOL)like
                objectId:(NSString *)objectId  {
  if (like) {
    [UITips showError:@"取消点赞失败" hideAfterDelay:UITipsDelay];
  } else {
    [UITips showError:@"点赞失败" hideAfterDelay:UITipsDelay];
  }
}
@end
