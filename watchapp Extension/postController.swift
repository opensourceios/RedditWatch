//
//  postController.swift
//  watchapp Extension
//
//  Created by Will Bishop on 20/12/17.
//  Copyright © 2017 Will Bishop. All rights reserved.
//

import WatchKit
import Foundation
import SwiftyJSON
import Alamofire

class postController: WKInterfaceController {
	
	@IBOutlet var postComments: WKInterfaceLabel!
	@IBOutlet var postScore: WKInterfaceLabel!
	@IBOutlet var postAuthor: WKInterfaceLabel!
	@IBOutlet var progressLabel: WKInterfaceLabel!
	@IBOutlet var upvoteButton: WKInterfaceButton!
	@IBOutlet var downvoteButton: WKInterfaceButton!
	@IBOutlet var savePostButton: WKInterfaceButton!
	@IBOutlet var postTitle: WKInterfaceLabel!
	@IBOutlet var commentsTable: WKInterfaceTable!
	@IBOutlet var postImage: WKInterfaceImage!
	@IBOutlet var postTime: WKInterfaceLabel!
	
	var saved = false
	var comments = [String: JSON]()
	var currentPost = JSON()
	var downvoted = false
	var upvoted = false
	@IBOutlet var postContent: WKInterfaceLabel!
	var ids = [String: Any]()
	var idList = [String]()
	var currentSort = "best"
	override func awake(withContext context: Any?) {
		
		
		super.awake(withContext: context)
		addMenuItem(with: WKMenuItemIcon.info, title: "Change Sort", action: #selector(changeSort))
		downvoteButton.setHidden(true)
		upvoteButton.setHidden(true)
		savePostButton.setHidden(true)
		guard let post = context as? JSON else{
			InterfaceController().becomeCurrentPage()
			return
			
			
		}
		
		if let connected = UserDefaults.standard.object(forKey: "connected") as? Bool{
			if connected {
				downvoteButton.setHidden(false)
				upvoteButton.setHidden(false)
				savePostButton.setHidden(false)
			}
		}
		print(UserDefaults.standard.object(forKey: "connected"))
		if let author = post["author"].string{
			postAuthor.setText(author)
		}
		if let newTime = post["created_utc"].float{
			postTime.setText(TimeInterval().differenceBetween(newTime))
		}
		if let score = post["score"].int{
			
			postScore.setText("↑ \(String(score))")
		}
		if let replies = post["num_comments"].int{
			postComments.setText("\(replies) Comments")
		}
		if UserDefaults.standard.object(forKey: "shouldLoadImage") as! Bool{
			if let imagedat = UserDefaults.standard.object(forKey: "selectedThumbnail") as? Data{
				postImage.setImageData(imagedat)
				
				
			}
			if var url = post["url"].string{
				if url.range(of: "imgur") != nil && url.range(of: "i.imgur") == nil && url.range(of: "/a/") == nil{ //If it's an imgur post, that isn't an album, but also is not a direct link
					let id = url.components(separatedBy: ".com/").last!
					url = "https://i.imgur.com/\(id).png" //Make it one
				}
				if url.range(of: "http") == nil{
					url = "https://" + url
				}
				if url.range(of: "https") == nil{
					url = url.replacingOccurrences(of: "http://", with: "https://")
				}
				print("Downloading")
				
				Alamofire.request(url)
					.responseData { imageData in
						
						if let data = imageData.data{
							if post["post_hint"].string! == "image" && url.range(of: "gif") != nil{
								if let b = UIImage.gifImageWithData(data){
									print("Gif")
									self.postImage.setImage(b)
									self.postImage.startAnimating()
								}
							} else{
								let image = UIImage(data: data)
								if image != nil{
									print("setting \(image)")
									self.postImage.setImage(image)
									
								}
							}
							
							
						} else{
							self.progressLabel.setText("Incompatible Website")
							print("couldn't make image")
						}
					}
					
					.downloadProgress { progress in
						self.progressLabel.setText("Downloading \(String(progress.fractionCompleted * 100).prefix(4))%")
						if progress.fractionCompleted == 1.0{
							self.progressLabel.setHidden(true)
						}
				}
			}
		}
		currentPost = post
		UserDefaults.standard.set(post["author"].string, forKey: "selectedAuthor")
		if let content = post["selftext"].string{
			postContent.setText(content.dehtmlify())
		}
		
		if let title = post["title"].string{
			postTitle.setText(title)
		}
		
		// Configure interface objects here.
		if let subreddit = post["subreddit"].string, let id = post["id"].string {
			getComments(subreddit: subreddit, id: id)
			
			
			updateUserActivity("com.willbishop.watchy.handoff", userInfo: ["current": id, "subreddit": subreddit], webpageURL: nil)
			
			
		} else{
			print("wouldn't let")
		}
	}
	
	
	func getComments(subreddit: String, id: String, sort: String = "best"){
		let url = URL(string: "https://www.reddit.com/r/\(subreddit)/comments/\(id).json")
		comments.removeAll()
		ids.removeAll()
		idList.removeAll()
		
		print(url)
		
		let parameters = [
			"sort": sort.lowercased()
		]
		
		print(sort)
		Alamofire.request(url!,  parameters: parameters)
			.responseData { data in
				
				if let data = data.data {
					do {
						let json = try JSON(data: data)
						
						if let da = json.array?.last!["data"]["children"]{
							for (_, element) in da.enumerated(){
								
								self.comments[element.1["data"]["id"].string!] = element.1["data"]
								self.idList.append(element.1["data"]["id"].string!)
							}
						} else{
							print("yeah no")
						}
						
						self.commentsTable.setAlpha(0.0)
						self.commentsTable.setNumberOfRows(self.comments.count, withRowType: "commentCell")
						for (index, element) in self.idList.enumerated(){
							if let row = self.commentsTable.rowController(at: index) as? commentController{
								if let stuff = self.comments[element]?.dictionary{
									row.nameLabel.setText(stuff["body"]?.string?.dehtmlify())
									if let score = stuff["score"]{
										
										row.scoreLabel.setText("↑ \(String(describing: score.int!)) |")
									}
									
									if let gildedCount = stuff["gilded"]?.int{
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
									if let rep = stuff["replies"]{
										if let replyCount = rep["data"]["children"].array{
											if let _ = replyCount.last!["data"]["body"].string{
												row.replies = replyCount.count
												row.replyCount.setText("\(String(describing: replyCount.count)) Replies")
											} else{
												row.replies = replyCount.count - 1
												row.replyCount.setText("\(String(describing: replyCount.count - 1)) Replies")
												
											}
											
										}
										
									}
									row.userLabel.setText(stuff["author"]?.string)
									
									if stuff["author"]?.string! == UserDefaults().string(forKey: "selectedAuthor"){
										row.userLabel.setTextColor(UIColor(red:0.20, green:0.60, blue:0.86, alpha:1.0))
									}
									if (stuff["distinguished"]?.null) != nil{
										
									} else{
										if let distin = stuff["distinguished"]?.string{
											if distin == "moderator"{
												row.userLabel.setTextColor(UIColor(red:0.18, green:0.80, blue:0.44, alpha:1.0))
												
											} else if distin == "admin"{
												row.userLabel.setTextColor(UIColor(red:0.91, green:0.30, blue:0.24, alpha:1.0))

											}
											
											
										}
										
									}
									
									if let newTime = stuff["created_utc"]?.float{
										row.timeLabel.setText(TimeInterval().differenceBetween(newTime))
									}
								} else{
									print("you done stuffed it")
								}
							} else{
								print("helllll no")
							}
						}
						self.commentsTable.setAlpha(1.0)
						WKInterfaceDevice.current().play(WKHapticType.stop)
						
						
					} catch {
						print("Swifty json messed up... though it's totally your fault")
					}
				} else{
					print("wouldn't let")
				}
		}
		
	}
	override func willActivate() {
		// This method is called when watch view controller is about to be visible to user
		super.willActivate()
		print("Back bitches")
		
		if let sort = UserDefaults.standard.object(forKey: currentPost["title"].string!) as? String{
			UserDefaults.standard.removeObject(forKey: currentPost["title"].string!)
			if let subreddit = currentPost["subreddit"].string, let id = currentPost["id"].string {
				if sort.lowercased() != currentSort{
					getComments(subreddit: subreddit, id: id, sort: sort)
					currentSort = sort.lowercased()
					self.commentsTable.setNumberOfRows(0, withRowType: "commentCell")
				} else{
					WKInterfaceDevice.current().play(WKHapticType.retry) //Retry, because they may have tapped the wrong sort.
				}
				
			}
		}
	}
	@IBAction func imageTapped(_ sender: Any) {
		print("Heyo")
	}
	override func table(_ table: WKInterfaceTable, didSelectRowAt rowIndex: Int) {
		print(ids[Array(comments.keys)[rowIndex]])
		
		
		if (commentsTable.rowController(at: rowIndex) as? commentController) != nil{
			//if row.replies > 0{
			WKInterfaceDevice.current().play(WKHapticType.click)
			self.pushController(withName: "subComment", context: comments[idList[rowIndex]])
			//} else{
			//	WKInterfaceDevice.current().play(WKHapticType.failure)
			//}
		}
		
	}
	@IBAction func upvote() {
		WKInterfaceDevice.current().play(WKHapticType.click)
		if downvoted{
			
			self.downvoteButton.setTitleWithColor(title: "↓", color: UIColor.white)
		}
		if !upvoted{
			upvoted = true
			print(UserDefaults.standard.object(forKey: "selectedId"))
			print(UserDefaults.standard.object(forKey: "access_token"))
			self.upvoteButton.setTitleWithColor(title: "↑", color: UIColor(red:0.95, green:0.61, blue:0.07, alpha:1.0))
			self.downvoteButton.setTitleWithColor(title: "↓", color: UIColor.white)
			RedditAPI().vote(1, id: "t3_\(UserDefaults.standard.object(forKey: "selectedId") as! String)", access_token: UserDefaults.standard.object(forKey: "access_token") as! String)
			
		} else{
			downvoted = false
			upvoted = false
			self.upvoteButton.setTitleWithColor(title: "↑", color: UIColor.white)
			RedditAPI().vote(0, id: "t3_\(UserDefaults.standard.object(forKey: "selectedId") as! String)", access_token: UserDefaults.standard.object(forKey: "access_token") as! String)
		}
		
	}
	@IBAction func downvote() {
		WKInterfaceDevice.current().play(WKHapticType.click)
		if upvoted{
			self.upvoteButton.setTitleWithColor(title: "↑", color: UIColor.white)
		}
		if !downvoted{
			downvoted = true
			print(UserDefaults.standard.object(forKey: "selectedId"))
			print(UserDefaults.standard.object(forKey: "access_token"))
			self.downvoteButton.setTitleWithColor(title: "↓", color: UIColor(red:0.16, green:0.50, blue:0.73, alpha:1.0))
			self.upvoteButton.setTitleWithColor(title: "↑", color: UIColor.white)
			RedditAPI().vote(-1, id: "t3_\(UserDefaults.standard.object(forKey: "selectedId") as! String)", access_token: UserDefaults.standard.object(forKey: "access_token") as! String)
			
		} else{
			downvoted = false
			upvoted = false
			self.downvoteButton.setTitleWithColor(title: "↓", color: UIColor.white)
			RedditAPI().vote(0, id: "t3_\(UserDefaults.standard.object(forKey: "selectedId") as! String)", access_token: UserDefaults.standard.object(forKey: "access_token") as! String)
			
		}
		
	}
	@IBAction func savePost() {
		WKInterfaceDevice.current().play(WKHapticType.click)
		
		if !saved{
			savePostButton.setBackgroundColor(UIColor(red:0.95, green:0.61, blue:0.07, alpha:1.0))
			let id = UserDefaults.standard.object(forKey: "selectedId") as! String
			let token = UserDefaults.standard.object(forKey: "access_token") as! String
			RedditAPI().save(id: id, type: "t3", access_token: token)
			saved = true
		} else{
			savePostButton.setBackgroundColor(UIColor(red: 0.13, green: 0.13, blue: 0.13, alpha: 1.0))
			let id = UserDefaults.standard.object(forKey: "selectedId") as! String
			let token = UserDefaults.standard.object(forKey: "access_token") as! String
			RedditAPI().save(id: id, type: "t3", access_token: token, true)
			saved = false
		}
	}
	override func didDeactivate() {
		// This method is called when watch view controller is no longer visible
		super.didDeactivate()
	}
	@objc func changeSort(){
		let context = [
			"type": "comment",
			"sorts": ["Best", "Top", "New", "Controversial", "Old"],
			"title": currentPost["title"].string!
			] as [String : Any?]
		self.presentController(withName: "commentSort", context: context)
		
	}
	@IBAction func postComment() {
		presentTextInputController(withSuggestions: ["No"], allowedInputMode:  WKTextInputMode.plain) { (arr: [Any]?) in
			if let arr = arr{
				if let comment = arr.first as? String{
					guard let access_token = UserDefaults.standard.object(forKey: "access_token") as? String else {return}
					print(self.currentPost["id"].string!)
					RedditAPI().post(commentText: comment, access_token: access_token, parentId: (self.currentPost["id"].string!), completionHandler: {js in
						
						guard let dat = js["json"]["data"]["things"].array else{return}
						guard let first = dat.first else {return}
					
						let postedComment = first["data"]
						
						
						if let author = postedComment["author"].string, let body = postedComment["body"].string{
							
							print("Created")
							let idx = NSIndexSet(index: 0)
							self.commentsTable.insertRows(at: idx as IndexSet, withRowType: "commentCell")
							if var row = self.commentsTable.rowController(at: 0) as? commentController{
								row.scoreLabel.setText("↑ 1 |")
								row.timeLabel.setText("Just Now")
								row.gildedIndicator.setHidden(true)
								row.replyCount.setText("0 Replies")
								row.userLabel.setText(author)
								row.nameLabel.setText(body)
								print("Set")
								self.commentsTable.scrollToRow(at: 0)
							}
						}
						
					})
					
					//TODO: Add row to post without refresh
					
				}
			}
		}
	}
}

extension String{
	func dehtmlify() -> String{
		let html = [
			"&quot;"    : "\"",
			"&amp;"     : "&",
			"&apos;"    : "'",
			"&lt;"      : "<",
			"&gt;"      : ">",
			"&qt;"         : "" //I don't know that &qt; is atm
		]
		var replacement = self
		for (_, element) in html.enumerated(){
			replacement = replacement.replacingOccurrences(of: element.key, with: element.value)
		}
		
		return replacement
		
	}
}

extension WKInterfaceButton {
	func setTitleWithColor(title: String, color: UIColor) {
		let attString = NSMutableAttributedString(string: title)
		attString.setAttributes([NSAttributedStringKey.foregroundColor: color], range: NSMakeRange(0, attString.length))
		self.setAttributedTitle(attString)
	}
	
}
