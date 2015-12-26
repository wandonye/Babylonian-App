//
// Copyright (c) 2015 Related Code - http://relatedcode.com
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.

#import <Parse/Parse.h>
#import <FBSDKCoreKit/FBSDKCoreKit.h>
#import <ParseFacebookUtilsV4/PFFacebookUtils.h>
#import <ParseTwitterUtils/ParseTwitterUtils.h>
#import "CLLocation+Utils.h"

#import "AppConstant.h"
#import "common.h"

#import "AppDelegate.h"
#import "RecentView.h"
//#import "GroupsView.h"
#import "PeopleView.h"
#import "SettingsView.h"
#import "NavigationController.h"
#import "Babylonian-Swift.h"

@implementation AppDelegate

//------------------------------------------------------

NSString * const NotificationCategoryIdent  = @"ACTIONABLE";
NSString * const NotificationActionOneIdent = @"ACTION_YES";
NSString * const NotificationActionTwoIdent = @"ACTION_NO";


//---------------------------------------------------------------------------------------------------
- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
//---------------------------------------------------------------------------------------------------
{
	[Parse setApplicationId:@"iZBQhKLvStLDiflpBDUy1NTMhfa6I8aHNa35J0Cz" clientKey:@"fNoS5g5FhRKO0Ul6aKt7ISJkqljwkCqSSQK3GwST"];
	//---------------------------------------------------------------------------------------------------------------------------------------------
	[PFTwitterUtils initializeWithConsumerKey:@"kS83MvJltZwmfoWVoyE1R6xko" consumerSecret:@"YXSupp9hC2m1rugTfoSyqricST9214TwYapQErBcXlP1BrSfND"];
	//---------------------------------------------------------------------------------------------------------------------------------------------
	[PFFacebookUtils initializeFacebookWithApplicationLaunchOptions:nil];
	//-----------------------------------------------------------------------------------------------------
    self.transStatus = APP_TRANS_STATUS_LIMBO;
    
    if ([application respondsToSelector:@selector(registerUserNotificationSettings:)])
	{
        
		UIUserNotificationType userNotificationTypes = (UIUserNotificationTypeAlert | UIUserNotificationTypeBadge | UIUserNotificationTypeSound);
		UIUserNotificationSettings *settings = [UIUserNotificationSettings settingsForTypes:userNotificationTypes categories:nil];
		[application registerUserNotificationSettings:settings];
		[application registerForRemoteNotifications];
        /*
        UIMutableUserNotificationAction *action1;
        action1 = [[UIMutableUserNotificationAction alloc] init];
        [action1 setActivationMode:UIUserNotificationActivationModeBackground];
        [action1 setTitle:@"Accept"];
        [action1 setIdentifier:NotificationActionOneIdent];
        [action1 setDestructive:NO];
        [action1 setAuthenticationRequired:NO];
        
        UIMutableUserNotificationAction *action2;
        action2 = [[UIMutableUserNotificationAction alloc] init];
        [action2 setActivationMode:UIUserNotificationActivationModeBackground];
        [action2 setTitle:@"Reject"];
        [action2 setIdentifier:NotificationActionTwoIdent];
        [action2 setDestructive:NO];
        [action2 setAuthenticationRequired:NO];
        
        UIMutableUserNotificationCategory *actionCategory;
        actionCategory = [[UIMutableUserNotificationCategory alloc] init];
        [actionCategory setIdentifier:NotificationCategoryIdent];
        [actionCategory setActions:@[action1, action2]
                        forContext:UIUserNotificationActionContextDefault];
        
        NSSet *categories = [NSSet setWithObject:actionCategory];
        UIUserNotificationType types = (UIUserNotificationTypeAlert|
                                        UIUserNotificationTypeSound|
                                        UIUserNotificationTypeBadge);
        
        UIUserNotificationSettings *settings;
        settings = [UIUserNotificationSettings settingsForTypes:types
                                                     categories:categories];
        
        [application registerUserNotificationSettings:settings];
        [application registerForRemoteNotifications];
         */
	}
	//-----------------------------------------------------------------------------------------------------
	self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    
    self.transView = [[TranslateTabView alloc] initWithNibName:@"TranslateTabView" bundle:nil];
    self.recentView = [[RecentView alloc] initWithNibName:@"RecentView" bundle:nil];
	//self.leaderboardView = [[LeaderBoardView alloc] initWithNibName:nil bundle:nil];
	self.peopleView = [[PeopleView alloc] initWithNibName:@"PeopleView" bundle:nil];
	self.settingsView = [[SettingsView alloc] initWithNibName:@"SettingsView" bundle:nil];

	NavigationController *navController1 = [[NavigationController alloc] initWithRootViewController:self.transView];
    NavigationController *navController3 = [[NavigationController alloc] initWithRootViewController:self.recentView];
	NavigationController *navController4 = [[NavigationController alloc] initWithRootViewController:self.peopleView];
	NavigationController *navController5 = [[NavigationController alloc] initWithRootViewController:self.settingsView];

	self.tabBarController = [[UITabBarController alloc] init];
	self.tabBarController.viewControllers = @[navController1, navController3, navController4, navController5];
	self.tabBarController.tabBar.translucent = NO;

	self.tabBarController.selectedIndex = DEFAULT_TAB;

	self.window.rootViewController = self.tabBarController;
	[self.window makeKeyAndVisible];
	//----------------------------------------------------------------------------------------------
	[self.recentView view];
	[self.transView view];
    [self.peopleView view];
	[self.settingsView view];
	//---------------------------------------------------------------------------------------------------
	return YES;
}

