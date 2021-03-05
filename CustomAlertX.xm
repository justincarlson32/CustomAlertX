#import <UIKit/UIWindow+Private.h>
#import <UIKit/UIKit.h>
#import <CoreGraphics/CoreGraphics.h>
#import <QuartzCore/QuartzCore.h>
#import <sys/utsname.h>
#import <objc/runtime.h>
#include "CustomAlertViewController.h"

#define PLIST_FILENAME @"/var/mobile/Library/Preferences/com.ion.customalertx.plist"

static BOOL isIphoneX = YES;
static BOOL isAlwaysOn;
static CustomAlertViewController *__strong alertController;
static NSMutableDictionary* preferences;
static NSString *lastAppBundleID;
static UIWindow *windowRef = nil;


@interface SBBacklightController : NSObject
+ (id)sharedInstance;
- (void)_startFadeOutAnimationFromLockSource:(int)arg1;
- (void) sendAlwaysOnFrequencyTrigger;
@end


@interface SpringBoard
+ (id)sharedInstance;
- (BOOL)isLocked;
- (NSString*)deviceName;
@end
%hook SpringBoard
static SpringBoard *__strong sharedInstance;

%new
- (NSString *)deviceName{
    struct utsname systemInfo;
    uname(&systemInfo);

    return [NSString stringWithCString:systemInfo.machine
                              encoding:NSUTF8StringEncoding];
};
- (id)init {
  NSString *deviceInformation = [self deviceName];
  if ([deviceInformation isEqualToString:@"iPhone10,3"] || [deviceInformation isEqualToString:@"iPhone10,6"]){
    isIphoneX = YES;
  }else{
    isIphoneX = NO;
  }

  id original = %orig;
  sharedInstance = original;
  return original;
}
%new
+ (id)sharedInstance {
  return sharedInstance;
}

%end

%hook SBTapToWakeController

- (void)tapToWakeDidRecognize:(id)arg1{
  if (alertController.isNotifying || [alertController.alwaysOnFrequencyTimer isValid]){
    alertController.isAlwaysOnFrequencyRunning = NO;
    [alertController viewWasTouched];
  }
  %orig();
}

%end

@interface SBLiftToWakeManager
- (void)clearWindow;
@end

%hook SBLiftToWakeManager


- (void)liftToWakeController:(id)arg1 didObserveTransition:(long long)arg2{
  if (alertController.isNotifying || [alertController.alwaysOnFrequencyTimer isValid]){
    alertController.isAlwaysOnFrequencyRunning = NO;
    [alertController viewWasTouched];
  }
  %orig();
}

- (void)liftToWakeController:(id)arg1 didObserveTransition:(long long)arg2 deviceOrientation:(long long)arg3{
  if (alertController.isNotifying || [alertController.alwaysOnFrequencyTimer isValid]){
    alertController.isAlwaysOnFrequencyRunning = NO;
    [alertController viewWasTouched];
  }
  %orig();
}


%end

@interface SBNCScreenController
- (BOOL)isCustomAlertEnabled;
- (void)_turnOnScreen;
- (id)init;
+ (id)sharedSBNC;
@end



%hook SBNCScreenController

static id __strong sharedSBNC;

%new
- (_Bool)isCustomAlertEnabled{
  if ([[preferences valueForKey:@"borderEnabled"] boolValue])
    return YES;
  else if ([[preferences valueForKey:@"dotsEnabled"] boolValue])
    return YES;
  else if ([[preferences valueForKey:@"rainDropEnabled"] boolValue])
    return YES;
  else if ([[preferences valueForKey:@"cubeEnabled"] boolValue])
    return YES;

  return NO;
}

- (_Bool)canTurnOnScreenForNotificationRequest:(id)arg1{
    return YES;
}

- (void)_turnOnScreen{
  %orig();
}

