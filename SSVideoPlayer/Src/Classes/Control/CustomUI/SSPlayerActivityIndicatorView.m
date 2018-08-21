
#import "SSPlayerActivityIndicatorView.h"

@interface SSPlayerActivityIndicatorView ()

@property(nonatomic, assign) BOOL animationd;
@property(nonatomic, strong) UIImageView *loadingImageView;
@end

@implementation SSPlayerActivityIndicatorView

- (instancetype)initWithFrame:(CGRect)frame {
  self = [super initWithFrame:frame];
  if (self) {
    self.animationd = NO;
    self.backgroundColor = [UIColor clearColor];
    self.loadingImageView = [[UIImageView alloc] initWithFrame:frame];
    self.loadingImageView.backgroundColor = [UIColor clearColor];
    self.loadingImageView.image = UIImageMake(UIImagePhotoVideoLoading);
    self.loadingImageView.hidden = YES;
    [self addSubview:self.loadingImageView];
  }
  return self;
}

- (void)layoutSubviews {
  [super layoutSubviews];
  self.loadingImageView.frame = self.bounds;
}

- (void)startLoading {
  if (self.hidden == NO) {
    self.animationd = YES;
    CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"transform.rotation.z"];
    animation.toValue = [NSNumber numberWithFloat: M_PI * 2.0];
    animation.duration = 1.0;
    animation.cumulative = YES;
    animation.repeatCount = MAXFLOAT;
    [self.loadingImageView.layer removeAnimationForKey:@"rotationAnimation"];
    [self.loadingImageView.layer addAnimation:animation forKey:@"rotationAnimation"];
    [self.loadingImageView setHidden:NO];
  }
}

- (void)stopLoading {
  if (self.hidden == NO) {
    self.animationd = NO;
    [self.loadingImageView.layer removeAnimationForKey:@"rotationAnimation"];
    [self.loadingImageView setHidden:YES];
  }
}

- (BOOL)isLoading {
  return self.animationd;
}
@end
