//
//  AppDelegate.m
//  AnyJSON Demo
//
//  Created by Cédric Luthi on 18.11.12.
//

#import "AppDelegate.h"

#import "DemoViewController.h"

@implementation AppDelegate

@synthesize window = _window;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    self.window.rootViewController = [[DemoViewController alloc] init];
    [self.window makeKeyAndVisible];
    return YES;
}

@end
