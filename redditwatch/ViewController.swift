//
//  ViewController.swift
//  redditwatch
//
//  Created by Will Bishop on 20/12/17.
//  Copyright © 2017 Will Bishop. All rights reserved.
//

import UIKit
import WatchConnectivity
import SafariServices
import Alamofire
import SwiftyJSON

class ViewController: UIViewController, WCSessionDelegate, SFSafariViewControllerDelegate {
	@IBOutlet weak var userSubreddits: UITextField!
	var authSession: SFAuthenticationSession?

	@IBOutlet weak var connectButton: UIButton!
	@IBOutlet weak var highResSwitch: UISwitch!
	
	func sessionDidBecomeInactive(_ session: WCSession) {
		//
	}
	
	func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
		print("Done")
	}
	func sessionDidDeactivate(_ session: WCSession) {
		//
	}
	
	var phases = UserDefaults.standard.object(forKey: "phrases") as? [String] ?? ["pics","all", "popular"]
	
	var wcSession: WCSession!
	override func viewWillAppear(_ animated: Bool) {
	userSubreddits.text = phases.joined(separator: ",")
	}
	override func viewDidLoad() {
		super.viewDidLoad()
		self.connectButton.isEnabled = true
		connectButton.setTitle("Please launch on watch to connect to Reddit", for: .normal)
		if let bool = UserDefaults.standard.object(forKey: "highResImage") as? Bool{
				highResSwitch.setOn(bool, animated: false)
		} else{
			print("couldn't do bool")
		}
		
		
		wcSession = WCSession.default
		wcSession.delegate = self
		wcSession.activate()
		
		// Do any additional setup after loading the view, typically from a nib.
		
	}
	
	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
		// Dispose of any resources that can be recreated.
	}
	func getQueryStringParameter(url: String, param: String) -> String? {
		guard let url = URLComponents(string: url) else { return nil }
		return url.queryItems?.first(where: { $0.name == param })?.value
	}
	@IBAction func connectToReddit(){
		
		let callbackUrl  = "redditwatch://redirect"
		let authURL = URL(string: "https://www.reddit.com/api/v1/authorize?client_id=uUgh0YyY_k_6ow&response_type=code&state=not_that_important&redirect_uri=redditwatch://redirect&duration=permanent&scope=identity%20edit%20flair%20history%20modconfig%20modflair%20modlog%20modposts%20modwiki%20mysubreddits%20privatemessages%20read%20report%20save%20submit%20subscribe%20vote%20wikiedit%20wikiread")
		//Initialize auth session
		self.authSession = SFAuthenticationSession(url: authURL!, callbackURLScheme: callbackUrl, completionHandler: { (callBack:URL?, error:Error? ) in
			guard error == nil, let successURL = callBack else {
				print(error!)
				print("error")
				return
			}
			print(successURL)
			let user = self.getQueryStringParameter(url: (successURL.absoluteString), param: "code")
			if let code = user{
				print("Going")
				RedditAPI().getAccessToken(grantType: "authorization_code", code: code, completionHandler: {result in
					UserDefaults.standard.set(true, forKey: "connected")
					self.wcSession.sendMessage(result, replyHandler: nil, errorHandler: { error in
						print(error.localizedDescription)
					})
				})
			}
		})
		self.authSession?.start()
		
	}

	func session(_ session: WCSession, didReceiveMessage message: [String : Any]) {
		print("recieved")
		if let launched = message["appLaunched"] as? Bool{
			if launched{
				DispatchQueue.main.async {
					self.connectButton.isEnabled = true
					self.connectButton.setTitle("Connect To Reddit", for: .normal)
				}
			}
		}
	}

	@IBAction func clickedButton(_ sender: Any) {
		
		UserDefaults.standard.set(userSubreddits.text?.components(separatedBy: ","), forKey: "phrases")
		phases = (userSubreddits.text?.components(separatedBy: ","))!
		wcSession.sendMessage(["phrases": phases], replyHandler: nil, errorHandler: { errror in
			print(errror)
		})
		self.resignFirstResponder()
		
	}
	@IBAction func switchImageRes(_ sender: Any) {
		if let sender = sender as? UISwitch{
			switch sender.isOn{
			case true:
				UserDefaults.standard.set(true, forKey: "highResImage")
				wcSession.sendMessage(["highResImage": true], replyHandler: nil, errorHandler: nil)
			case false:
				wcSession.sendMessage(["highResImage": false], replyHandler: nil, errorHandler: nil)
				UserDefaults.standard.set(false, forKey: "highResImage")
			}
		}
	}
}

