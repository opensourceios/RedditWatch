//
//  InterfaceController.swift
//  watchapp Extension
//
//  Created by Will Bishop on 20/12/17.
//  Copyright © 2017 Will Bishop. All rights reserved.
//

import WatchKit
import Foundation
import SwiftyJSON
import WatchConnectivity
import Alamofire
class InterfaceController: WKInterfaceController, WCSessionDelegate{
	func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
		print("Done")
	}
	
	
	
	
	@IBOutlet var redditTable: WKInterfaceTable!
	
	var posts = [String: [String: Any]]()
	var names = [String]()
	var images = [Int: UIImage]()
	var post = [String: JSON]()
	var ids = [String]()
	var imageDownloadMode = false
	
	var phrases = UserDefaults.standard.object(forKey: "phrases") as? [String] ?? ["Popular", "All", "Funny"]
	var wcSession: WCSession!
	var highResImage = UserDefaults.standard.object(forKey: "highResImage") as? Bool ?? false
	var currentSubreddit = String()
	var currentSort = String()
	
	
	override func awake(withContext context: Any?) {
		super.awake(withContext: context)
		_ = ["test": "4"]
		let domain = Bundle.main.bundleIdentifier!
		UserDefaults.standard.removePersistentDomain(forName: domain) //Prevent nasty 0 __pthread_kill SIGABRT kill
		UserDefaults.standard.synchronize()
		
		
		
		changeSubreddit()
		
		
	}
	
	override func willActivate() {
		// This method is called when watch view controller is about to be visible to user
		super.willActivate()
		wcSession = WCSession.default
		wcSession.delegate = self
		wcSession.activate()
	}
	
	override func didDeactivate() {
		// This method is called when watch view controller is no longer visible
		super.didDeactivate()
	}
	func session(_ session: WCSession, didReceiveMessage message: [String : Any]) {
		if let responsePhrases = message["phrases"] as? [String]{
			UserDefaults.standard.set(responsePhrases, forKey: "phrases")
			phrases = responsePhrases
		}
		if let highres = message["highResImage"] as? Bool{
			UserDefaults.standard.set(highres, forKey: "highResImage")
			highResImage = highres
		}
	}
	func setupTable(_ subreddit: String = "askreddit", sort: String = "hot"){
		self.setTitle(subreddit.lowercased())
		self.currentSubreddit = subreddit
		self.currentSort = sort
		var parameters = [String: Any]()
		var url = URL(string: "https://www.reddit.com/r/\(subreddit)/\(sort).json")
		if sort == "top"{
			url = URL(string: "https://www.reddit.com/r/\(subreddit)/\(sort).json")
			parameters["t"] = "all"
			
		} else{
			url = URL(string: "https://www.reddit.com/r/\(subreddit)/\(sort).json")
		}
		print(url)
		
		names.removeAll()
		images.removeAll()
		ids.removeAll()
		post.removeAll()
		posts.removeAll()
		self.redditTable.setNumberOfRows(0, withRowType: "redditCell")
		print("her though")
		WKInterfaceDevice.current().play(WKHapticType.start)
		Alamofire.request(url!, parameters: parameters)
			.responseData { (dat) in
				let data = dat.data
				let error = dat.error
				print(error)
				if (error != nil){
					WKInterfaceDevice.current().play(WKHapticType.failure)
					self.presentAlert(withTitle: "Error", message: error?.localizedDescription, preferredStyle: .alert, actions: [WKAlertAction.init(title: "Confirm", style: WKAlertActionStyle.default, handler: {
						print("Ho")
					})])
				} else{
					
				}
				
				if let dat = data{
					do {
						let json = try JSON(data: dat)
						let children = json["data"]["children"].array
						guard let child = children else{
							print("Wouldn't let with")
							print(json)
							return}
						for element in child{
							
							if !(element["data"]["stickied"].bool!){
								self.names.append(element["data"]["title"].string!)
								
								self.post[element["data"]["id"].string!] = element["data"]
								self.ids.append(element["data"]["id"].string!)
								
							}
						}
						self.redditTable.setAlpha(0.0)
						self.redditTable.setNumberOfRows(self.names.count, withRowType: "redditCell")
						print(self.post.count)
						for (index, _) in self.post.enumerated(){
							print(index)
							if let row = self.redditTable.rowController(at: index) as? NameRowController{
								if let stuff = self.post[self.ids[index]]
								{
									
									row.nameLabe.setText(stuff["title"].string!)
									if let gildedCount = stuff["gilded"].int{
										if gildedCount > 0{
											row.gildedIndicator.setHidden(false)
											print(gildedCount)
											row.gildedIndicator.setText("\(gildedCount * "•")")
											
										} else{
											print(gildedCount)
											row.gildedIndicator.setHidden(true)
										}
									} else
									{
										print("couldn't find gild")
									}
									
									row.postAuthor.setText(stuff["author"].string!)
									row.postCommentCount.setText(String(stuff["num_comments"].int!) + " Comments")
									let score = stuff["score"].int!
									row.postScore.setText("↑ \(String(describing: score)) |")
									if stuff["post_hint"].string != nil{
										if let height = stuff["thumbnail_height"].int{
											row.postImage.setHeight(CGFloat(height))
											
											
										}
										print(self.highResImage)
										var url = ""
										//if hint == "image"{
										
										if self.highResImage{
											url = stuff["url"].string!
										} else {
											url = stuff["thumbnail"].string! //back to thumbnail, show full image on post view
											if url == "image" || url == "nsfw"{
												url = stuff["url"].string!
											}
										}
										
										if url.range(of: "http") == nil{
											url = "https://" + url
										}
										
										print("\(stuff["title"].string!)\n\(url)\n\n")
										Alamofire.request(url)
											.responseData { data in
												if let data = data.data{
													if let image = UIImage(data: data){
														row.postImage.setImage(image)
														self.images[index] = image
													}
													
												}
												
										}
										
										//}
									} else{
										print("No hint for \(stuff["title"].string)")
									}
									if let newTime = stuff["created_utc"].float{
										
										let timeInterval = NSDate().timeIntervalSince1970
										let dif = (Float(timeInterval) - newTime)
										
										let time = (dif / 60 / 60)
										
										if time * 60 < 60{
											print(time)
											let timedif = String(describing: time * 60).components(separatedBy: ".").first! + "m"
											row.postTime.setText(timedif)
										} else {
											let timedif = String(describing: time).components(separatedBy: ".").first! + "h"
											row.postTime.setText(timedif)
										}
									}
									
								}
							}
							
							
							
						}
						self.redditTable.setAlpha(1.0)
						WKInterfaceDevice.current().play(WKHapticType.stop)
						
						
					} catch {
						print("done stuffed up")
					}
				} else{
					print("No go")
				}
				
		}
		
	}
	func downloadImage(url: String, index: Int, completionHandler: @escaping (_: UIImage?) -> Void){
		Alamofire.request(url)
			.responseData { data in
				if let data = data.data{
					if let image = UIImage(data: data){
						completionHandler(image)
					}
				}
		}
		//			.downloadProgress { progress in
		////				if let row = self.redditTable.rowController(at: index) as? NameRowController{
		////
		////					//row.percentComplete.setText(String(describing: progress.fileCompletedCount) + "%")
		////				}
		//		}
	}
	@IBAction func changeSubreddit() {
		let suggestions = UserDefaults.standard.object(forKey: "phrases") as? [String] ?? phrases
		presentTextInputController(withSuggestions: suggestions, allowedInputMode:   WKTextInputMode.plain) { (arr: [Any]?) in
			if let input = arr?.first as? String{
				self.setupTable(input)
			} else{
				WKInterfaceDevice.current().play(WKHapticType.failure)
				self.changeSubreddit()
			}
		}
	}
	@IBAction func changeSort() {
		let sorts = ["Hot", "New", "Rising", "Controversial", "Top", "Gilded"]
		presentTextInputController(withSuggestions: sorts, allowedInputMode: WKTextInputMode.plain){ (arr: [Any]?) in
			if let sort = arr?.first as? String{
				self.setupTable(self.currentSubreddit, sort: sort.lowercased())
			}
		}
		
	}
	
	
	override func table(_ table: WKInterfaceTable, didSelectRowAt rowIndex: Int) {
		WKInterfaceDevice.current().play(WKHapticType.click)
		if (redditTable.rowController(at: rowIndex) as? NameRowController) != nil{
			
			//    UserDefaults.standard.set(posts[names[rowIndex]], forKey: "selectedPost")
			if images[rowIndex] != nil{
				print("Should attach image")
				UserDefaults.standard.set(true, forKey: "shouldLoadImage")
				UserDefaults.standard.set(UIImagePNGRepresentation(images[rowIndex]!), forKey: "selectedThumbnail")
				self.pushController(withName: "lorem", context: post[ids[rowIndex]])
			} else{
				UserDefaults.standard.set(false, forKey: "shouldLoadImage")
				self.pushController(withName: "lorem", context: post[ids[rowIndex]])
			}
		}
	}
}

extension String{
	
	static func *(left: Int, right: String) -> String{
		var input = ""
		for _ in 1 ... left{
			input = input + right
		}
		return input
	}
}
