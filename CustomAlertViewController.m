#include "CustomAlertViewController.h"
#import <SceneKit/SceneKit.h>

@interface SBNCScreenController
+ (id)sharedSBNC;
- (void)_turnOnScreen;
@end

@interface SBBacklightController : NSObject
+ (id)sharedInstance;
- (void)_startFadeOutAnimationFromLockSource:(int)arg1;
@end

@implementation CustomAlertViewController

- (void)initWithConfiguration:(NSMutableDictionary *)preferences isXDevice:(BOOL)device withWidow:(UIWindow *)window fromApp:(NSString *)bundleID{
  if ([[preferences valueForKey:@"cubeEnabled"] boolValue]){
    self.animationType = 4;
    self.isAppSpecificColorEnabled = YES;
  }else if ([[preferences valueForKey:@"borderEnabled"] boolValue])
    self.animationType = 1;
  else if ([[preferences valueForKey:@"dotsEnabled"] boolValue])
    self.animationType = 2;
  else if ([[preferences valueForKey:@"rainDropEnabled"] boolValue])
    self.animationType = 3;

  if (!self.activeTimers)
    self.activeTimers = [[NSMutableArray alloc] init];
  if (!self.colorInformation)
    self.colorInformation = [[NSMutableDictionary alloc] init];
  //self.drawingColor = [UIColor whiteColor];

  self.isIphoneX = device;
  self.preferences = preferences;
  self.isAlwaysOnFrequencyRunning = NO;
  self.isAlwaysOn = [[preferences valueForKey:@"isAlwaysOn"] boolValue];
  self.alwaysOnFrequency = [[preferences valueForKey:@"alwaysOnFrequencyAmount"] floatValue];
  if (self.window != window){
    self.window.hidden = YES;
    [self.window release];
    self.window = nil;
    self.window = window;
    //[self.window retain];
  }

  self.isAppSpecificColorEnabled = [[preferences valueForKey:@"colorSpecificEnabled"] boolValue];
  if (self.isAppSpecificColorEnabled || self.animationType == 4){
    if (self.bundleID == bundleID){
      self.shouldUpdateDrawingColor = NO;
    }else{
      self.shouldUpdateDrawingColor = YES;
    }
    self.bundleID = bundleID;
  }
  [self handleAnimationStart];
}

- (void)handleAnimationStart{
  self.isNotifying = YES;
  if (self.animationType == 1){
    [self drawBorderEffect];
  }else if (self.animationType == 2){

    self.backView = [[UIView alloc] initWithFrame:[UIScreen mainScreen].bounds];
    self.backView.backgroundColor = [UIColor blackColor];
    [self.window addSubview:self.backView];
    self.Index = 0;
    UITapGestureRecognizer *singleTapRecognizer = [[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(viewWasTouched)] autorelease];
    [self.window addGestureRecognizer:singleTapRecognizer];
    [self drawDots];

  }else if (self.animationType == 3){

    UIView *backgroundView = [[UIView alloc] initWithFrame:[UIScreen mainScreen].bounds];
    backgroundView.backgroundColor = [UIColor blackColor];
    [self.window addSubview:backgroundView];
    self.Index = 0;
    UITapGestureRecognizer *singleTapRecognizer = [[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(viewWasTouched)] autorelease];
    [self.window addGestureRecognizer:singleTapRecognizer];
    [self drawSonar];
    [self startGenerationTimers];

  }else if (self.animationType == 4){
    self.backView = [[UIView alloc] initWithFrame:[UIScreen mainScreen].bounds];
    self.backView.backgroundColor = [UIColor clearColor];
    UITapGestureRecognizer *singleTapRecognizer = [[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(viewWasTouched)] autorelease];
    [self.window addGestureRecognizer:singleTapRecognizer];
    [self.window addSubview:self.backView];
    [self drawCube];
  }
}

- (void)drawBorderEffect{
  [[objc_getClass("SBNCScreenController") sharedSBNC] _turnOnScreen];
  if (self.isAlwaysOnFrequencyRunning){
    self.isAlwaysOnFrequencyRunning = NO;
    NSTimer *clearWindowTimer = [
                   NSTimer scheduledTimerWithTimeInterval: (6.1)
                   target: self
                   selector:@selector(clearWindowForNextFrequency)
                   userInfo: nil repeats:NO];
   [clearWindowTimer retain];
   [self.activeTimers addObject:clearWindowTimer];
 }
 BOOL rainbowEffectEnabled = NO;
 BOOL pulseEffectEnabled = [[self.preferences valueForKey:@"pulseBorderEnabled"] boolValue];

 if (!self.isAppSpecificColorEnabled){
  float redValue = [[self.preferences valueForKey:@"redAmount"] floatValue];
  float blueValue = [[self.preferences valueForKey:@"blueAmount"] floatValue];
  float greenValue = [[self.preferences valueForKey:@"greenAmount"] floatValue];
  rainbowEffectEnabled = [[self.preferences valueForKey:@"rainbowBorderEnabled"] boolValue];
  self.drawingColor = [UIColor colorWithRed:(redValue/255.0f) green:(greenValue/255.0f) blue:(blueValue/255.0f) alpha:1.0f];
 }else{
   if (self.shouldUpdateDrawingColor){
    UIImage *icon = [[ALApplicationList sharedApplicationList] iconOfSize:ALApplicationIconSizeLarge forDisplayIdentifier:self.bundleID];
    if (icon){
      NSMutableDictionary *colorInformation = [self mainColoursInImage:icon detail:1];
      self.drawingColor = [self applicationIconColor:colorInformation];
    }else{
      self.drawingColor = [UIColor whiteColor];
    }
   }
 }
 UIView *wayBackground = [[UIView alloc] initWithFrame:[UIScreen mainScreen].bounds];
 wayBackground.backgroundColor = [UIColor blackColor];
 [self.window addSubview:wayBackground];
 [wayBackground autorelease];

 self.backView = [[UIView alloc] initWithFrame:[UIScreen mainScreen].bounds];
 self.backView.backgroundColor = self.drawingColor;
 UITapGestureRecognizer *singleTap = [[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(viewWasTouched)]autorelease];
 [self.window addSubview:self.backView];
 [self.window addGestureRecognizer:singleTap];

 if (self.isIphoneX){
  UIView *myBox  = [[UIView alloc] initWithFrame:CGRectMake(10, 13, 355, 790)];
  myBox.backgroundColor = [UIColor blackColor];
  myBox.clipsToBounds = YES;
  myBox.layer.cornerRadius = 180/7.0f;
  myBox.layer.borderColor= [UIColor blackColor].CGColor;
  myBox.layer.borderWidth=1.0f;
  [self.window addSubview:myBox];

  self.topBox  = [[UIView alloc] initWithFrame:CGRectMake(73, -14, 230, 50)];
  self.topBox.clipsToBounds = YES;
  self.topBox.layer.cornerRadius = 180/8.0f;
  self.topBox.layer.borderColor= [UIColor clearColor].CGColor;
  self.topBox.layer.borderWidth=1.0f;
  self.topBox.backgroundColor = self.drawingColor;
  [self.window addSubview:self.topBox];
 }else{
   self.backView.backgroundColor = [UIColor blackColor];
   self.backView.layer.borderColor = self.drawingColor.CGColor;
   self.backView.layer.borderWidth = 12.0f;
 }

 if (rainbowEffectEnabled && !self.isAppSpecificColorEnabled) {

   [self rainbowEffectHandler];
   NSTimer *rainbowTimer = [
                   NSTimer scheduledTimerWithTimeInterval: (3.7f)
                   target: self
                   selector:@selector(rainbowEffectHandler)
                   userInfo: nil repeats:YES];
   [[NSRunLoop mainRunLoop] addTimer:rainbowTimer forMode:NSRunLoopCommonModes];
   [rainbowTimer retain];
   [self.activeTimers addObject:rainbowTimer];
 }

 if (pulseEffectEnabled){
  float pulsateValue = [[self.preferences valueForKey:@"borderPulsationRate"] floatValue];
  NSTimer *pulseTimer = [
                   NSTimer scheduledTimerWithTimeInterval: (1.0f / pulsateValue)
                   target: self
                   selector:@selector(pulsationEffectHandler)
                   userInfo: nil repeats:YES];
  [[NSRunLoop mainRunLoop] addTimer:pulseTimer forMode:NSRunLoopCommonModes];
  [pulseTimer retain];
  [self.activeTimers addObject:pulseTimer];
 }
}

