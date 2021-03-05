#import <UIKit/UIWindow+Private.h>
#import <UIKit/UIKit.h>
#import <CoreGraphics/CoreGraphics.h>
#import <QuartzCore/QuartzCore.h>
#import <sys/utsname.h>
#import <AppList/AppList.h>
#import <objc/runtime.h>
#import <SceneKit/SceneKit.h>

@class CustomAlertViewController;

@interface CustomAlertViewController : UIViewController

@property (nonatomic) BOOL isAlwaysOn;
@property (nonatomic) BOOL shouldUpdateDrawingColor;
@property (nonatomic) BOOL isRainbowEnabled;
@property (nonatomic) BOOL isPulsationEnabled;
@property (nonatomic) BOOL isIphoneX;
@property (nonatomic) BOOL isNotifying;
@property (nonatomic) BOOL isAlwaysOnFrequencyRunning;
@property (nonatomic) BOOL isAppSpecificColorEnabled;
@property (nonatomic) int animationType;
@property (nonatomic) NSInteger xPosition;
@property (nonatomic) NSInteger xPosition2;
@property (nonatomic) NSInteger yPosition;
@property (nonatomic) NSInteger Index;
@property (nonatomic) float alwaysOnFrequency;
@property (nonatomic, retain) UIColor *drawingColor;
@property (nonatomic, retain) UIWindow *window;
@property (nonatomic, retain) UIView *topBox;
@property (nonatomic, retain) UIView *backView;
@property (nonatomic, retain) NSTimer *spawnTimer;
@property (nonatomic, retain) NSTimer *__strong alwaysOnFrequencyTimer;
@property (nonatomic, retain) NSMutableDictionary *colorInformation;
@property (nonatomic, retain) NSMutableDictionary *preferences;
@property (nonatomic, retain) NSMutableArray *activeTimers;
@property (nonatomic, retain) NSString *bundleID;
@property (nonatomic, retain) SCNScene *scene;


- (void)initWithConfiguration:(NSMutableDictionary *)preferences isXDevice:(BOOL)device withWidow:(UIWindow *)window fromApp:(NSString *)bundleID;
- (void)handleAnimationStart;
- (void)startGenerationTimers;
- (void)rainbowEffectHandler;
- (void)pulsationEffectHandler;
- (void)haltTimers;
- (void)viewWasTouched;
- (void)clearWindowForNextFrequency;
- (void)clearWindow;
- (void)drawBorderEffect;
- (void)drawDots;
- (void)createDots;
- (void)drawSonar;
- (void)drawCube;
- (void)reDrawCube;
- (void)cancelAnimations;
- (void)startAlwaysOnFrequencyTimer:(NSTimer *)withTimer;
- (void)updateDrawingColor:(NSString *)withBundle;
- (NSMutableDictionary *)mainColoursInImage:(UIImage *)image detail:(int)detail;
- (UIColor *)applicationIconColor:(NSMutableDictionary *)colorInformation;

@end
