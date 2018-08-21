
#import "SSPlayerSliderView.h"

@interface _SSPlayerSliderButton : UIButton @end
@implementation _SSPlayerSliderButton
- (BOOL)pointInside:(CGPoint)point withEvent:(UIEvent *)event {
  CGRect bounds = self.bounds;
  bounds = CGRectInset(bounds, -30, -30);
  return CGRectContainsPoint(bounds, point);
}
@end

@interface SSPlayerSliderView ()

@property(nonatomic, strong) UIImageView *bgProgressView;
@property(nonatomic, strong) UIImageView *bufferProgressView;
@property(nonatomic, strong) UIImageView *sliderProgressView;
@property(nonatomic, strong) _SSPlayerSliderButton *sliderBtn;
@property(nonatomic, assign) CGPoint lastPoint;
@property(nonatomic, strong) UITapGestureRecognizer *tapGesture;
@property(nonatomic, assign, readwrite) BOOL isForward;
@end

@implementation SSPlayerSliderView

- (instancetype)initWithFrame:(CGRect)frame {
  self = [super initWithFrame:frame];
  if (self) {
    self.allowTapped = YES;
    self.animate = YES;
    [self addSubViews];
    self.sliderHeight = 2;
  }
  return self;
}

- (void)awakeFromNib {
  [super awakeFromNib];
  self.allowTapped = YES;
  self.animate = YES;
  [self addSubViews];
  self.sliderHeight = 2;
}

- (void)layoutSubviews {
  [super layoutSubviews];
  
  if (self.sliderBtn.hidden) {
    self.bgProgressView.width   = self.width;
  } else {
    self.bgProgressView.width   = self.width;
  }
  
  self.bgProgressView.centerY     = self.height * 0.5;
  self.bufferProgressView.centerY = self.height * 0.5;
  self.sliderProgressView.centerY = self.height * 0.5;
  self.sliderBtn.centerY          = self.height * 0.5;
  
  CGFloat finishValue = self.bgProgressView.width * self.bufferValue;
  self.bufferProgressView.width = finishValue;
  
  CGFloat progressValue  = self.bgProgressView.width * self.value;
  self.sliderProgressView.width = progressValue;
  self.sliderBtn.left = (self.width - self.sliderBtn.width) * self.value;
}

- (void)addSubViews {
  self.backgroundColor = [UIColor clearColor];
  [self addSubview:self.bgProgressView];
  [self addSubview:self.bufferProgressView];
  [self addSubview:self.sliderProgressView];
  [self addSubview:self.sliderBtn];
  self.bgProgressView.frame     = CGRectMake(0, 0, 0, self.sliderHeight);
  self.bufferProgressView.frame = self.bgProgressView.frame;
  self.sliderProgressView.frame = self.bgProgressView.frame;
  self.sliderBtn.frame          = CGRectMake(0, 0, 12, 12);
  self.tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapped:)];
  [self addGestureRecognizer:self.tapGesture];
}

#pragma mark - Setter

- (void)setMaximumTrackTintColor:(UIColor *)maximumTrackTintColor {
  _maximumTrackTintColor = maximumTrackTintColor;
  self.bgProgressView.backgroundColor = maximumTrackTintColor;
}

- (void)setMinimumTrackTintColor:(UIColor *)minimumTrackTintColor {
  _minimumTrackTintColor = minimumTrackTintColor;
  self.sliderProgressView.backgroundColor = minimumTrackTintColor;
}

- (void)setBufferTrackTintColor:(UIColor *)bufferTrackTintColor {
  _bufferTrackTintColor = bufferTrackTintColor;
  self.bufferProgressView.backgroundColor = bufferTrackTintColor;
}

- (void)setMaximumTrackImage:(UIImage *)maximumTrackImage {
  _maximumTrackImage = maximumTrackImage;
  self.bgProgressView.image = maximumTrackImage;
  self.maximumTrackTintColor = [UIColor clearColor];
}