- (void)pulsationEffectHandler{
  float pulsateValue = [[self.preferences valueForKey:@"borderPulsationRate"] floatValue];
  [UIView animateWithDuration:(0.5f/pulsateValue) animations:^{
      self.backView.layer.opacity = 0.0f;
      self.topBox.layer.opacity = 0.0f;
  } completion:^(BOOL finished){
    [UIView animateWithDuration:(0.5f/pulsateValue) animations:^{
        self.backView.layer.opacity = 1.0f;
        self.topBox.layer.opacity = 1.0f;
    } completion:NULL];
  }];

}

- (void)rainbowEffectHandler{
 if (self.isIphoneX){
  [UIView animateWithDuration:(0.6f) animations:^{
      if (self.isIphoneX){
        self.backView.layer.backgroundColor = [UIColor redColor].CGColor;
        self.topBox.layer.backgroundColor = [UIColor redColor].CGColor;
      }else{
        self.backView.layer.borderColor = [UIColor redColor].CGColor;
      }
  } completion:^(BOOL finished){
  [UIView animateWithDuration:(0.6f) animations:^{
      if (self.isIphoneX){
        self.backView.layer.backgroundColor = [UIColor orangeColor].CGColor;
        self.topBox.layer.backgroundColor = [UIColor orangeColor].CGColor;
      }else{
        self.backView.layer.borderColor = [UIColor orangeColor].CGColor;
      }
  } completion:^(BOOL finished){
    [UIView animateWithDuration:(0.6f) animations:^{
        if (self.isIphoneX){
          self.backView.layer.backgroundColor = [UIColor yellowColor].CGColor;
          self.topBox.layer.backgroundColor = [UIColor yellowColor].CGColor;
        }else{
          self.backView.layer.borderColor = [UIColor yellowColor].CGColor;
        }
    } completion:^(BOOL finished){
      [UIView animateWithDuration:(0.6f) animations:^{
          if (self.isIphoneX){
            self.backView.layer.backgroundColor = [UIColor greenColor].CGColor;
            self.topBox.layer.backgroundColor = [UIColor greenColor].CGColor;
          }else{
            self.backView.layer.borderColor = [UIColor greenColor].CGColor;
          }
      } completion:^(BOOL finished){
        [UIView animateWithDuration:(0.6f) animations:^{
            if (self.isIphoneX){
              self.backView.layer.backgroundColor = [UIColor blueColor].CGColor;
              self.topBox.layer.backgroundColor = [UIColor blueColor].CGColor;
            }else{
              self.backView.layer.borderColor = [UIColor blueColor].CGColor;
            }
        } completion:^(BOOL finished){
          [UIView animateWithDuration:(0.6f) animations:^{
              if (self.isIphoneX){
                self.backView.layer.backgroundColor = [UIColor purpleColor].CGColor;
                self.topBox.layer.backgroundColor = [UIColor purpleColor].CGColor;
              }else{
                self.backView.layer.borderColor = [UIColor purpleColor].CGColor;
              }
          } completion:^(BOOL finished){

          }];
        }];
      }];
    }];
  }];
 }];
 }else{
  [CATransaction begin];
  [CATransaction setCompletionBlock:^{
  [CATransaction begin];
    [CATransaction setCompletionBlock:^{
      [CATransaction begin];
      [CATransaction setCompletionBlock:^{
        [CATransaction begin];
        [CATransaction setCompletionBlock:^{
          [CATransaction begin];
          [CATransaction setCompletionBlock:^{
            UIColor *fromColor6 = [UIColor purpleColor];
            UIColor *toColor6 = [UIColor redColor];
            CABasicAnimation *colorAnimation6 = [CABasicAnimation animationWithKeyPath:@"borderColor"];
             colorAnimation6.duration =.6;
            colorAnimation6.removedOnCompletion = NO;
            colorAnimation6.fromValue = (id)fromColor6.CGColor;
            colorAnimation6.toValue = (id)toColor6.CGColor;
            colorAnimation6.fillMode = kCAFillModeForwards;
            [self.backView.layer addAnimation:colorAnimation6 forKey:@"borderColor"];
          }];
          UIColor *fromColor5 = [UIColor blueColor];
          UIColor *toColor5 = [UIColor purpleColor];
          CABasicAnimation *colorAnimation5 = [CABasicAnimation animationWithKeyPath:@"borderColor"];
           colorAnimation5.duration =.6;
          colorAnimation5.removedOnCompletion = NO;
          colorAnimation5.fromValue = (id)fromColor5.CGColor;
          colorAnimation5.toValue = (id)toColor5.CGColor;
          colorAnimation5.fillMode = kCAFillModeForwards;
          [self.backView.layer addAnimation:colorAnimation5 forKey:@"borderColor"];
          [CATransaction commit];
        }];
        UIColor *fromColor4 = [UIColor greenColor];
        UIColor *toColor4 = [UIColor blueColor];
        CABasicAnimation *colorAnimation4 = [CABasicAnimation animationWithKeyPath:@"borderColor"];
        colorAnimation4.duration =.6;
        colorAnimation4.removedOnCompletion = NO;
        colorAnimation4.fromValue = (id)fromColor4.CGColor;
        colorAnimation4.toValue = (id)toColor4.CGColor;
        colorAnimation4.fillMode = kCAFillModeForwards;
        [self.backView.layer addAnimation:colorAnimation4 forKey:@"borderColor"];
        [CATransaction commit];
      }];
      UIColor *fromColor3 = [UIColor yellowColor];
      UIColor *toColor3 = [UIColor greenColor];
      CABasicAnimation *colorAnimation3 = [CABasicAnimation animationWithKeyPath:@"borderColor"];
      colorAnimation3.duration = .6;
      colorAnimation3.fromValue = (id)fromColor3.CGColor;
      colorAnimation3.toValue = (id)toColor3.CGColor;
      colorAnimation3.removedOnCompletion = NO;
      colorAnimation3.fillMode = kCAFillModeForwards;
      [self.backView.layer addAnimation:colorAnimation3 forKey:@"borderColor"];
      [CATransaction commit];
    }];
     UIColor *fromColor2 = [UIColor orangeColor];
     UIColor *toColor2 = [UIColor yellowColor];
     CABasicAnimation *colorAnimation2 = [CABasicAnimation animationWithKeyPath:@"borderColor"];
     colorAnimation2.duration = .6;
     colorAnimation2.fromValue = (id)fromColor2.CGColor;
     colorAnimation2.toValue = (id)toColor2.CGColor;
     colorAnimation2.removedOnCompletion = NO;
     colorAnimation2.fillMode = kCAFillModeForwards;
     [self.backView.layer addAnimation:colorAnimation2 forKey:@"borderColor"];
     [CATransaction commit];
  }];
  UIColor *fromColor = [UIColor redColor];
  UIColor *toColor = [UIColor orangeColor];
  CABasicAnimation *colorAnimation = [CABasicAnimation animationWithKeyPath:@"borderColor"];
  colorAnimation.duration =.6;
  colorAnimation.removedOnCompletion = NO;
  colorAnimation.fromValue = (id)fromColor.CGColor;
  colorAnimation.toValue = (id)toColor.CGColor;
  colorAnimation.fillMode = kCAFillModeForwards;
  [self.backView.layer addAnimation:colorAnimation forKey:@"borderColor"];
  [CATransaction commit];
}
}

