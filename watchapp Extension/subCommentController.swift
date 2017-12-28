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
	@IBOutlet var repliesTable: WKInterfaceTable!
	override func awake(withContext context: Any?) {
		super.awake(withContext: context)
		print(context)
		if let js = context as? JSON{
			commentLabel.setText(js["body"].string!)
			//	print(js["replies"])
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
						
						return}
					
					row.nameLabe.setText(body)
					row.scoreLabel.setText("↑ " + String(describing: score) + " | ")
					row.userLabel.setText(user)
					if let newTime = comment["created_utc"].float{
						
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
		WKInterfaceDevice.current().play(WKHapticType.click)
		self.setTitle("Comments")
		self.pushController(withName: "subComment", context: comments[idList[rowIndex]])
	}
	
}
