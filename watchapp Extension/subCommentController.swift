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
	
	@IBOutlet var repliesTable: WKInterfaceTable!
	override func awake(withContext context: Any?) {
        super.awake(withContext: context)
		if let js = context as? JSON{
			if let comments = js["replies"].array{
				for (index, comment) in comments.enumerated(){
					print(comment)
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

}