- (void)drawDots{
  [[objc_getClass("SBNCScreenController") sharedSBNC] _turnOnScreen];
  /*if (self.isAlwaysOnFrequencyRunning){
    NSLog(@"%@", @" h iiiiiiiiiiiiiiiiiiii-------------------");
     self.Index = 0;
     self.isAlwaysOnFrequencyRunning = NO;
     self.window = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
     self.window.windowLevel = 2000;
     self.window.backgroundColor = [UIColor clearColor];
     [self.window _setSecure: YES];
     [self.window makeKeyAndVisible];

     UIView *wayBackground = [[UIView alloc] initWithFrame:[UIScreen mainScreen].bounds];
     wayBackground.backgroundColor = [UIColor blackColor];
     [self.window addSubview:wayBackground];
     [wayBackground autorelease];

     UITapGestureRecognizer *singleTap = [[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(viewWasTouched)]autorelease];
     [self.window addSubview:wayBackground];
     [self.window addGestureRecognizer:singleTap];
   }*/
   [self startGenerationTimers];
   self.spawnTimer = [
                       NSTimer scheduledTimerWithTimeInterval: (.1)
                       target: self
                       selector:@selector(createDots)
                       userInfo: nil repeats:YES];
  [[NSRunLoop mainRunLoop] addTimer:self.spawnTimer forMode:NSRunLoopCommonModes];
  [self.activeTimers addObject:self.spawnTimer];

}

