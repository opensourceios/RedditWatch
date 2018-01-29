//
//  AppDelegate.swift
//  redditwatch
//	
//  Created by Will Bishop on 20/12/17.
//  Copyright © 2017 Will Bishop. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

	var window: UIWindow?


	func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
		// Override point for customization after application launch.
		return true
	}

	func applicationWillResignActive(_ application: UIApplication) {
		// Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
		// Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
	}

	func applicationDidEnterBackground(_ application: UIApplication) {
		// Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
		// If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
	}

	func applicationWillEnterForeground(_ application: UIApplication) {
		// Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
	}

	func applicationDidBecomeActive(_ application: UIApplication) {
		// Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
	}

	func applicationWillTerminate(_ application: UIApplication) {
		// Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
	}
	func application(_ application: UIApplication, handleWatchKitExtensionRequest userInfo: [AnyHashable : Any]?, reply: @escaping ([AnyHashable : Any]?) -> Void) {
		reply(["test": "4"])
	}
	func application(_ app: UIApplication, open url: URL, options: [UIApplicationOpenURLOptionsKey : Any] = [:]) -> Bool {
		print(url)
		return true
	}
	func application(_ application: UIApplication, continue userActivity: NSUserActivity, restorationHandler: @escaping ([Any]?) -> Void) -> Bool {
		if let id = userActivity.userInfo!["current"] as? String, let sub = userActivity.userInfo!["subreddit"] as? String{
			guard let selectedClient = UserDefaults.standard.object(forKey: "selectedClient") as? String else { return false}
			
			var redditHooks = ""
			switch selectedClient{
			case "apollo":
				redditHooks = "apollo://reddit.com/\(id)"
			case "reddit":
				redditHooks = "reddit:///r/\(sub)/comments/\(id)"
			case "narwhal":
				redditHooks = "narwhal://open-url/reddit.com/r/\(sub)/comments/\(id)"
			default:
				redditHooks = "reddit:///r/\(sub)/comments/\(id)"
			}
			print(redditHooks)
			
			let redditUrl = URL(string: redditHooks)!
			if UIApplication.shared.canOpenURL(redditUrl)
			{
				UIApplication.shared.open(redditUrl)
				
			} else {
				//redirect to safari because the user doesn't have reddit
				print("No go")
			}
		} else{
			print("Would let id: \(userActivity.userInfo!)")
		}
		return true
	}
	func application(application: UIApplication,
					 continueUserActivity userActivity: NSUserActivity,
					 restorationHandler: (([AnyObject]!) -> Void))
		-> Bool {
			print("HERE")
			if let id = userActivity.userInfo!["current"]{
				let redditHooks = "apollo://reddit.com/\(id)"
				let redditUrl = URL(string: redditHooks)!
				if UIApplication.shared.canOpenURL(redditUrl)
				{
					UIApplication.shared.open(redditUrl)
					
				} else {
					//redirect to safari because the user doesn't have reddit
					print("No go")
				}
			} else{
				print("Would let id: \(String(describing: userActivity.userInfo))")
			}
	
			print(userActivity)
			// Do some checks to make sure you can proceed
			if self.window != nil {
				ViewController().restoreUserActivityState(userActivity)
			}
			return true
	}
	
	
}

