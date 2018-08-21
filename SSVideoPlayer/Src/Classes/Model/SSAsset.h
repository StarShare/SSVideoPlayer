
#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@class SSPlayerLoader;

@interface SSAsset : NSObject

@property(nonatomic, strong, readonly) SSPlayerLoader *resourceLoader;
@property(nonatomic, strong, readonly) NSURL *url;
- (id)avURLAsset;

+ (instancetype)assetWithURL:(NSURL *)URL;
- (instancetype)initWithURL:(NSURL *)URL;
- (void)destroy;
@end

NS_ASSUME_NONNULL_END
