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
class InterfaceController: WKInterfaceController{

    
    
    @IBOutlet var redditTable: WKInterfaceTable!
    
    var posts = [String: [String: Any]]()
    var names = [String]()
    var images = [Int: UIImage]()
    var post = [String: JSON]()
    var ids = [String]()
    var imageDownloadMode = false
    
    var currentSubreddit = String()
    var currentSort = String()
    
    
    override func awake(withContext context: Any?) {
        super.awake(withContext: context)
		_ = ["test": "4"]
        changeSubreddit()
        
        
    }
    
    override func willActivate() {
        // This method is called when watch view controller is about to be visible to user
        super.willActivate()
    }
    
    override func didDeactivate() {
        // This method is called when watch view controller is no longer visible
        super.didDeactivate()
    }
	func setupTable(_ subreddit: String = "askreddit", sort: String = "hot"){
        self.setTitle(subreddit)
        self.currentSubreddit = subreddit
        self.currentSort = sort
        var url = URL(string: "https://www.reddit.com/r/\(subreddit)/\(sort)/.json)")
        if sort == "Top"{
             url = URL(string: "https://www.reddit.com/r/\(subreddit)/\(sort)?t=all/.json")
        } else{
             url = URL(string: "https://www.reddit.com/r/\(subreddit)/\(sort)/.json")
        }
        
        names.removeAll()
        images.removeAll()
        ids.removeAll()
        post.removeAll()
        posts.removeAll()
		self.redditTable.setNumberOfRows(0, withRowType: "redditCell")
        print("her though")
        WKInterfaceDevice.current().play(WKHapticType.start)
        let task = URLSession.shared.dataTask(with: url!) { (data, response, error) in
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
								if let hint = stuff["post_hint"].string{
									//if hint == "image"{
										print(stuff["url"].string!)
										var url = stuff["url"].string! //High quality image, slow, but makes sure it all fits
									
										if 
											url.range(of: "http") == nil{
											url = "https://" + url
										}
										
										print("\(stuff["title"].string!)\n\(url)\n\n")
										Alamofire.request(url)
											.responseData { data in
												if let data = data.data{
													if let image = UIImage(data: data){
														row.postImage.setImage(image)
													}
												}
										}
										
									//}
								} else{
									print("No hint")
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
        task.resume()
        
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
        let phrases = ["popular", "tifu", "askreddit", "apple", "jailbreak", "talesfromtechsupport"]
        
        presentTextInputController(withSuggestions: phrases, allowedInputMode:   WKTextInputMode.plain) { (arr: [Any]?) in
            self.setupTable(arr?.first as! String)
        }
	}
	@IBAction func changeSort() {
		let sorts = ["Hot", "Top", "New"]
		presentTextInputController(withSuggestions: sorts, allowedInputMode: WKTextInputMode.plain){ (arr: [Any]?) in
			if let sort = arr?.first as? String{
				self.setupTable(self.currentSubreddit, sort: sort)
			}
		}
        
    }
    
	
    override func table(_ table: WKInterfaceTable, didSelectRowAt rowIndex: Int) {
        WKInterfaceDevice.current().play(WKHapticType.click)
        if (redditTable.rowController(at: rowIndex) as? NameRowController) != nil{
			
            //    UserDefaults.standard.set(posts[names[rowIndex]], forKey: "selectedPost")
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
