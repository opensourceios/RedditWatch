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

class postController: WKInterfaceController {
    
    @IBOutlet var postTitle: WKInterfaceLabel!
    @IBOutlet var commentsTable: WKInterfaceTable!
    @IBOutlet var postImage: WKInterfaceImage!
    var comments = [String: JSON]()
    var waiiiiiit = JSON()
    @IBOutlet var postContent: WKInterfaceLabel!
    var ids = [String: Any]()
    var idList = [String]()
    override func awake(withContext context: Any?) {
        
        if UserDefaults.standard.object(forKey: "shouldLoadImage") as! Bool{
            let image = UserDefaults.standard.object(forKey: "selectedImage") as! Data
            let realImage = UIImage(data: image)
            postImage.setImage(realImage)
        }
        super.awake(withContext: context)
        let post = context as! JSON
        waiiiiiit = post
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
        } else{
            print("wouldn't let")
        }
    }
    
    
    func getComments(subreddit: String, id: String){
        let url = URL(string: "https://www.reddit.com/r/\(subreddit)/\(id)/.json")
        comments.removeAll()
        print("her though")
        let task = URLSession.shared.dataTask(with: url!) { (data, response, error) in
            print("here too")
			if (error != nil){
				WKInterfaceDevice.current().play(WKHapticType.failure)
				self.presentAlert(withTitle: "Error", message: error?.localizedDescription, preferredStyle: .alert, actions: [WKAlertAction.init(title: "Confirm", style: WKAlertActionStyle.default, handler: {
					print("Ho")
				})])
			} else{
				
			}
            if let data = data {
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
                    print(self.comments.count)
                    self.commentsTable.setAlpha(0.0)
                    self.commentsTable.setNumberOfRows(self.comments.count - 1, withRowType: "commentCell")
                    for (index, element) in self.idList.enumerated(){
                        if let row = self.commentsTable.rowController(at: index) as? commentController{
                            if let stuff = self.comments[element]?.dictionary{
                                row.nameLabe.setText(stuff["body"]?.string?.dehtmlify())
                                if let score = stuff["score"]{
                                    
                                    row.scoreLabel.setText("↑ \(String(describing: score.int!)) |")
                                }
                                if let replyCount = stuff["replies"]!["data"]["children"].array?.count
                                
                                {row.replyCount.setText("\(String(describing: replyCount)) Replies")}
                                row.userLabel.setText(stuff["author"]?.string)
                                
                                if stuff["author"]?.string! == UserDefaults().string(forKey: "selectedAuthor"){
                                    row.userLabel.setTextColor(UIColor.blue)
                                }
                                if (stuff["distinguished"]?.null) != nil{
                                    
                                } else{
                                    row.userLabel.setTextColor(UIColor(red:0.20, green:0.60, blue:0.86, alpha:1.0))
                                }
                                
                                if let newTime = stuff["created_utc"]?.float{
                                    
                                    let timeInterval = NSDate().timeIntervalSince1970
                                    let dif = (Float(timeInterval) - newTime)
                                    
                                    let time = (dif / 60 / 60)
                                    
                                    if time * 60 < 60{
                                        print(time)
                                        let timedif = String(describing: time * 60).components(separatedBy: ".").first! + "m"
                                        row.timeLabel.setText(timedif)
                                    } else {
                                        let timedif = String(describing: time).components(separatedBy: ".").first! + "h"
                                        row.timeLabel.setText(timedif)
                                    }
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
        task.resume()
    }
    override func willActivate() {
        // This method is called when watch view controller is about to be visible to user
        super.willActivate()
    }
    override func table(_ table: WKInterfaceTable, didSelectRowAt rowIndex: Int) {
        print(ids[Array(comments.keys)[rowIndex]])
        WKInterfaceDevice.current().play(WKHapticType.click)
        self.pushController(withName: "subComment", context: comments[idList[rowIndex]])
    }
    override func didDeactivate() {
        // This method is called when watch view controller is no longer visible
        super.didDeactivate()
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