- (void)createDots{
    NSInteger standardSize = 36;
    if (self.isAppSpecificColorEnabled){
      if (self.shouldUpdateDrawingColor){
       UIImage *icon = [[ALApplicationList sharedApplicationList] iconOfSize:ALApplicationIconSizeLarge forDisplayIdentifier:self.bundleID];
       if (icon){
         NSMutableDictionary *colorInformation = [self mainColoursInImage:icon detail:1];
         self.drawingColor = [self applicationIconColor:colorInformation];
       }else{
         self.drawingColor = [UIColor whiteColor];
       }
      }
    }else{
      self.drawingColor = [UIColor orangeColor];
    }

    if (self.Index == 0){
      if (self.isIphoneX){
        self.xPosition = 175;
        self.xPosition2 = 180;
        self.yPosition = 25;
      }else{
        self.xPosition2 = (self.backView.center.x) - 10;
        self.xPosition = (self.backView.center.x) - 20;
        self.yPosition = 0;
      }
    }
  self.Index++;
  if (self.Index < 18 ){
   __block CAShapeLayer *circleLayer = [CAShapeLayer layer];
   [circleLayer setPath:[[UIBezierPath bezierPathWithOvalInRect:CGRectMake(self.xPosition2, (self.yPosition), standardSize, standardSize)] CGPath]];
   [circleLayer setFillColor:self.drawingColor.CGColor];
   circleLayer.opacity = .45f;
   [[self.window layer] addSublayer:circleLayer];

   __block CAShapeLayer *othercircleLayer = [CAShapeLayer layer];
   [othercircleLayer setPath:[[UIBezierPath bezierPathWithOvalInRect:CGRectMake(self.xPosition, (self.yPosition), standardSize, standardSize)] CGPath]];
   [othercircleLayer setFillColor:self.drawingColor.CGColor];
   othercircleLayer.opacity = .45f;
   [[self.window layer] addSublayer:othercircleLayer];


   CABasicAnimation *moveDown;
   moveDown            = [CABasicAnimation animationWithKeyPath:@"position.y"];
   moveDown.byValue    = @(-15.0f);
   moveDown.duration   = 2.0;
   moveDown.removedOnCompletion = NO;
   moveDown.fillMode   = kCAFillModeForwards;

   [CATransaction begin];
   [CATransaction setCompletionBlock:^{
        [CATransaction begin];
        [CATransaction setCompletionBlock:^{
          [circleLayer removeFromSuperlayer];
          [othercircleLayer removeFromSuperlayer];
          circleLayer = nil;
          othercircleLayer = nil;
        }];
         CABasicAnimation *colorAnimation3 = [CABasicAnimation animationWithKeyPath:@"opacity"];
         colorAnimation3.duration = .2;
         colorAnimation3.toValue =@(0.0f);
         colorAnimation3.fillMode = kCAFillModeForwards;
         colorAnimation3.removedOnCompletion = NO;
         if (circleLayer != nil && othercircleLayer != nil){
          [circleLayer addAnimation:colorAnimation3 forKey:@"opacity"];
          [othercircleLayer addAnimation:colorAnimation3 forKey:@"opacity"];
          [CATransaction commit];
        }
     }];
     [circleLayer addAnimation:moveDown forKey:@"y"];
     [othercircleLayer addAnimation:moveDown forKey:@"y"];
   [CATransaction commit];


   if (self.isAppSpecificColorEnabled){

   }else{
     [CATransaction begin];
     [CATransaction setCompletionBlock:^{
     UIColor *fromColor = [UIColor redColor];
     UIColor *toColor = [UIColor purpleColor];
     CABasicAnimation *colorAnimation2 = [CABasicAnimation animationWithKeyPath:@"fillColor"];
     colorAnimation2.duration = .9;
     colorAnimation2.fromValue = (id)fromColor.CGColor;
     colorAnimation2.toValue = (id)toColor.CGColor;
     colorAnimation2.removedOnCompletion = NO;
     colorAnimation2.fillMode = kCAFillModeForwards;
     [circleLayer addAnimation:colorAnimation2 forKey:@"fillColor"];
     [othercircleLayer addAnimation:colorAnimation2 forKey:@"fillColor"];

  }];
  UIColor *fromColor = [UIColor yellowColor];
  UIColor *toColor = [UIColor redColor];
  CABasicAnimation *colorAnimation = [CABasicAnimation animationWithKeyPath:@"fillColor"];
     colorAnimation.duration =.9;
  colorAnimation.removedOnCompletion = NO;
  colorAnimation.fromValue = (id)fromColor.CGColor;
  colorAnimation.toValue = (id)toColor.CGColor;
  colorAnimation.fillMode = kCAFillModeForwards;
  [circleLayer addAnimation:colorAnimation forKey:@"fillColor"];
  [othercircleLayer addAnimation:colorAnimation forKey:@"fillColor"];
  [CATransaction commit];
  }
     if (self.Index < 8){
       if (self.isIphoneX){
         self.xPosition = (self.xPosition - 10);
         self.xPosition2 = (self.xPosition2 + 10);
       }else{
         self.xPosition = (self.xPosition - 12);
         self.xPosition2 = (self.xPosition2 + 12);
       }
     }else{
       self.xPosition = (self.xPosition - 6);
       self.xPosition2 = (self.xPosition2 + 6);
       if (self.isIphoneX){
         self.xPosition = (self.xPosition - 6);
         self.xPosition2 = (self.xPosition2 + 6);
         self.yPosition = (self.yPosition - 5);
       }else{
         self.xPosition = (self.xPosition - 12);
         self.xPosition2 = (self.xPosition2 + 12);
       }
     }
  }else {
    self.Index = 0;
    if (self.spawnTimer != nil && [self.spawnTimer isValid]){
     [self.spawnTimer invalidate];
    }
     self.xPosition = 165;
     self.xPosition2 = 175;
     if (self.isIphoneX){
       self.yPosition = 25;
     }
  }


}

