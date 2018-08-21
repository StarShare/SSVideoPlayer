
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@protocol SSPlayerActivityIndicatorViewProtocol <NSObject>

- (BOOL)isLoading;
- (void)startLoading;
- (void)stopLoading;
@end

@interface SSPlayerActivityIndicatorView : UIView <SSPlayerActivityIndicatorViewProtocol>

@end

NS_ASSUME_NONNULL_END
