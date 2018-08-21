
#import <UIKit/UIKit.h>
#import "SSPlayerController.h"
#import "SSPlayerUserInfo.h"

NS_ASSUME_NONNULL_BEGIN

/**
 * @future
 *
 * SSPlayerController
 * SSPlayerUserInfo
 * SSPlayerControlView
 * SSPlayerSliderView
 * SSAVPlayer
 *
 * Classes of the above all support mutable delegate.
 * You can implement any delegate yourself,no internal logic will be affected.
 */

@class SSMoviePlayerViewController;

@protocol SSMoviePlayerViewControllerDelagate <NSObject>
@optional
- (void)playerViewController:(SSMoviePlayerViewController *)viewController likeStateChanged:(BOOL)like objectId:(NSString *)objectId;
@end

@class RichElement;

@interface SSMoviePlayerViewController : DSUIViewController

/**
 player controller.
 @see SSPlayerController
 */
@property(nonatomic, strong, readonly) SSPlayerController *playerController;
@property(nonatomic, weak) id <SSMoviePlayerViewControllerDelagate>delegate;
@end

NS_ASSUME_NONNULL_END
