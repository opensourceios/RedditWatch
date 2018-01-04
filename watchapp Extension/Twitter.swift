//
//  Twitter.swift
//  watchapp Extension
//
//  Created by Will Bishop on 4/1/18.
//  Copyright © 2018 Will Bishop. All rights reserved.
//

import Foundation
import SwiftyJSON
import OAuthSwift

class Twitter{
	func getTweet(tweetId: String, completionHandler: @escaping (_: JSON?) -> Void){
		let oauthswift = OAuth1Swift(
			consumerKey:    "9N64qsTDR3wme5mx8CnSBSbyC",
			consumerSecret: "yEUjk5aypsjCBUbLECQD9Jn1C8Jgfo2qjCIV5TbVmJnZ8fPkzx"
		)
		// do your HTTP request without authorize
		oauthswift.client.get("https://api.twitter.com/1.1/statuses/show.json", parameters: ["id": tweetId],
							  success: { response in
								let tweet = try? JSON(data: response.data)
								completionHandler(tweet)
		},
							  failure: { error in
								print(error.localizedDescription)
								//...
		}
		)
	}
}