- (void)turnOnScreenForNotificationRequest:(id)request {
  preferences = [[NSMutableDictionary alloc] initWithContentsOfFile: PLIST_FILENAME];
  isAlwaysOn = [[preferences valueForKey:@"isAlwaysOn"] boolValue];
  BOOL isLocked = [[objc_getClass("SpringBoard") sharedInstance] isLocked];
  id sharedInstance = [objc_getClass("SBLockScreenManager") sharedInstance];
  BOOL isScreenOn = MSHookIvar<BOOL>(sharedInstance, "_isScreenOn");
  lastAppBundleID = [request valueForKey:@"sectionIdentifier"];
  BOOL isEnabled = [self isCustomAlertEnabled];

  if (isLocked && !isScreenOn && isEnabled){
    UIWindow *window = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
    window.windowLevel = 3000;
    [window _setSecure: YES];
    [window makeKeyAndVisible];
    if (!alertController){
      alertController = [[CustomAlertViewController alloc] retain];
    }
    UITapGestureRecognizer *singleTap = [[[UITapGestureRecognizer alloc]initWithTarget:alertController action:@selector(viewWasTouched)]autorelease];
    [window addGestureRecognizer:singleTap];
    [alertController initWithConfiguration:preferences isXDevice:isIphoneX withWidow:window fromApp:lastAppBundleID];

    windowRef = window;

  }else if (isScreenOn && alertController.isNotifying && alertController.bundleID != lastAppBundleID) {
    [alertController updateDrawingColor:lastAppBundleID];
  }else if (alertController.isAlwaysOnFrequencyRunning){

  }else{
    %orig();
  }

}

- (id)initWithBackLightController:(id)arg1 lockScreenManager:(id)arg2 lockStateAggregator:(id)arg3 quietModeStateAggregator:(id)arg4 {
  id original = %orig2
  sharedSBNC = original;
  return original;
}

- (id)initWithBackLightController:(id)arg1 lockScreenManager:(id)arg2 lockStateAggregator:(id)arg3{
  id original = %orig;
  sharedSBNC = original;
  return original;
}

%new
+ (id)sharedSBNC {
  return sharedSBNC;
}

%new
- (void)testing{
  NSString *testString = [NSString stringWithFormat:@"%@ --- %@ --- %d", alertController.scene, alertController.window, alertController.isNotifying];
  UIAlertView *alert = [[UIAlertView alloc]
                      initWithTitle:testString
                            message:@""
                           delegate:self
                  cancelButtonTitle:@""
                  otherButtonTitles:@"", nil];
[alert show];
[alert release];
}

%end

%hook SBLockScreenManager

- (void)_lockScreenDimmed:(id)arg1{
  if (alertController.isAlwaysOnFrequencyRunning){
    [alertController clearWindow];
    //%orig();
  }
  if (alertController.isNotifying){
    if (!isAlwaysOn){
      [alertController viewWasTouched];
      %orig();
    }

 }else{
   %orig();
 }
}

%end

%hook SBBacklightController

%new
- (void)sendAlwaysOnFrequencyTrigger{
    UIWindow *window = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
    window.windowLevel = 2000;
    [window _setSecure: YES];
    [window makeKeyAndVisible];
    UITapGestureRecognizer *singleTap = [[[UITapGestureRecognizer alloc]initWithTarget:alertController action:@selector(viewWasTouched)]autorelease];
    [window addGestureRecognizer:singleTap];
    [alertController initWithConfiguration:preferences isXDevice:isIphoneX withWidow:window fromApp:lastAppBundleID];
}

- (void)_startFadeOutAnimationFromLockSource:(int)arg1{
  if (isAlwaysOn && alertController.isNotifying){
    if (alertController.alwaysOnFrequency != 0.0){
      [alertController haltTimers];
      alertController.isNotifying = NO;
       if (!alertController.isAlwaysOnFrequencyRunning){
         alertController.alwaysOnFrequencyTimer = nil;
         NSTimer *__strong alwaysOnFrequencyTimer  = [
                               NSTimer scheduledTimerWithTimeInterval: (alertController.alwaysOnFrequency)
                               target: self
                               selector:@selector(sendAlwaysOnFrequencyTrigger)
                               userInfo: nil repeats:NO];
        [alwaysOnFrequencyTimer retain];
        [alertController performSelectorInBackground:@selector(startAlwaysOnFrequencyTimer:) withObject:alwaysOnFrequencyTimer];
        %orig();
    }
   }
  }else{
    %orig();
  }
};

%end

%hook SBLockHardwareButton

- (void)singlePress:(id)arg1{
  if (alertController.isNotifying || [alertController.alwaysOnFrequencyTimer isValid]){
    alertController.isAlwaysOnFrequencyRunning = NO;
    [alertController viewWasTouched];
  }
  %orig();
}


%end


%hook SBHomeHardwareButton

- (void)initialButtonDown:(id)arg1{
  if (alertController.isNotifying || [alertController.alwaysOnFrequencyTimer isValid]){
    alertController.isAlwaysOnFrequencyRunning = NO;
    [alertController viewWasTouched];
  }
  %orig();
}
%end