- (void)drawSonar{
  [[objc_getClass("SBNCScreenController") sharedSBNC] _turnOnScreen];
  if (self.isAlwaysOnFrequencyRunning){
    self.isAlwaysOnFrequencyRunning = NO;
    self.window = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
    self.window.windowLevel = 2000;
    [self.window _setSecure: YES];
    [self.window makeKeyAndVisible];

    UIView *wayBackground = [[UIView alloc] initWithFrame:[UIScreen mainScreen].bounds];
    wayBackground.backgroundColor = [UIColor blackColor];
    [self.window addSubview:wayBackground];
    [wayBackground autorelease];
    UITapGestureRecognizer *singleTap = [[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(viewWasTouched)]autorelease];
    [self.window addGestureRecognizer:singleTap];
    NSTimer *clearWindowTimer = [
                     NSTimer scheduledTimerWithTimeInterval: (7.7)
                     target: self
                     selector:@selector(clearWindowForNextFrequency)
                     userInfo: nil repeats:NO];
    [[NSRunLoop mainRunLoop] addTimer:clearWindowTimer forMode:NSRunLoopCommonModes];
    [clearWindowTimer retain];
    [self.activeTimers addObject:clearWindowTimer];
  }
  float redValue = [[self.preferences valueForKey:@"redAmount"] floatValue];
  float blueValue = [[self.preferences valueForKey:@"blueAmount"] floatValue];
  float greenValue = [[self.preferences valueForKey:@"greenAmount"] floatValue];
  BOOL colorSpecificEnabled = [[self.preferences valueForKey:@"colorSpecificEnabled"] boolValue];

  if (colorSpecificEnabled){
    if (self.shouldUpdateDrawingColor){
     UIImage *icon = [[ALApplicationList sharedApplicationList] iconOfSize:ALApplicationIconSizeLarge forDisplayIdentifier:self.bundleID];
     NSMutableDictionary *colorInformation = [self mainColoursInImage:icon detail:1];
     self.drawingColor = [self applicationIconColor:colorInformation];
    }
  }else{
    self.drawingColor =  [UIColor colorWithRed:(redValue/255.0f) green:(greenValue/255.0f) blue:(blueValue/255.0f) alpha:1.0f];
  }

    NSInteger screenX = (NSInteger) (floor(self.window.frame.size.width));
    NSInteger screenY = (NSInteger) (floor(self.window.frame.size.height));
    self.xPosition = (arc4random() % (screenX));
    self.yPosition = (arc4random() % (screenY));

  CGPoint circleCenter = CGPointMake(self.xPosition, self.yPosition);

  __block CAShapeLayer *circleLayer = [CAShapeLayer layer];
  circleLayer.bounds = CGRectMake((self.xPosition), (self.yPosition), 70, 70);
  [circleLayer setPath:[[UIBezierPath bezierPathWithOvalInRect:CGRectMake((self.xPosition), (self.yPosition), 70, 70)] CGPath]];
  [circleLayer setFillColor:[[UIColor clearColor] CGColor]];
  circleLayer.strokeColor = self.drawingColor.CGColor;
  circleLayer.opacity = .65f;
  circleLayer.position = circleCenter;
  [[self.window layer] addSublayer:circleLayer];

 __block CAShapeLayer *othercircleLayer = [CAShapeLayer layer];
 othercircleLayer.bounds = CGRectMake((self.xPosition), (self.yPosition), 70, 70);
 [othercircleLayer setPath:[[UIBezierPath bezierPathWithOvalInRect:CGRectMake((self.xPosition - 10), (self.yPosition - 10), 90, 90)] CGPath]];
 [othercircleLayer setFillColor:[[UIColor clearColor] CGColor]];
 othercircleLayer.strokeColor = self.drawingColor.CGColor;
 othercircleLayer.opacity = .65f;
 othercircleLayer.position = circleCenter;
 [[self.window layer] addSublayer:othercircleLayer];

 __block CAShapeLayer *othercircleLayer2 = [CAShapeLayer layer];
 othercircleLayer2.bounds = CGRectMake((self.xPosition), (self.yPosition), 70, 70);
 [othercircleLayer2 setPath:[[UIBezierPath bezierPathWithOvalInRect:CGRectMake((self.xPosition - 20), (self.yPosition - 20), 110, 110)] CGPath]];
 [othercircleLayer2 setFillColor:[[UIColor clearColor] CGColor]];
 othercircleLayer2.strokeColor = self.drawingColor.CGColor;
 othercircleLayer2.opacity = .65f;
 othercircleLayer2.position = circleCenter;
 [[self.window layer] addSublayer:othercircleLayer2];


 CABasicAnimation *scale = [CABasicAnimation animationWithKeyPath:@"transform.scale"];
 [scale setFromValue:[NSNumber numberWithFloat:1.0f]];
 [scale setToValue:[NSNumber numberWithFloat:6.0f]];
 scale.fillMode = kCAFillModeForwards;
 scale.removedOnCompletion = NO;
 [scale setRemovedOnCompletion:NO];
 [scale setDuration:3.8f];


 [CATransaction begin];
 [CATransaction setCompletionBlock:^{

  [CATransaction begin];
  [CATransaction setCompletionBlock:^{
    [circleLayer removeFromSuperlayer];
    [othercircleLayer removeFromSuperlayer];
    [othercircleLayer2 removeFromSuperlayer];
    circleLayer = nil;
    othercircleLayer = nil;
    othercircleLayer2 = nil;

  }];
  CABasicAnimation *colorAnimation3 = [CABasicAnimation animationWithKeyPath:@"opacity"];
  colorAnimation3.duration = .15;
  colorAnimation3.toValue =@(0.0f);
  colorAnimation3.fillMode = kCAFillModeForwards;
  colorAnimation3.removedOnCompletion = NO;
  [circleLayer addAnimation:colorAnimation3 forKey:@"opacity"];
  [othercircleLayer addAnimation:colorAnimation3 forKey:@"opacity"];
  [othercircleLayer2 addAnimation:colorAnimation3 forKey:@"opacity"];
  [CATransaction commit];


   }];
   [circleLayer addAnimation:scale forKey:@"transform.scale"];
   [othercircleLayer addAnimation:scale forKey:@"transform.scale"];
   [othercircleLayer2 addAnimation:scale forKey:@"transform.scale"];
 [CATransaction commit];


}

- (void)startGenerationTimers{
  if (self.animationType == 2){
    NSTimer *createDotsSetTimer  = [
                           NSTimer scheduledTimerWithTimeInterval: (2.9)
                           target: self
                           selector:@selector(drawDots)
                           userInfo: nil repeats:NO];
   [[NSRunLoop mainRunLoop] addTimer:createDotsSetTimer forMode:NSRunLoopCommonModes];
   [createDotsSetTimer retain];
   [self.activeTimers addObject:createDotsSetTimer];
 }else if (self.animationType == 3){
   NSTimer *createSonar  = [
                    NSTimer scheduledTimerWithTimeInterval: (4.1)
                    target: self
                    selector:@selector(drawSonar)
                    userInfo: nil repeats:YES];
  [[NSRunLoop mainRunLoop] addTimer:createSonar forMode:NSRunLoopCommonModes];
  [createSonar retain];
  [self.activeTimers addObject:createSonar];
 }
}

