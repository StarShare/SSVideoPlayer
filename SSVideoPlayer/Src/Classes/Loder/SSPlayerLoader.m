
#import "SSPlayerLoader.h"

@implementation SSPlayerLoader

- (BOOL)resourceLoader:(AVAssetResourceLoader *)resourceLoader shouldWaitForLoadingOfRequestedResource:(AVAssetResourceLoadingRequest *)loadingRequest{
  [self handleLoadingRequest:loadingRequest];
  return YES;
}

#pragma mark -

- (void)handleLoadingRequest:(AVAssetResourceLoadingRequest *)loadingReques {
  
}
@end
