//
//  waitForiPhone.swift
//  watchapp Extension
//
//  Created by Will Bishop on 4/1/18.
//  Copyright © 2018 Will Bishop. All rights reserved.
//

import WatchKit
import WatchConnectivity

class waitForiPhone: WKInterfaceController, WCSessionDelegate {
	func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
		print("Done")
		switch activationState {
		case .activated:
			print("activated")
			if (self.wcSession?.isReachable)!{
				self.wcSession?.sendMessage(["appLaunched": true], replyHandler: nil, errorHandler: { error in
					print(error.localizedDescription)
				})
			} else{
				print("Not reachable")
			}
		default:
			print("not actived")
		}
		print(error?.localizedDescription)
		
	}
	@IBOutlet var getStartedButton: WKInterfaceButton!
	var wcSession: WCSession?
	override func awake(withContext context: Any?) {
		super.awake(withContext: context)
		wcSession = WCSession.default
		wcSession?.delegate = self
		wcSession?.activate()
//		getStartedButton.setEnabled(false)
//		if let connected = UserDefaults.standard.object(forKey: "connected") as? Bool{
//			if connected {
//				getStartedButton.setEnabled(true)
//			}
//		}
	}
	
	
	@IBAction func getStarted() {
		print("Starting")
		UserDefaults.standard.set(true, forKey: "setup")
		self.dismiss()
	}
	func session(_ session: WCSession, didReceiveMessage message: [String : Any]) {
		print("RECEIVED")
		print(message)
		if let refesh_token = message["refresh_token"] as? String{
			print(refesh_token)
			UserDefaults.standard.set(refesh_token, forKey: "refresh_token")
			RedditAPI().getAccessToken(grantType: "refresh_token", code: refesh_token, completionHandler: { result in
				print(result)
				print("Saving \(result["access_token"])")
				UserDefaults.standard.set(result["access_token"], forKey: "access_token")
				UserDefaults.standard.set(true, forKey: "connected")
				print("SHould enable")
//				self.getStartedButton.setEnabled(true)
				
				
				
			})
		} else{
			print("WOULDN'T LET")
		}
	}

}
