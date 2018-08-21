
#import "SSPlayerItem.h"
#import <AVFoundation/AVFoundation.h>

@interface SSPlayerItem ()

@property(nonatomic, strong) SSAsset *asset;
@property(nonatomic, strong) AVPlayerItem *playerItem;
@end

@implementation SSPlayerItem

+ (instancetype)playerItemWithURL:(NSURL *)URL {
  return [self playerItemWithAsset:[SSAsset assetWithURL:URL]];
}

+ (instancetype)playerItemWithAsset:(SSAsset *)asset {
  return [[self alloc] initWithAsset:asset];
}

- (instancetype)initWithURL:(NSURL *)URL {
  return [self initWithAsset:[SSAsset assetWithURL:URL]];
}

- (instancetype)initWithAsset:(SSAsset *)asset {
  self = [super init];
  if (self) {
    self.asset = asset;
    self.playerItem = [AVPlayerItem playerItemWithAsset:[asset avURLAsset]
                           automaticallyLoadedAssetKeys:@[@"duration"]];
    if (@available(iOS 9.0, *)) {
      self.playerItem.canUseNetworkResourcesForLiveStreamingWhilePaused = YES;
    }
    if (@available(iOS 10.0, *)) {
      self.playerItem.preferredForwardBufferDuration = 1.0;
    }
  }
  return self;
}

- (void)cancelPendingSeeks {
  if (self.playerItem) {
    [self.playerItem cancelPendingSeeks];
  }
}

- (void)destroy {
  if (self.playerItem) {
    [self.asset destroy];
    [self.playerItem cancelPendingSeeks];
    self.playerItem = nil;
  }
}

#pragma mark - Getter

- (id)avPlayerItem {
  return self.playerItem;
}
@end
