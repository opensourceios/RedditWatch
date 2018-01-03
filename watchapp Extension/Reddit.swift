//
//  Reddit.swift
//  watchapp Extension
//
//  Created by Will Bishop on 3/1/18.
//  Copyright © 2018 Will Bishop. All rights reserved.
//

import Foundation
import Alamofire
import SwiftyJSON

class RedditAPI{
	func getAccessToken(_ grantType: String = "refresh_token", _ authCode: String, completionHandler: @escaping ([String: String]) -> Void){
		let parameters = [
			"grant_type": grantType,
			"code": authCode,
			"redirect_uri": "redditwatch://redirect"
		]
		print(parameters)
		Alamofire.request("https://www.reddit.com/api/v1/access_token", method: .post, parameters: parameters)
			.authenticate(user: "uUgh0YyY_k_6ow", password: "")
			.responseJSON(completionHandler: {data in
				if let dat = data.data{
					if let json = try? JSON(data: dat){
						let tokens = ["access_token": json["access_token"].string!, "refresh_token": json["refresh_token"].string!]
						completionHandler(tokens)
						
					}
				}
			})
	}
}
