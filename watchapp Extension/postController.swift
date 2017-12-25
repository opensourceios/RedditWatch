//
//  postController.swift
//  watchapp Extension
//
//  Created by Will Bishop on 20/12/17.
//  Copyright © 2017 Will Bishop. All rights reserved.
//

import WatchKit
import Foundation


class postController: WKInterfaceController {

	@IBOutlet var postTitle: WKInterfaceLabel!
	@IBOutlet var commentsTable: WKInterfaceTable!
	@IBOutlet var postImage: WKInterfaceImage!
	var comments = [String: [String]]()
	var waiiiiiit = [String: Any]()
	@IBOutlet var postContent: WKInterfaceLabel!
	var ids = [String: Any]()
	override func awake(withContext context: Any?) {
		
		if UserDefaults.standard.object(forKey: "shouldLoadImage") as! Bool{
			let image = UserDefaults.standard.object(forKey: "selectedImage") as! Data
			let realImage = UIImage(data: image)
			postImage.setImage(realImage)
		}
        super.awake(withContext: context)
		let post = context as! [String: Any]
		waiiiiiit = post
		if let content = post["selftext"] as? String{
			postContent.setText(content)
		}
		
		if let title = post["title"] as? String{
			postTitle.setText(title)
		}
        // Configure interface objects here.
		guard let subreddit = post["subreddit"] as? String, let id = post["id"] as? String else {return}
		
		getComments(subreddit: subreddit, id: id)
    }
	
	func getComments(subreddit: String, id: String){
		let url = URL(string: "https://www.reddit.com/r/\(subreddit)/\(id)/.json")
		print(url)
		comments.removeAll()
		print("her though")
		let task = URLSession.shared.dataTask(with: url!) { (data, response, error) in
			print("here too")
			if let data = data {
				print("no way")
				do {
					print("Oh get outta town")
					// Convert the data to JSON
					let jsonSerialized = try JSONSerialization.jsonObject(with: data, options: []) as? [[String : Any]]
					if let json = jsonSerialized {
						if let jsobn = json as? NSArray{
							if let commentss = jsobn[1] as? [String: Any]{
								if let data = commentss["data"] as? [String: Any]{
									var timeString = String()
									
									if let children = data["children"] as? [[String: Any]]{
										for (_, element) in children.enumerated(){
											guard let shit = element["data"] as? [String: Any] else {print("No go"); return}
											if let body = shit["body"] as? String{
												
												self.ids[body] = [shit["id"] as! String, shit["replies"] as? [String: Any]]
												guard let score = shit["score"] as? Int else {
													return
												}
												
												let scoreInt = "↑ " + String(score) + " | "
												let timeInterval = NSDate().timeIntervalSince1970
												if let newTime = shit["created_utc"] as? Float{
													
													let dif = (Float(timeInterval) - newTime)
													let time = (dif / 60 / 60)
													
													if time * 60 < 60{
														print(time)
														let timedif = String(describing: time * 60).components(separatedBy: ".").first! + "m"
														self.comments[body] = [(shit["author"] as? String)!, timedif, scoreInt]
													} else {
														let timedif = String(describing: time).components(separatedBy: ".").first! + "h"
														self.comments[body] = [(shit["author"] as? String)!, timedif, scoreInt]
													}
												}
											}
											
										}
									}
									self.commentsTable.setNumberOfRows(self.comments.count, withRowType: "commentCell")
									for (index, element) in self.comments.enumerated(){
										if let row = self.commentsTable.rowController(at: index) as? commentController{
											row.nameLabe.setText(element.key)
											row.userLabel.setText(element.value.first!)
											row.timeLabel.setText(element.value[1])
											row.scoreLabel.setText(element.value[2])
											
										}
									}
									
								}
								
							} else{
								print("no")
								
							}
							
						}
					}
				}  catch let error as NSError {
					print(error.localizedDescription)
				}
			} else if let error = error {
				print(error.localizedDescription)
			}
		}
		
		task.resume()
	}
    override func willActivate() {
        // This method is called when watch view controller is about to be visible to user
        super.willActivate()
    }
	override func table(_ table: WKInterfaceTable, didSelectRowAt rowIndex: Int) {
		print(ids[Array(comments.keys)[rowIndex]])
		self.pushController(withName: "subComment", context: ids[Array(comments.keys)[rowIndex]])
	}
    override func didDeactivate() {
        // This method is called when watch view controller is no longer visible
        super.didDeactivate()
    }

}