- (void)drawCube{
  [[objc_getClass("SBNCScreenController") sharedSBNC] _turnOnScreen];
  self.window.backgroundColor = [UIColor clearColor];
  if (self.shouldUpdateDrawingColor){
   UIImage *icon = [[ALApplicationList sharedApplicationList] iconOfSize:ALApplicationIconSizeLarge forDisplayIdentifier:self.bundleID];
   if (icon){
     NSMutableDictionary *colorInformation = [self mainColoursInImage:icon detail:1];
     self.drawingColor = [self applicationIconColor:colorInformation];
   }else{
     self.drawingColor = [UIColor whiteColor];
   }
  }

  self.scene = [SCNScene scene];

  float boxEdge = .5;
  float boxDimension = 6.5;
  SCNBox *box = [SCNBox boxWithWidth:(boxDimension) height:boxDimension length:boxDimension chamferRadius:boxEdge];
  SCNNode *boxNode = [SCNNode nodeWithGeometry:box];
  boxNode.position = SCNVector3Make(0, (0), 0);
  SCNBox *backBox = [SCNBox boxWithWidth:(boxDimension - .01) height:(boxDimension) length:(boxDimension - .01) chamferRadius:boxEdge];
  SCNNode *backBoxNode = [SCNNode nodeWithGeometry:backBox];
  backBoxNode.position = SCNVector3Make(0, 0, 0);


  SCNMaterial *colorMaterial              = [SCNMaterial material];
  colorMaterial.doubleSided                = YES;
  colorMaterial.diffuse.contents            = self.drawingColor;
  colorMaterial.locksAmbientWithDiffuse     = NO;

  SCNMaterial *appIconMaterial              = [SCNMaterial material];
  appIconMaterial.doubleSided                = YES;
  UIImage *icon = [[ALApplicationList sharedApplicationList] iconOfSize:ALApplicationIconSizeLarge forDisplayIdentifier:self.bundleID];
  appIconMaterial.diffuse.contents            = icon;
  appIconMaterial.locksAmbientWithDiffuse     = NO;
  //appIconMaterial.diffuse.contentsTransform = SCNMatrix4MakeScale(1.3, 1.6, 2);

  box.materials = @[appIconMaterial, appIconMaterial, appIconMaterial, appIconMaterial, colorMaterial, colorMaterial, colorMaterial, colorMaterial];
  backBox.materials = @[colorMaterial];

  boxNode.geometry.firstMaterial.doubleSided = YES;

  [self.scene.rootNode addChildNode:boxNode];
  [self.scene.rootNode addChildNode:backBoxNode];


  SCNNode *cameraNode = [SCNNode node];
  cameraNode.camera = [SCNCamera camera];
  cameraNode.position = SCNVector3Make(0, -6, 20);
  cameraNode.rotation = SCNVector4Make(.5, 0, 0, M_PI/12);
  [self.scene.rootNode addChildNode:cameraNode];

  SCNNode *lightNode = [SCNNode node];
  lightNode.light = [SCNLight light];
  lightNode.light.type = SCNLightTypeOmni;
  lightNode.position = SCNVector3Make(0, -6, 20);
  cameraNode.rotation = SCNVector4Make(.5, 0, 0, M_PI/12);
  [self.scene.rootNode addChildNode:lightNode];

  SCNNode *ambientLightNode = [SCNNode node];
  ambientLightNode.light = [SCNLight light];
  ambientLightNode.light.type = SCNLightTypeAmbient;
  ambientLightNode.light.color = [UIColor blackColor];
  [self.scene.rootNode addChildNode:ambientLightNode];

  SCNView *scnView = [[SCNView alloc] initWithFrame:[UIScreen mainScreen].bounds options:nil];
  scnView.scene = [self scene];
  scnView.backgroundColor = [UIColor blackColor];
  [self.backView addSubview:scnView];

  [backBoxNode runAction:[SCNAction repeatActionForever:[SCNAction rotateByX:0 y:.5 z:0 duration:.5]] forKey:@"rotate"];
  [boxNode runAction:[SCNAction repeatActionForever:[SCNAction rotateByX:0 y:.5 z:0 duration:.5]] forKey:@"rotate"];
}

- (void)reDrawCube{
  if (self.shouldUpdateDrawingColor){
   UIImage *icon = [[ALApplicationList sharedApplicationList] iconOfSize:ALApplicationIconSizeLarge forDisplayIdentifier:self.bundleID];
   if (icon){
     NSMutableDictionary *colorInformation = [self mainColoursInImage:icon detail:1];
     self.drawingColor = [self applicationIconColor:colorInformation];
   }else{
     self.drawingColor = [UIColor whiteColor];
   }
  }
  for (SCNNode *node in [self.scene.rootNode childNodes]) {
    if (node.camera == nil && node.light == nil){
      node.geometry = nil;
      [node removeActionForKey:@"rotate"];
      [node removeFromParentNode];
      //[node release];
      node = nil;
    }
  }

  float boxEdge = .5;
  float boxDimension = 6.5;
  SCNBox *box = [SCNBox boxWithWidth:(boxDimension) height:boxDimension length:boxDimension chamferRadius:boxEdge];
  SCNNode *boxNode = [SCNNode nodeWithGeometry:box];
  boxNode.position = SCNVector3Make(0, (0), 0);
  SCNBox *backBox = [SCNBox boxWithWidth:(boxDimension - .01) height:(boxDimension) length:(boxDimension - .01) chamferRadius:boxEdge];
  SCNNode *backBoxNode = [SCNNode nodeWithGeometry:backBox];
  backBoxNode.position = SCNVector3Make(0, 0, 0);


  SCNMaterial *colorMaterial              = [SCNMaterial material];
  colorMaterial.doubleSided                = YES;
  colorMaterial.diffuse.contents            = self.drawingColor;
  colorMaterial.locksAmbientWithDiffuse     = NO;

  SCNMaterial *appIconMaterial              = [SCNMaterial material];
  appIconMaterial.doubleSided                = YES;
  UIImage *icon = [[ALApplicationList sharedApplicationList] iconOfSize:ALApplicationIconSizeLarge forDisplayIdentifier:self.bundleID];
  appIconMaterial.diffuse.contents            = icon;
  appIconMaterial.locksAmbientWithDiffuse     = NO;
  //appIconMaterial.diffuse.contentsTransform = SCNMatrix4MakeScale(1.3, 1.6, 2);

  box.materials = @[appIconMaterial, appIconMaterial, appIconMaterial, appIconMaterial, colorMaterial, colorMaterial, colorMaterial, colorMaterial];
  backBox.materials = @[colorMaterial];

  boxNode.geometry.firstMaterial.doubleSided = YES;

  [self.scene.rootNode addChildNode:boxNode];
  [self.scene.rootNode addChildNode:backBoxNode];

  [backBoxNode runAction:[SCNAction repeatActionForever:[SCNAction rotateByX:0 y:.5 z:0 duration:.5]] forKey:@"rotate"];
  [boxNode runAction:[SCNAction repeatActionForever:[SCNAction rotateByX:0 y:.5 z:0 duration:.5]] forKey:@"rotate"];

}

- (void)viewWasTouched{
  [self clearWindow];
  [self haltTimers];
  self.isAlwaysOnFrequencyRunning = NO;
  self.isNotifying = NO;
  self.Index = 19;
}

