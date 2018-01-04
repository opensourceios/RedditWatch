//
//  NameRowController.swift
//  redditwatch
//
//  Created by Will Bishop on 20/12/17.
//  Copyright © 2017 Will Bishop. All rights reserved.
//

import WatchKit
class NameRowController: NSObject {
	@IBOutlet var nameLabe: WKInterfaceLabel!
	@IBOutlet var postImage: WKInterfaceImage!
	@IBOutlet var postScore: WKInterfaceLabel!
	@IBOutlet var postTime: WKInterfaceLabel!
	@IBOutlet var postAuthor: WKInterfaceLabel!
	@IBOutlet var postCommentCount: WKInterfaceLabel!
	
	@IBOutlet var upvoteButton: WKInterfaceButton!
	@IBOutlet var gildedIndicator: WKInterfaceLabel!
	var id = String()
	
	@IBOutlet var twitterHousing: WKInterfaceGroup!
	@IBOutlet var twitterPic: WKInterfaceImage!
	
	@IBOutlet var tweetText: WKInterfaceLabel!
	@IBOutlet var twitterDisplayName: WKInterfaceLabel!
	@IBOutlet var twitterRetweets: WKInterfaceLabel!
	
	@IBOutlet var twitterLikes: WKInterfaceLabel!
	@IBOutlet var twitterUsername: WKInterfaceLabel!
}
