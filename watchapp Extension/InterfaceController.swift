//
//  InterfaceController.swift
//  watchapp Extension
//
//  Created by Will Bishop on 20/12/17.
//  Copyright © 2017 Will Bishop. All rights reserved.
//

import WatchKit
import Foundation


class InterfaceController: WKInterfaceController {

	@IBOutlet var redditTable: WKInterfaceTable!
	
	var posts = [String: [String: Any]]()
	var names = [String]()
	var images = [Int: UIImage]()
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
	func setupTable(_ subreddit: String = "funny"){
		self.setTitle(subreddit)
		let url = URL(string: "https://www.reddit.com/r/\(subreddit)/.json")
		names.removeAll()
		print("her though")
		let task = URLSession.shared.dataTask(with: url!) { (data, response, error) in
			print("here too")
			if let data = data {
				print("no way")
				do {
					print("Oh get outta town")
					// Convert the data to JSON
					let jsonSerialized = try JSONSerialization.jsonObject(with: data, options: []) as? [String : Any]
					
					if let json = jsonSerialized {
						if let data = json["data"] as? [String: Any]{
							if let children = data["children"] as? NSArray{
								for (index, element) in children.enumerated(){
									if let ele = element as? [String: Any]{
										if let b = ele["data"] as? [String: Any]{
											
											if (b["stickied"] as! Int) == 0{
												self.names.append(b["title"]! as! String)
												self.posts[b["title"]! as! String] = b
											}
											if let hint = b["post_hint"] as? String{
												
												if hint == "image"{
													guard let url = b["url"] as? String else {return}
													
													print("Should download \(url) for row \(index)")
													self.downloadImage(url: url, completionHandler: { image in
														if let img = image{
																self.images[index - 1] = img
																
															}
														
													})
												}
											} else{
												print(b["post_hint"])
											}
										}
									} else{
										print("F swift honestly")
									}
								}
								self.redditTable.setNumberOfRows(self.names.count, withRowType: "redditCell")
								for (index, _) in self.names.enumerated(){
									if let row = self.redditTable.rowController(at: index) as? NameRowController{
										row.nameLabe.setText(self.names[index])
										if self.images[index] != nil{
											row.postImage.setImage(self.images[index])
										}
									}
								}
							}else{
								print("Failed at data['children]'")
							}
						}else{
							print("Failed at json[data]")
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
	func downloadImage(url: String, completionHandler: (_: UIImage?) -> Void){
		let url = URL(string: url)
		let data = try? Data(contentsOf: url!) //make sure your image in this url does exist, otherwise unwrap in a if let check / try-catch
		if let dat = data{
			let image = UIImage(data: dat)
			completionHandler(image)
			
		}
	}
	@IBAction func changeSubreddit() {
		let phrases = ["tifu", "lifeofnorman", "talesfromtechsupport"]
		
		presentTextInputController(withSuggestions: phrases, allowedInputMode:   WKTextInputMode.plain) { (arr: [Any]?) in
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
				self.pushController(withName: "lorem", context: posts[names[rowIndex]])
			}
		}
	}
}
