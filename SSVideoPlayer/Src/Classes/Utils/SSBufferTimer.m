
#import "SSBufferTimer.h"
#import <libkern/OSAtomic.h>

#if !__has_feature(objc_arc)
  #error SSBufferTimer is ARC only. Either turn on ARC for the project or use -fobjc-arc flag
#endif

#if OS_OBJECT_USE_OBJC
  #define ms_gcd_property_qualifier strong
  #define ms_release_gcd_object(object)
#else
  #define ms_gcd_property_qualifier assign
  #define ms_release_gcd_object(object) dispatch_release(object)
#endif

@interface SSBufferTimer ()

@property(nonatomic,   copy) void (^block)(SSBufferTimer *timer);
@property(nonatomic, ms_gcd_property_qualifier) dispatch_source_t source;
@end

@implementation SSBufferTimer

+ (SSBufferTimer *)repeatingTimerWithTimeInterval:(NSTimeInterval)seconds
                                            block:(void (^ __nullable)(SSBufferTimer *timer))block {
  NSParameterAssert(seconds);
  NSParameterAssert(block);
  
  SSBufferTimer *timer = [[self alloc] init];
  timer.block = block;
  timer.source = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER,
                                        0, 0,
                                        dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0));
  uint64_t nsec = (uint64_t)(seconds * NSEC_PER_SEC);
  dispatch_source_set_timer(timer.source,
                            dispatch_time(DISPATCH_TIME_NOW, nsec),
                            nsec, 0);
  dispatch_block_t dispatch_block = ^(){
    if (timer.block) {
      dispatch_sync(dispatch_get_main_queue(), ^{
        timer.block(timer);
      });
    }
  };
  dispatch_source_set_event_handler(timer.source, dispatch_block);
  dispatch_resume(timer.source);
  return timer;
}

- (void)invalidate {
  if (self.source) {
    dispatch_source_cancel(self.source);
    self.source = nil;
  }
  self.block = nil;
}

- (void)dealloc {
  [self invalidate];
}

- (void)fire {
  if (self.block) {
    self.block(self);
  }
}
@end
