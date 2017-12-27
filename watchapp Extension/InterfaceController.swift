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

class InterfaceController: WKInterfaceController {
	
	@IBOutlet var redditTable: WKInterfaceTable!
	
	var posts = [String: [String: Any]]()
	var names = [String]()
	var images = [Int: UIImage]()
	var post = [String: JSON]()
	var ids = [String]()
	var imageDownloadMode = false
	
	override func awake(withContext context: Any?) {
		super.awake(withContext: context)
		setupTable()
		
	}
	
	override func willActivate() {
		// This method is called when watch view controller is about to be visible to user
		super.willActivate()
	}
	
	override func didDeactivate() {
		// This method is called when watch view controller is no longer visible
		super.didDeactivate()
	}
	func setupTable(_ subreddit: String = "askreddit"){
		self.setTitle(subreddit)
		
		let url = URL(string: "https://www.reddit.com/r/\(subreddit)/.json")
		names.removeAll()
		images.removeAll()
		ids.removeAll()
		post.removeAll()
		posts.removeAll()
		print("her though")
		let task = URLSession.shared.dataTask(with: url!) { (data, response, error) in
			print(arc4random())
			print(error)
			if (error != nil){
				self.presentAlert(withTitle: "Error", message: error?.localizedDescription, preferredStyle: .alert, actions: [WKAlertAction.init(title: "Confirm", style: WKAlertActionStyle.default, handler: {
					print("Ho")
				})])
			}
			
			if let dat = data{
				do {
					let json = try JSON(data: dat)
					let children = json["data"]["children"].array
					for element in children!{
						
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
								row.postAuthor.setText(stuff["author"].string!)
								row.postCommentCount.setText(String(stuff["num_comments"].int!) + " Comments")
								let score = stuff["score"].int!
								row.postScore.setText("↑ \(String(describing: score)) |")
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
					
					
				} catch {
					print("done stuffed up")
				}
			} else{
				print("No go")
			}
			
			
		}
		task.resume()
		
	}
	func downloadImage(url: String, completionHandler: (_: UIImage?) -> Void){
		let url = URL(string: url)
		let data = try? Data(contentsOf: url!) //make sure your image in this url does exist, otherwise unwrap in a if let check / try-catch
		if let dat = data{
			let image = UIImage(data: dat)
			completionHandler(image)
			
		}
	}
	@IBAction func changeSubreddit() {
		let phrases = ["tifu", "askreddit", "talesfromtechsupport"]
		
		presentTextInputController(withSuggestions: phrases, allowedInputMode:   WKTextInputMode.plain) { (arr: [Any]?) in
			self.redditTable.setNumberOfRows(0, withRowType: "redditCell")
			self.setupTable(arr?.first as! String)
		}
		
	}
	override func table(_ table: WKInterfaceTable, didSelectRowAt rowIndex: Int) {
		if (redditTable.rowController(at: rowIndex) as? NameRowController) != nil{
			
			//	UserDefaults.standard.set(posts[names[rowIndex]], forKey: "selectedPost")
			if images[rowIndex] != nil{
				print("Should attach image")
				let image = UIImagePNGRepresentation(images[rowIndex]!)
				UserDefaults.standard.set(image, forKey: "selectedImage")
				UserDefaults.standard.set(true, forKey: "shouldLoadImage")
				self.pushController(withName: "lorem", context: posts[names[rowIndex]])
			} else{
				UserDefaults.standard.set(false, forKey: "shouldLoadImage")
				self.pushController(withName: "lorem", context: post[ids[rowIndex]])
			}
		}
	}
}
