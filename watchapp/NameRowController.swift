//
//  NameRowController.swift
//  redditwatch
//
//  Created by Will Bishop on 20/12/17.
//  Copyright © 2017 Will Bishop. All rights reserved.
//

import WatchKit

protocol customDelegate: NSObjectProtocol {
	func didSelect(_ button: WKInterfaceButton, onCellWith id: String, action: String)
}

class NameRowController: NSObject {
	weak var delegate: customDelegate?
	var index: Int = 0
	
	@IBOutlet var nameLabe: WKInterfaceLabel!
	@IBOutlet var postImage: WKInterfaceImage!
	@IBOutlet var postScore: WKInterfaceLabel!
	@IBOutlet var postTime: WKInterfaceLabel!
	@IBOutlet var postAuthor: WKInterfaceLabel!
	@IBOutlet var postCommentCount: WKInterfaceLabel!
	
	@IBOutlet var postSubreddit: WKInterfaceLabel!
	@IBOutlet var postFlair: WKInterfaceLabel!
	@IBOutlet var upvoteButton: WKInterfaceButton!
	@IBOutlet var gildedIndicator: WKInterfaceLabel!
	var id = String()
	
	@IBOutlet var twitterHousing: WKInterfaceGroup!
	@IBOutlet var twitterPic: WKInterfaceImage!
	@IBOutlet var nsfwIndicator: WKInterfaceLabel!
	
	@IBOutlet var tweetText: WKInterfaceLabel!
	@IBOutlet var twitterDisplayName: WKInterfaceLabel!
	@IBOutlet var twitterRetweets: WKInterfaceLabel!
	
	@IBOutlet var downvoteButton: WKInterfaceButton!
	@IBOutlet var twitterLikes: WKInterfaceLabel!
	@IBOutlet var twitterUsername: WKInterfaceLabel!
	@IBAction func upvotePost() {
		self.delegate?.didSelect(self.upvoteButton, onCellWith: self.id, action: "upvote")
	}
	
	@IBAction func downvotePost() {
		self.delegate?.didSelect(self.downvoteButton, onCellWith: self.id, action: "downvote")
	}
}
