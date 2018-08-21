
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@protocol SSPlayerSliderViewDelegate <NSObject>
@optional
- (void)sliderTouchBegan:(float)value;
- (void)sliderValueChanged:(float)value;
- (void)sliderTouchEnded:(float)value;
- (void)sliderTapped:(float)value;
@end

@interface SSPlayerSliderView : UIView

@property(nonatomic, weak) id<SSPlayerSliderViewDelegate> delegate;
@property(nonatomic, strong) UIColor *maximumTrackTintColor;
@property(nonatomic, strong) UIColor *minimumTrackTintColor;
@property(nonatomic, strong) UIColor *bufferTrackTintColor;
@property(nonatomic, strong) UIImage *maximumTrackImage;
@property(nonatomic, strong) UIImage *minimumTrackImage;
@property(nonatomic, strong) UIImage *bufferTrackImage;
@property(nonatomic, assign) float value;
@property(nonatomic, assign) float bufferValue;
@property(nonatomic, assign) BOOL allowTapped;
@property(nonatomic, assign) BOOL animate;
@property(nonatomic, assign) CGFloat sliderHeight;
@property(nonatomic, assign) BOOL isHideSliderBlock;
@property(nonatomic, assign) BOOL isdragging;
@property(nonatomic, assign, readonly) BOOL isForward;

- (void)setBackgroundImage:(UIImage *)image forState:(UIControlState)state;
- (void)setThumbImage:(UIImage *)image forState:(UIControlState)state;
@end

NS_ASSUME_NONNULL_END
