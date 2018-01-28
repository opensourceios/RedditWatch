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
import OAuthSwift

class InterfaceController: WKInterfaceController, WCSessionDelegate{
	
	
	
	
	@IBOutlet var redditTable: WKInterfaceTable!
	
	var posts = [String: [String: Any]]()
	var names = [String]()
	var images = [Int: UIImage]()
	var post = [String: JSON]()
	var ids = [String]()
	var imageDownloadMode = false
	var showSubredditLabels = ["popular", "all"]
	var phrases = ["Popular", "All", "Funny"]
	var wcSession: WCSession?
	var highResImage = UserDefaults.standard.object(forKey: "highResImage") as? Bool ?? false
	var currentSubreddit = String()
	var currentSort = String()
	
	
	override func awake(withContext context: Any?) {
		super.awake(withContext: context)
		invalidateUserActivity()
		//		let domain = Bundle.main.bundleIdentifier!
		//		UserDefaults.standard.removePersistentDomain(forName: domain) //Prevent nasty 0 __pthread_kill SIGABRT kill
		//		UserDefaults.standard.synchronize()
		print("we back bitche")
		if let bool = UserDefaults.standard.object(forKey: "setup") as? Bool{
			if bool{
				changeSubreddit()
			}
		}else{
			self.presentController(withNamesAndContexts: [("setup", AnyObject.self as AnyObject), ("page2", AnyObject.self as AnyObject)])
			
		}
		
		
		
	}
	
	
	override func willActivate() {
		// This method is called when watch view controller is about to be visible to user
		super.willActivate()
		wcSession = WCSession.default
		wcSession?.delegate = self
		wcSession?.activate()
		
		if let sort = UserDefaults.standard.object(forKey: currentSubreddit + "sort") as? String{
			UserDefaults.standard.removeObject(forKey: currentSubreddit + "sort")
			setupTable(currentSubreddit, sort: sort)
		}
		
		var lastTime = Date()
		var shouldRefresh = false
		
		if let lastRefresh = UserDefaults.standard.object(forKey: "lastRefresh") as? Date{
			lastTime = lastRefresh
		} else{
			shouldRefresh = true
		}
		
		let timeSince = Date().timeIntervalSince(lastTime)
		if timeSince > 1800{
			shouldRefresh = true
		}
		print(timeSince)
		
		if let refresh_token = UserDefaults.standard.object(forKey: "refresh_token") as? String{
			if shouldRefresh{
				UserDefaults.standard.set(Date(), forKey: "lastRefresh")
				print("Haven't refreshed access in atleast 30 mins")
				RedditAPI().getAccessToken(grantType: "refresh_token", code: refresh_token, completionHandler: { result in
					print("Got back \(result)")
					print("Saving \(result["acesss_token"])")
					UserDefaults.standard.set(result["acesss_token"]!, forKey: "access_token")
				})
			} else{
				print("Not refreshing because refreshed recently")
			}
		} else{
			print("Not setup")
			self.presentController(withName: "setup", context: nil)
		}
		
		
		
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
		print("RECEIVED")
		
		if let refesh_token = message["refresh_token"] as? String{
			print(refesh_token)
			UserDefaults.standard.set(refesh_token, forKey: "refresh_token")
			RedditAPI().getAccessToken(grantType: "refresh_token", code: refesh_token, completionHandler: { result in
				print(result)
				print("Saving \(result["acesss_token"])")
				UserDefaults.standard.set(result["acesss_token"], forKey: "access_token")
				UserDefaults.standard.set(true, forKey: "connected")
				print("SHould enable")
				self.dismiss()
				self.changeSubreddit()
				self.wcSession?.sendMessage(["setup":true], replyHandler: nil, errorHandler: { error in
					print(error.localizedDescription)
				})
				UserDefaults.standard.set(true, forKey: "setup")
				
				
				
			})
		} else{
			print("WOULDN'T LET")
		}
	}
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
		
