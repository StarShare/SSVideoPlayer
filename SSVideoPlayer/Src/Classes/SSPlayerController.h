
#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "SSPlayer.h"
#import "SSPlayerControlView.h"

NS_ASSUME_NONNULL_BEGIN

@class RichElement;
@class SSUpvoter;
@class SSPlayer;
@class SSPlayerUserInfo;
@class SSPlayerControlView;
@class SSPlayerController;

@protocol SSPlayerControllerDelegate <NSObject>
@optional
- (void)playerControllerDidStop:(SSPlayerController *)controller;
- (void)playerController:(SSPlayerController *)controller receiveError:(NSError *)error;
- (void)playerController:(SSPlayerController *)controller fullScreenChanged:(BOOL)fullScreen;
- (void)playerController:(SSPlayerController *)controller likeStateChanged:(BOOL)like objectId:(NSString *)objectId;
- (void)playerController:(SSPlayerController *)controller likeRequestError:(NSError *)error originalState:(BOOL)like objectId:(NSString *)objectId;
@end

@interface SSPlayerController : NSObject

- (instancetype)initWithRichMedia:(RichElement *)richMedia;
@property(nonatomic, copy) RichElement *richMedia;

@property(nonatomic, weak) id<SSPlayerControllerDelegate> delegate;
@property(nonatomic, strong, readonly) UIView *view;
@property(nonatomic, assign, readonly) SSPlayerPlaybackState state;
@property(nonatomic, assign) SSPlayerScalingMode scalingMode;
@property(nonatomic, assign) BOOL muted;
@property(nonatomic, assign) float rate;
@property(nonatomic, assign, getter=isFullScreen) BOOL fullScreen;
- (void)setFullscreen:(BOOL)fullscreen animated:(BOOL)animated;
@property(nonatomic, assign) BOOL shouldAutoplay;
@end

NS_ASSUME_NONNULL_END