- (void)clearWindow{
  self.backView.layer.borderColor = [UIColor blackColor].CGColor;
  [self.window.layer removeAllAnimations];
  NSEnumerator *enumerator = [self.window.layer.sublayers reverseObjectEnumerator];
  for (CAShapeLayer *layer in enumerator) {
    if (layer && layer != nil && [layer class] == NSClassFromString(@"CAShapeLayer")){
      layer.strokeColor = [UIColor clearColor].CGColor;
      layer.opacity = 0.0f;
      [layer removeAllAnimations];
      layer.strokeColor = [UIColor clearColor].CGColor;
      layer.opacity = 0.0f;
    }
  }
  if (self.scene){
    dispatch_async(dispatch_get_main_queue(), ^{
      for (SCNNode *node in [self.scene.rootNode childNodes]) {
        node.geometry = nil;
        [node removeActionForKey:@"rotate"];
        [node removeFromParentNode];
        //[node release];
        node = nil;
      }
      if ([self.backView.subviews count] > 0){
        for (SCNView *b in self.backView.subviews){
          if ([b class] == NSClassFromString(@"SCNView")){
            [b removeFromSuperview];
            [b release];
          }
        }
      }
   });
  }
  [self.backView.layer removeAllAnimations];

  [UIView animateWithDuration:0.25f animations:^{
    [self.window setAlpha:0.0f];
  } completion:^(BOOL finished) {
   [self cancelAnimations];
   self.window.hidden = YES;
   [self.window release];
   self.window = nil;
  }];
  [UIView animateWithDuration:(0.3f) animations:^{
   self.backView.backgroundColor = [UIColor blackColor];
   self.topBox.backgroundColor = [UIColor blackColor];
   self.backView.layer.opacity = 0.0f;
   self.topBox.layer.opacity = 0.0f;
  } completion:^(BOOL finished){
  if (self.backView){
  //[self.scene release];
   self.scene = nil;
   [self.backView release];
   self.backView = nil;
  }
  if (self.topBox){
   [self.topBox release];
   self.topBox = nil;
  }
  }];
}

- (void)cancelAnimations{

  /*if ([self.scene.rootNode.childNodes count] > 0){
    for (SCNNode *node in [b.scene.rootNode childNodes]) {
      if (node != nil && node != NULL){
        [node removeActionForKey:@"rotate"];
        [node removeFromParentNode];
        [node release];
        node = nil;
        NSLog(@"%@ : ------------------MADE IT HERE", node);
      }
    }
  }*/
  /*
  for (int i = ([self.addedSubLayers count] - 1); i >= 0; i--){
    CAShapeLayer *temp = self.addedSubLayers[i];
    if (temp != nil){
      [temp removeAllAnimations];
      [self.addedSubLayers makeObjectsPerformSelector:@selector(removeFromSuperlayer)];
      [self.addedSubLayers removeObjectAtIndex:i];
    }
  }
  */
}

- (void)haltTimers{
  for (int i = ([self.activeTimers count] - 1); i >= 0; i--){
    NSTimer *temp = self.activeTimers[i];
    if (temp != nil && [temp isValid]){
      if (temp == self.alwaysOnFrequencyTimer && self.isAlwaysOnFrequencyRunning){

      }else{
        [temp invalidate];
        temp = nil;
        [self.activeTimers removeObjectAtIndex:i];
      }
    }
  }

}

- (void)clearWindowForNextFrequency{
  [self haltTimers];
  self.Index = 19;
  self.backView.layer.borderColor = [UIColor blackColor].CGColor;
  [self.window.layer removeAllAnimations];
  self.backView.backgroundColor = [UIColor blackColor];
  [UIView animateWithDuration:0.25f animations:^{
    self.window.layer.backgroundColor = [UIColor blackColor].CGColor;
  } completion:^(BOOL finished) {
    self.window.hidden = YES;
    self.window = nil;
  }];
  [[objc_getClass("SBBacklightController") sharedInstance] _startFadeOutAnimationFromLockSource:1];
}

