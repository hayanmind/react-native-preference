#import <React/RCTConvert.h>
#import "RNPreferenceManager.h"

static NSString *const kSHMPreferenceChangedEmitterTag = @"SHMPreferenceWhiteListChanged";
static NSString *const kSHMPreferenceClearEmitterTag = @"SHMPreferenceClear";

@implementation RNPreferenceManager
RCT_EXPORT_MODULE()
+ (BOOL)requiresMainQueueSetup { return YES; }
- (NSArray<NSString *> *)supportedEvents { return @[kSHMPreferenceChangedEmitterTag,kSHMPreferenceClearEmitterTag];}
- (instancetype)init {
    self = [super init];
    if (self) {
        [RNPreferenceSingleton shareInstance];
    }
    return self;
}
- (void)startObserving {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(perferenceChanged:) name:kSHMPreferenceChangedNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(cleared) name:kSHMPreferenceClearNotification object:nil];
}
- (void)stopObserving {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kSHMPreferenceChangedNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kSHMPreferenceClearNotification object:nil];
}
- (void)perferenceChanged:(NSNotification *)notification {
    [self sendEventWithName:kSHMPreferenceChangedEmitterTag body:notification.object];
}
- (void)cleared {
    [self sendEventWithName:kSHMPreferenceClearEmitterTag body:nil];
}


RCT_EXPORT_METHOD(set:(NSString *)key
                  value:(NSString *)value
                  resolve:(RCTPromiseResolveBlock)resolve
                  reject:(RCTPromiseRejectBlock)reject) {
    [[RNPreferenceSingleton shareInstance] setPreferenceValue:value forKey:key];
    resolve([RNPreferenceSingleton getAllPreferences]);
}

RCT_EXPORT_METHOD(clear:(RCTPromiseResolveBlock)resolve
                  reject:(RCTPromiseRejectBlock)reject) {
    [[RNPreferenceSingleton shareInstance] clear];
    resolve([RNPreferenceSingleton getAllPreferences]);
}

RCT_EXPORT_METHOD(getPreferenceForKey:(NSString *)key
                  resolve:(RCTPromiseResolveBlock)resolve
                  reject:(RCTPromiseRejectBlock)reject) {
    resolve( [[RNPreferenceSingleton shareInstance] getPreferenceValueForKey:key] );
}

// 设置白名单, (需要接收状态发生改变的keys)
RCT_EXPORT_METHOD(setWhiteList:(NSArray *)whiteList) {
    [RNPreferenceSingleton shareInstance].whiteList = whiteList;
}

- (NSDictionary *)constantsToExport {
    return @{ @"InitialPreferences" : RCTJSONStringify([RNPreferenceSingleton shareInstance].singlePerference, nil) };
}

@end