- (void)setMinimumTrackImage:(UIImage *)minimumTrackImage {
  _minimumTrackImage = minimumTrackImage;
  self.sliderProgressView.image = minimumTrackImage;
  self.minimumTrackTintColor = [UIColor clearColor];
}

- (void)setBufferTrackImage:(UIImage *)bufferTrackImage {
  _bufferTrackImage = bufferTrackImage;
  self.bufferProgressView.image = bufferTrackImage;
  self.bufferTrackTintColor = [UIColor clearColor];
}

- (void)setValue:(float)value {
  _value = value;
  CGFloat finishValue  = self.bgProgressView.width * value;
  self.sliderProgressView.width = finishValue;
  self.sliderBtn.left = (self.width - self.sliderBtn.width) * value;
  self.lastPoint = self.sliderBtn.center;
}

- (void)setBufferValue:(float)bufferValue {
  _bufferValue = bufferValue;
  CGFloat finishValue = self.bgProgressView.width * bufferValue;
  self.bufferProgressView.width = finishValue;
}

- (void)setBackgroundImage:(UIImage *)image forState:(UIControlState)state {
  [self.sliderBtn setBackgroundImage:image forState:state];
  [self.sliderBtn sizeToFit];
  [self.sliderBtn.layer setCornerRadius:0];
  [self.sliderBtn.layer setMasksToBounds:NO];
}

- (void)setThumbImage:(UIImage *)image forState:(UIControlState)state {
  [self.sliderBtn setImage:image forState:state];
  [self.sliderBtn sizeToFit];
  [self.sliderBtn.layer setCornerRadius:0];
  [self.sliderBtn.layer setMasksToBounds:NO];
}

- (void)setAllowTapped:(BOOL)allowTapped {
  _allowTapped = allowTapped;
  if (!allowTapped) {
    [self removeGestureRecognizer:self.tapGesture];
  }
}

- (void)setSliderHeight:(CGFloat)sliderHeight {
  _sliderHeight = sliderHeight;
  self.bgProgressView.height     = sliderHeight;
  self.bufferProgressView.height = sliderHeight;
  self.sliderProgressView.height = sliderHeight;
  self.bgProgressView.layer.cornerRadius = self.sliderHeight/2.0;
  self.bgProgressView.layer.masksToBounds = YES;
  self.bufferProgressView.layer.cornerRadius = self.sliderHeight/2.0;
  self.bufferProgressView.layer.masksToBounds = YES;
  self.sliderProgressView.layer.cornerRadius = self.sliderHeight/2.0;
  self.sliderProgressView.layer.masksToBounds = YES;
}

- (void)setIsHideSliderBlock:(BOOL)isHideSliderBlock {
  _isHideSliderBlock = isHideSliderBlock;
  if (isHideSliderBlock) {
    self.sliderBtn.hidden = YES;
    self.bgProgressView.left     = 0;
    self.bufferProgressView.left = 0;
    self.sliderProgressView.left = 0;
    self.allowTapped = NO;
  }
}

#pragma mark - User Action

- (void)sliderBtnTouchBegin:(UIButton *)btn {
  if ([self.delegate respondsToSelector:@selector(sliderTouchBegan:)]) {
    [self.delegate sliderTouchBegan:self.value];
  }
  if (self.animate) {
    [UIView animateWithDuration:.25 animations:^{
      btn.transform = CGAffineTransformMakeScale(1.2, 1.2);
    }];
  }
}

- (void)sliderBtnTouchEnded:(UIButton *)btn {
  if ([self.delegate respondsToSelector:@selector(sliderTouchEnded:)]) {
    [self.delegate sliderTouchEnded:self.value];
  }
  if (self.animate) {
    [UIView animateWithDuration:.25 animations:^{
      btn.transform = CGAffineTransformIdentity;
    }];
  }
}