//---------------------------------------------------------------------------------------------------
- (void)applicationWillResignActive:(UIApplication *)application
//---------------------------------------------------------------------------------------------------
{
	
}

//---------------------------------------------------------------------------------------------------
- (void)applicationDidEnterBackground:(UIApplication *)application
//---------------------------------------------------------------------------------------------------
{
    //last active time
    PFUser *user = [PFUser currentUser];
    user[PF_USER_LASTACTIVE] = [NSDate date];
    [user saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error)
     {
         if (error != nil)
         {
             //[self loginFailed:@"Failed to save user data."];
         }
     }];
	
}

//---------------------------------------------------------------------------------------------------
- (void)applicationWillEnterForeground:(UIApplication *)application
//---------------------------------------------------------------------------------------------------
{

}

//---------------------------------------------------------------------------------------------------
- (void)applicationDidBecomeActive:(UIApplication *)application
//---------------------------------------------------------------------------------------------------
{
	[FBSDKAppEvents activateApp];
	PostNotification(NOTIFICATION_APP_STARTED);
	[self locationManagerStart];
}

//---------------------------------------------------------------------------------------------------
- (void)applicationWillTerminate:(UIApplication *)application
//---------------------------------------------------------------------------------------------------
{

}

#pragma mark - Facebook responses

//---------------------------------------------------------------------------------------------------
- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation
//---------------------------------------------------------------------------------------------------
{
	return [[FBSDKApplicationDelegate sharedInstance] application:application openURL:url sourceApplication:sourceApplication annotation:annotation];
}

#pragma mark - Push notification methods

//---------------------------------------------------------------------------------------------------
- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken
//---------------------------------------------------------------------------------------------------
{
	PFInstallation *currentInstallation = [PFInstallation currentInstallation];
	[currentInstallation setDeviceTokenFromData:deviceToken];
	[currentInstallation saveInBackground];
}

//---------------------------------------------------------------------------------------------------
- (void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error
//--------------------------------------------------------------------------------------------------------
{
	//NSLog(@"didFailToRegisterForRemoteNotificationsWithError %@", error);
}
//---------------------------------------------------------------------------------------------------
- (void)application:(UIApplication *)application handleActionWithIdentifier:(NSString *)identifier forRemoteNotification:(NSDictionary *)userInfo completionHandler:(void(^)())completionHandler {
//--------------------------------------------------------------------------------------------------------
    
    // Handle actions of remote notifications here. You can identify the action by using "identifier" and perform appropriate operations
    if ([identifier isEqualToString:NotificationActionOneIdent]) {
        
        NSLog(@"Friend request accepted.");
        
        
    }
    else if ([identifier isEqualToString:NotificationActionTwoIdent]) {
        
        NSLog(@"Friend request rejected.");
        
    }

    
    if(completionHandler != nil)    //Finally call completion handler if its not nil
        completionHandler();
}
//---------------------------------------------------------------------------------------------------
- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo
//---------------------------------------------------------------------------------------------------
{
    //
}


#pragma mark - Location manager methods

//---------------------------------------------------------------------------------------------------
- (void)locationManagerStart
//---------------------------------------------------------------------------------------------------
{
	if (self.locationManager == nil)
	{
		self.locationManager = [[CLLocationManager alloc] init];
		[self.locationManager setDelegate:self];
		[self.locationManager setDesiredAccuracy:kCLLocationAccuracyBest];
        if ([self.locationManager respondsToSelector:@selector(requestWhenInUseAuthorization)]) {
            [self.locationManager requestWhenInUseAuthorization];
        }
	}
	[self.locationManager startUpdatingLocation];
}

//---------------------------------------------------------------------------------------------------
- (void)locationManagerStop
//---------------------------------------------------------------------------------------------------
{
	[self.locationManager stopUpdatingLocation];
}

#pragma mark - CLLocationManagerDelegate

//---------------------------------------------------------------------------------------------------
- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation
//---------------------------------------------------------------------------------------------------
{
	self.coordinate = newLocation.coordinate;
	//----------------------------------------------------------------------------------------------------
	PFUser *user = [PFUser currentUser];
	if (user != nil)
	{
		PFGeoPoint *geoPoint = user[PF_USER_LOCATION];
		CLLocation *locationUser = [[CLLocation alloc] initWithLatitude:geoPoint.latitude longitude:geoPoint.longitude];
		double distance = [newLocation pythagorasEquirectangularDistanceFromLocation:locationUser];
		if (distance > 100)
		{
			user[PF_USER_LOCATION] = [PFGeoPoint geoPointWithLocation:newLocation];
			[user saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error)
			{
				if (error != nil) NSLog(@"AppDelegate didUpdateToLocation network error.");
			}];
		}
	}
}

//---------------------------------------------------------------------------------------------------
- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error
//---------------------------------------------------------------------------------------------------
{
	
}

@end
