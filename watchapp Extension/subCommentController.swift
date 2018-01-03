//
//  subCommentController.swift
//  watchapp Extension
//
//  Created by Will Bishop on 21/12/17.
//  Copyright © 2017 Will Bishop. All rights reserved.
//

import WatchKit
import Foundation
import SwiftyJSON

class subCommentController: WKInterfaceController {
    
    @IBOutlet var commentLabel: WKInterfaceLabel!
    var comments = [String: JSON]()
    var idList = [String]()
    var reduce = commentController()
    var post = JSON()
    @IBOutlet var repliesTable: WKInterfaceTable!
    override func awake(withContext context: Any?) {
		self.setTitle("Comments")
		
        super.awake(withContext: context)
        print(context)
        if let js = context as? JSON{
            post = js
            commentLabel.setText(js["body"].string!)
            //    print(js["replies"])
            for (_, element) in (js["replies"]["data"]["children"].array?.enumerated())!{
                let id = element["data"]["id"]
                idList.append(id.string!)
                comments[id.string!] = element["data"]
                
            }
            
        }
        repliesTable.setNumberOfRows(comments.count, withRowType: "replyCell")
        for (index, element) in idList.enumerated(){
            let comment = comments[element]
            if let row = repliesTable.rowController(at: index) as? commentController{
                if let comment = comment{
                    guard let body = comment["body"].string, let score = comment["score"].int, let user = comment["author"].string else{
                        print("Returning")
                        return}
                    if comment["author"].string! == UserDefaults().string(forKey: "selectedAuthor"){
                        row.userLabel.setTextColor(UIColor(red:0.20, green:0.60, blue:0.86, alpha:1.0))
                    }
					if let replyCount = comment["replies"]["data"]["children"].array?.count{
						row.replies = replyCount
						row.replyCount.setText("\(String(describing: replyCount)) Replies")
						
					}
					if let gildedCount = comment["gilded"].int{
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
                    if (comment["distinguished"].null) != nil{
                        
                    } else{
                        row.userLabel.setTextColor(UIColor.green)
                    }
                    row.nameLabe.setText(body)
                    row.scoreLabel.setText("↑ " + String(describing: score) + " | ")
                    row.userLabel.setText(user)
					
                    if let newTime = comment["created_utc"].float{
                        
                        
                        
						if let newTime = comment["created_utc"].float{
							
							row.timeLabel.setText(TimeInterval().differenceBetween(newTime))
						}
                    }
                    
                }
            }
        }
		
        // Configure interface objects here.
    }
    
    override func willActivate() {
        // This method is called when watch view controller is about to be visible to user
        super.willActivate()
    }
    
    override func didDeactivate() {
        // This method is called when watch view controller is no longer visible
        super.didDeactivate()
    }
    override func table(_ table: WKInterfaceTable, didSelectRowAt rowIndex: Int) {
		
		if let row = repliesTable.rowController(at: rowIndex) as? commentController{
			if row.replies > 0{ //Temporarily disabling crash-detection until fix to bug where replies to replies couldn't be viewed
				WKInterfaceDevice.current().play(WKHapticType.click)
				self.pushController(withName: "subComment", context: comments[idList[rowIndex]])
			} else{
				WKInterfaceDevice.current().play(WKHapticType.failure)
			}
		}
    }
    
}