- (void)sliderBtnDragMoving:(UIButton *)btn event:(UIEvent *)event {
  CGPoint point = [event.allTouches.anyObject locationInView:self];
  float value = (point.x - btn.width * 0.5) / (self.width - btn.width);
  value = value >= 1.0 ? 1.0 : value <= 0.0 ? 0.0 : value;
  if (self.value == value) return;
  self.isForward = self.value < value;
  [self setValue:value];
  if ([self.delegate respondsToSelector:@selector(sliderValueChanged:)]) {
    [self.delegate sliderValueChanged:value];
  }
}

- (void)tapped:(UITapGestureRecognizer *)tap {
  CGPoint point = [tap locationInView:self];
  float value = (point.x - self.bgProgressView.left) * 1.0 / self.bgProgressView.width;
  value = value >= 1.0 ? 1.0 : value <= 0 ? 0 : value;
  [self setValue:value];
  if ([self.delegate respondsToSelector:@selector(sliderTapped:)]) {
    [self.delegate sliderTapped:value];
  }
}

#pragma mark - getter

- (UIView *)bgProgressView {
  if (!_bgProgressView) {
    _bgProgressView = [UIImageView new];
    _bgProgressView.backgroundColor = [UIColor grayColor];
    _bgProgressView.contentMode = UIViewContentModeScaleAspectFill;
    _bgProgressView.clipsToBounds = YES;
    _bgProgressView.layer.cornerRadius = self.sliderHeight/2.0;
    _bgProgressView.layer.masksToBounds = YES;
  }
  return _bgProgressView;
}

- (UIView *)bufferProgressView {
  if (!_bufferProgressView) {
    _bufferProgressView = [UIImageView new];
    _bufferProgressView.backgroundColor = [UIColor whiteColor];
    _bufferProgressView.contentMode = UIViewContentModeScaleAspectFill;
    _bufferProgressView.clipsToBounds = YES;
    _bufferProgressView.layer.cornerRadius = self.sliderHeight/2.0;
    _bufferProgressView.layer.masksToBounds = YES;
  }
  return _bufferProgressView;
}

- (UIView *)sliderProgressView {
  if (!_sliderProgressView) {
    _sliderProgressView = [UIImageView new];
    _sliderProgressView.backgroundColor = [UIColor redColor];
    _sliderProgressView.contentMode = UIViewContentModeScaleAspectFill;
    _sliderProgressView.clipsToBounds = YES;
    _sliderProgressView.layer.cornerRadius = self.sliderHeight/2.0;
    _sliderProgressView.layer.masksToBounds = YES;
  }
  return _sliderProgressView;
}

- (_SSPlayerSliderButton *)sliderBtn {
  if (!_sliderBtn) {
    _sliderBtn = [_SSPlayerSliderButton buttonWithType:UIButtonTypeCustom];
    [_sliderBtn setAdjustsImageWhenHighlighted:NO];
    [_sliderBtn setClipsToBounds:YES];
    [_sliderBtn.layer setCornerRadius:6];
    [_sliderBtn.layer setMasksToBounds:YES];
    [_sliderBtn setBackgroundColor:UIColor.whiteColor];
    [_sliderBtn addTarget:self action:@selector(sliderBtnTouchBegin:) forControlEvents:UIControlEventTouchDown];
    [_sliderBtn addTarget:self action:@selector(sliderBtnTouchEnded:) forControlEvents:UIControlEventTouchCancel];
    [_sliderBtn addTarget:self action:@selector(sliderBtnTouchEnded:) forControlEvents:UIControlEventTouchUpInside];
    [_sliderBtn addTarget:self action:@selector(sliderBtnTouchEnded:) forControlEvents:UIControlEventTouchUpOutside];
    [_sliderBtn addTarget:self action:@selector(sliderBtnDragMoving:event:) forControlEvents:UIControlEventTouchDragInside];
  }
  return _sliderBtn;
}
@end