- (NSMutableDictionary *)mainColoursInImage:(UIImage *)image detail:(int)detail {
 float dimension = 8;
 float flexibility = 2;
 float range = 100;

 if (detail == 1){
    dimension = 4;
    flexibility = 1;
    range = 150;
 } else if (detail == 2) {
    dimension = 25;
    flexibility = 10;
    range = 20;
 }

 NSMutableArray * colours = [NSMutableArray new];
 CGImageRef imageRef = [image CGImage];
 CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
 unsigned char *rawData = (unsigned char*) calloc(dimension * dimension * 4, sizeof(unsigned char));
 NSUInteger bytesPerPixel = 4;
 NSUInteger bytesPerRow = bytesPerPixel * dimension;
 NSUInteger bitsPerComponent = 8;
 CGContextRef context = CGBitmapContextCreate(rawData, dimension, dimension, bitsPerComponent, bytesPerRow, colorSpace, kCGImageAlphaPremultipliedLast | kCGBitmapByteOrder32Big);
 CGColorSpaceRelease(colorSpace);
 CGContextDrawImage(context, CGRectMake(0, 0, dimension, dimension), imageRef);
 CGContextRelease(context);

 float x = 0;
 float y = 0;
 for (int n = 0; n<(dimension*dimension); n++){

    int index = (bytesPerRow * y) + x * bytesPerPixel;
    int red   = rawData[index];
    int green = rawData[index + 1];
    int blue  = rawData[index + 2];
    int alpha = rawData[index + 3];
    NSMutableArray * a = [NSMutableArray arrayWithObjects:[NSString stringWithFormat:@"%i",red],[NSString stringWithFormat:@"%i",green],[NSString stringWithFormat:@"%i",blue],[NSString stringWithFormat:@"%i",alpha], nil];
    [colours addObject:a];

    y++;
    if (y==dimension){
        y=0;
        x++;
    }
 }
 free(rawData);

 NSMutableArray * copyColours = [NSMutableArray arrayWithArray:colours];
 NSMutableArray * flexibleColours = [NSMutableArray new];

 float flexFactor = flexibility * 2 + 1;
 float factor = flexFactor * flexFactor * 3; //(r,g,b) == *3
 for (int n = 0; n<(dimension * dimension); n++){

    NSMutableArray * pixelColours = copyColours[n];
    NSMutableArray * reds = [NSMutableArray new];
    NSMutableArray * greens = [NSMutableArray new];
    NSMutableArray * blues = [NSMutableArray new];

    for (int p = 0; p<3; p++){

        NSString * rgbStr = pixelColours[p];
        int rgb = [rgbStr intValue];

        for (int f = -flexibility; f<flexibility+1; f++){
            int newRGB = rgb+f;
            if (newRGB<0){
                newRGB = 0;
            }
            if (p==0){
                [reds addObject:[NSString stringWithFormat:@"%i",newRGB]];
            } else if (p==1){
                [greens addObject:[NSString stringWithFormat:@"%i",newRGB]];
            } else if (p==2){
                [blues addObject:[NSString stringWithFormat:@"%i",newRGB]];
            }
        }
    }

    int r = 0;
    int g = 0;
    int b = 0;
    for (int k = 0; k<factor; k++){

        int red = [reds[r] intValue];
        int green = [greens[g] intValue];
        int blue = [blues[b] intValue];

        NSString * rgbString = [NSString stringWithFormat:@"%i,%i,%i",red,green,blue];
        [flexibleColours addObject:rgbString];

        b++;
        if (b==flexFactor){ b=0; g++; }
        if (g==flexFactor){ g=0; r++; }
    }
 }
 NSMutableDictionary * colourCounter = [NSMutableDictionary new];

 NSCountedSet *countedSet = [[NSCountedSet alloc] initWithArray:flexibleColours];
 for (NSString *item in countedSet) {
    NSUInteger count = [countedSet countForObject:item];
    [colourCounter setValue:[NSNumber numberWithInteger:count] forKey:item];
 }

 NSArray *orderedKeys1 = [colourCounter keysSortedByValueUsingComparator:^NSComparisonResult(id obj1, id obj2){
    return [obj2 compare:obj1];
 }];

 NSMutableArray *orderedKeys = [orderedKeys1 mutableCopy];
 NSMutableArray * ranges = [NSMutableArray new];
 for (NSString * key in orderedKeys){
    NSArray *rgb1 = [key componentsSeparatedByString:@","];
    NSMutableArray *rgb = [rgb1 mutableCopy];
    int r = [rgb[0] intValue];
    int g = [rgb[1] intValue];
    int b = [rgb[2] intValue];
    bool exclude = false;
    for (NSString * ranged_key in ranges){
        NSArray * ranged_rgb1 = [ranged_key componentsSeparatedByString:@","];
        NSMutableArray *ranged_rgb = [ranged_rgb1 mutableCopy];

        int ranged_r = [ranged_rgb[0] intValue];
        int ranged_g = [ranged_rgb[1] intValue];
        int ranged_b = [ranged_rgb[2] intValue];

        if (r>= ranged_r-range && r<= ranged_r+range){
            if (g>= ranged_g-range && g<= ranged_g+range){
                if (b>= ranged_b-range && b<= ranged_b+range){
                    exclude = true;
                }
            }
        }
    }

    if (!exclude){ [ranges addObject:key]; }
 }

 NSMutableArray * colourArray = [NSMutableArray new];
 for (NSString * key in ranges){
    NSArray * rgb1 = [key componentsSeparatedByString:@","];
    NSMutableArray *rgb = [rgb1 mutableCopy];
    float r = [rgb[0] floatValue];
    float g = [rgb[1] floatValue];
    float b = [rgb[2] floatValue];
    UIColor * colour = [UIColor colorWithRed:(r/255.0f) green:(g/255.0f) blue:(b/255.0f) alpha:1.0f];
    [colourArray addObject:colour];
 }
 return [NSMutableDictionary dictionaryWithObject:colourArray forKey:@"colours"];

}

- (UIColor *)applicationIconColor:(NSMutableDictionary *)colorInformation{
  UIColor *determinedColor = [UIColor whiteColor];
  NSMutableArray *returnedColors = [colorInformation valueForKeyPath:@"colours"];
  if (returnedColors && [returnedColors count]) {
  for (int n = 0; n <= (((sizeof returnedColors) / (sizeof returnedColors[0])) + 1); n++){
      CGFloat red = 0.0, green = 0.0, blue = 0.0, alpha =0.0;
      UIColor *testingColor = returnedColors[n];
      [testingColor getRed:&red green:&green blue:&blue alpha:&alpha];
      if ((red <= 0.1) && (green <= 0.1) && (blue <= 0.1)){
        if (n == ((sizeof returnedColors) / (sizeof returnedColors[0]))){
          determinedColor = [UIColor whiteColor];
        }
      }else if ((red >= .75) && (blue >= .75) && (green >= .75)){
        if (n == (sizeof returnedColors) / (sizeof returnedColors[0])){
          determinedColor = [UIColor whiteColor];
        }
      }else {
        determinedColor = testingColor;
      }
      if (determinedColor != [UIColor whiteColor]) {
        break;
      }
  }
  return determinedColor;
 }else {
   return [UIColor whiteColor];
 }
}

- (void)updateDrawingColor:(NSString *)withBundle{
  if (self.bundleID != withBundle && self.isAppSpecificColorEnabled){
    self.shouldUpdateDrawingColor = YES;
    self.bundleID = withBundle;
    //UIImage *icon = [[ALApplicationList sharedApplicationList] iconOfSize:ALApplicationIconSizeLarge forDisplayIdentifier:self.bundleID];
    SBApplication *app = [[%c(SBApplicationController) sharedInstance] applicationWithDisplayIdentifier:withBundle];
    SBApplicationIcon *appIcon = [[%c(SBApplicationIcon) alloc] initWithApplication:mailApp];
    UIImage *icon = MSHookIvar<UIImage *>(appIcon, "_cachedSquareHomeScreenContentsImage");
    if (self.animationType == 1){
      if (self.isIphoneX){
        if (icon){
          NSMutableDictionary *colorInformation = [self mainColoursInImage:icon detail:1];
          self.drawingColor = [self applicationIconColor:colorInformation];
          self.topBox.backgroundColor = self.drawingColor;
          self.backView.backgroundColor = self.drawingColor;
        }else{
          self.drawingColor = [UIColor whiteColor];
        }
      }else{
        if (icon){
          NSMutableDictionary *colorInformation = [self mainColoursInImage:icon detail:1];
          self.drawingColor = [self applicationIconColor:colorInformation];
          self.backView.layer.borderColor = self.drawingColor.CGColor;
        }else{
          self.drawingColor = [UIColor whiteColor];
          self.backView.layer.borderColor = self.drawingColor.CGColor;
        }
      }
    }else if (self.animationType == 4){
      [self reDrawCube];
    }
  }
}

- (void)startAlwaysOnFrequencyTimer:(NSTimer *)withTimer {
  [withTimer retain];
  [[NSRunLoop mainRunLoop] addTimer:withTimer forMode:NSDefaultRunLoopMode];
  [self.activeTimers addObject:withTimer];
  self.isAlwaysOnFrequencyRunning = YES;
  self.alwaysOnFrequencyTimer = withTimer;
}

@end
