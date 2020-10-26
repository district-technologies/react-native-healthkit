#import <React/RCTBridgeModule.h>

@interface RCT_EXTERN_MODULE(Healthkit, NSObject)

RCT_EXTERN_METHOD(requestPermissions:(RCTPromiseResolveBlock)resolve
                 withRejecter:(RCTPromiseRejectBlock)reject)

RCT_EXTERN_METHOD(getWorkouts:(NSDictionary)input
                  withResolver:(RCTPromiseResolveBlock)resolve
                  withRejecter:(RCTPromiseRejectBlock)reject)

@end
