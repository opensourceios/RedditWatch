//
//  ViewController.swift
//  redditwatch
//
//  Created by Will Bishop on 20/12/17.
//  Copyright © 2017 Will Bishop. All rights reserved.
//

import UIKit
import WatchConnectivity

class ViewController: UIViewController, WCSessionDelegate {
	@IBOutlet weak var userSubreddits: UITextField!
	
	
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

