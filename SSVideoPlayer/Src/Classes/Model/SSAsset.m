
#import "SSAsset.h"
#import <AVFoundation/AVFoundation.h>
#import "SSPlayerLoader.h"

@interface SSAsset ()

@property(nonatomic, strong) NSURL *url;
@property(nonatomic, strong) NSURL *handledUrl;
@property(nonatomic, strong) SSPlayerLoader *resourceLoader;
@property(nonatomic, strong) AVURLAsset *urlAsset;
@end

@implementation SSAsset

+ (instancetype)assetWithURL:(NSURL *)URL {
  return [[self alloc] initWithURL:URL];
}

- (instancetype)initWithURL:(NSURL *)URL {
  self = [super init];
  if (self) {
    [self setUrl:URL];
    [self handleUrl:URL];
    [self setUrlAsset:[AVURLAsset URLAssetWithURL:self.handledUrl options:nil]];
    [self setResourceLoader:[[SSPlayerLoader alloc] init]];
    [self.urlAsset.resourceLoader setDelegate:self.resourceLoader
                                        queue:dispatch_get_main_queue()];
  }
  return self;
}

- (void)destroy {
  if (self.urlAsset) {
    [self.urlAsset cancelLoading];
    self.urlAsset = nil;
  }
}

#pragma mark - Handle URL

- (void)handleUrl:(NSURL *)URL{
  NSURLComponents *components = [[NSURLComponents alloc] initWithURL:URL resolvingAgainstBaseURL:NO];
  components.scheme = @"SSStreaming";
  self.handledUrl = URL;
}

#pragma mark - Getter

- (id)avURLAsset {
  return self.urlAsset;
}
@end