		names.removeAll()
		images.removeAll()
		ids.removeAll()
		post.removeAll()
		posts.removeAll()
		self.redditTable.setNumberOfRows(0, withRowType: "redditCell")
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
						for (index, _) in self.post.enumerated(){
							if let row = self.redditTable.rowController(at: index ) as? NameRowController{
								if let stuff = self.post[self.ids[index]]
								{
									
									row.nameLabe.setText(stuff["title"].string!.dehtmlify())
									if let gildedCount = stuff["gilded"].int{
										if gildedCount > 0{
											row.gildedIndicator.setHidden(false)
											
											row.gildedIndicator.setText("\(gildedCount * "•")")
											
											
										} else{
											row.gildedIndicator.setHidden(true)
										}
									} else
									{
										print("couldn't find gild")
									}
									if let flair = stuff["link_flair_text"].string{
										row.postFlair.setText(flair)
									} else{
										row.postFlair.setHidden(true)
									}
									if let subreddit = stuff["subreddit"].string{
										if self.showSubredditLabels.contains(self.currentSubreddit){
											row.postSubreddit.setText("r/" + subreddit)
										} else{
											row.postSubreddit.setHidden(true)
										}
									} else{
										row.postSubreddit.setHidden(true)
									}
									row.postAuthor.setText(stuff["author"].string!)
									row.postCommentCount.setText(String(stuff["num_comments"].int!) + " Comments")
									let score = stuff["score"].int!
									row.postScore.setText("↑ \(String(describing: score)) |")
									if stuff["post_hint"].string != nil{
										if stuff["url"].string!.range(of: "twitter") != nil && (stuff["url"].string!.range(of: "status") != nil){
											print("MATCH: \(stuff["url"].string!)")
											let id = stuff["url"].string!.components(separatedBy: "/").last!
											Twitter().getTweet(tweetId: id, completionHandler: {tweet in
												if let js = tweet{
													row.tweetText.setText(js["text"].string!)
													row.twitterLikes.setText(String(js["favorite_count"].int!) + " Likes")
													row.twitterRetweets.setText(String(describing: js["retweet_count"].int!) +	 " Retweets")
													row.twitterUsername.setText("@" + js["user"]["screen_name"].string!)
													row.twitterDisplayName.setText(js["user"]["name"].string!)
													self.downloadImage(url: js["user"]["profile_image_url_https"].string!, index: 0, completionHandler: { image in
														if let img = image{
															row.twitterPic.setImage(img.circleMasked)
														}
													})
													
												}
												
											})
										} else {
											row.twitterHousing.setHidden(true)
											if let height = stuff["thumbnail_height"].int{
												row.postImage.setHeight(CGFloat(height))
											}
											var url = ""
											//if hint == "image"{
											row.id = stuff["id"].string!
											//row.upvoteButton.set
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
											
											Alamofire.request(url)
												.responseData { data in
													if let data = data.data{
														if let image = UIImage(data: data){
															row.postImage.setImage(image)
															self.images[index] = image
														}
														
													}
													
											}
											
										}
										
										//}
									} else{
										row.twitterHousing.setHidden(true)
									}
									if let newTime = stuff["created_utc"].float{
										
										row.postTime.setText(TimeInterval().differenceBetween(newTime))
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
	
	}
	@IBAction func changeSubreddit() {
		let suggestions = UserDefaults.standard.object(forKey: "phrases") as? [String] ?? phrases
		presentTextInputController(withSuggestions: suggestions, allowedInputMode:   WKTextInputMode.plain) { (arr: [Any]?) in
			if let input = arr?.first as? String{
				self.setupTable(input.lowercased().replacingOccurrences(of: " ", with: ""))
			} else{
				WKInterfaceDevice.current().play(WKHapticType.failure)
				self.changeSubreddit()
			}
		}
	}
	@IBAction func changeSort() {
		
		let context = [
			"type": "subreddit",
			"sorts": ["Hot", "New", "Rising", "Controversial", "Top", "Gilded"],
			"title": nil,
			"subreddit": currentSubreddit
			] as [String : Any?]
		self.presentController(withName: "commentSort", context: context)
		
//		let sorts = ["Hot", "New", "Rising", "Controversial", "Top", "Gilded"]
//		presentTextInputController(withSuggestions: sorts, allowedInputMode: WKTextInputMode.plain){ (arr: [Any]?) in
//			if let sort = arr?.first as? String{
//				self.setupTable(self.currentSubreddit, sort: sort.lowercased())
//			}
//		}
		
	}
	
	
	
	override func table(_ table: WKInterfaceTable, didSelectRowAt rowIndex: Int) {
		WKInterfaceDevice.current().play(WKHapticType.click)
		if (redditTable.rowController(at: rowIndex) as? NameRowController) != nil{
			
			//    UserDefaults.standard.set(posts[names[rowIndex]], forKey: "selectedPost")
			if images[rowIndex] != nil{
				print("Should attach image")
				UserDefaults.standard.set(true, forKey: "shouldLoadImage")
				UserDefaults.standard.set(ids[rowIndex], forKey: "selectedId")
				UserDefaults.standard.set(UIImagePNGRepresentation(images[rowIndex]!), forKey: "selectedThumbnail")
				self.pushController(withName: "lorem", context: post[ids[rowIndex]])
			} else{
				UserDefaults.standard.set(false, forKey: "shouldLoadImage")
				UserDefaults.standard.set(ids[rowIndex], forKey: "selectedId")
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
extension UIImage {
	var isPortrait:  Bool    { return size.height > size.width }
	var isLandscape: Bool    { return size.width > size.height }
	var breadth:     CGFloat { return min(size.width, size.height) }
	var breadthSize: CGSize  { return CGSize(width: breadth, height: breadth) }
	var breadthRect: CGRect  { return CGRect(origin: .zero, size: breadthSize) }
	var circleMasked: UIImage? {
		UIGraphicsBeginImageContextWithOptions(breadthSize, false, scale)
		defer { UIGraphicsEndImageContext() }
		guard let cgImage = cgImage?.cropping(to: CGRect(origin: CGPoint(x: isLandscape ? floor((size.width - size.height) / 2) : 0, y: isPortrait  ? floor((size.height - size.width) / 2) : 0), size: breadthSize)) else { return nil }
		UIBezierPath(ovalIn: breadthRect).addClip()
		UIImage(cgImage: cgImage, scale: 1, orientation: imageOrientation).draw(in: breadthRect)
		return UIGraphicsGetImageFromCurrentImageContext()
	}
}
