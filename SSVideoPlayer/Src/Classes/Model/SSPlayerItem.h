
#import <Foundation/Foundation.h>
#import "SSAsset.h"

NS_ASSUME_NONNULL_BEGIN

@interface SSPlayerItem : NSObject

@property(nonatomic, strong, readonly) SSAsset *asset;
- (id)avPlayerItem;

+ (instancetype)playerItemWithURL:(NSURL *)URL;
+ (instancetype)playerItemWithAsset:(SSAsset *)asset;
- (instancetype)initWithURL:(NSURL *)URL;
- (instancetype)initWithAsset:(SSAsset *)asset;
- (void)cancelPendingSeeks;
- (void)destroy;
@end

NS_ASSUME_NONNULL_END
