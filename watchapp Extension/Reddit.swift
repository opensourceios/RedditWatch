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
	
	func getAccessToken(grantType: String, code: String, completionHandler: @escaping ([String: String]) -> Void){
		print(grantType)
		var parameters = [
			"grant_type": grantType,
			"redirect_uri": "redditwatch://redirect"
		]
		if grantType == "refresh_token"{
			parameters["refresh_token"] = code
		} else{
			parameters["code"] = code
		}
		print(parameters)
		Alamofire.request("https://www.reddit.com/api/v1/access_token", method: .post, parameters: parameters)
			.authenticate(user: "uUgh0YyY_k_6ow", password: "")
			.responseJSON(completionHandler: {data in
				if data.response?.statusCode == 200{
					UserDefaults.standard.set(true, forKey: "connected")
				}
				if let dat = data.data{
					if let json = try? JSON(data: dat){
						print(json)
						var tokens = [String: String]()
						if grantType != "refresh_token"{
							tokens = ["access_token": json["access_token"].string!, "refresh_token": json["refresh_token"].string!]
							
						} else{
							tokens["acesss_token"] = json["access_token"].string!
						}
						completionHandler(tokens)
						
					}
				}
			})
	}
	func vote(_ direction: Int, id: String, rank: Int = 2, access_token: String){
		let parameters = [
			"dir": direction,
			"id": id,
			"rank": 1
			] as [String : Any]
		let headers = [
			"Authorization": "bearer \(access_token)",
			"User-Agent": "RedditWatch/0.1 by 123icebuggy",
		]
		print(headers)
		Alamofire.request("https://oauth.reddit.com/api/vote", method: .post, parameters: parameters, headers: headers)
			.responseString(completionHandler: {response in
				print(response.result.value)
			})
	}
	func save(id: String, type: String, access_token: String, _ unsave:Bool = false){
		let parameters = [
			"id": type + "_" + id,
			] as [String : Any]
		let headers = [
			"Authorization": "bearer \(access_token)",
			"User-Agent": "RedditWatch/0.1 by 123icebuggy",
			]
		print(headers)
		var save = "save"
		if unsave{
			save = "un" + save
		}
		Alamofire.request("https://oauth.reddit.com/api/\(save)", method: .post, parameters: parameters, headers: headers)
			.responseString(completionHandler: {response in
				print(response.result.value)
			})
			.response { reponse in
				print("Got \(reponse.response?.statusCode)")
		}
	}
	func post(commentText: String, access_token: String, parentId: String, type: String = "post"){
		let headers = [
			"Authorization": "bearer \(access_token)",
			"User-Agent": "RedditWatch/0.1 by 123icebuggy",
		]
		let types = ["post": "t3_", "comment": "t1_"]
		
		print("\(types[type])\(parentId)")
		let parameters = [
			"thing_id": "\(types[type]!)\(parentId)",
			"text": commentText,
			"return_rtjson": false,
			"api_type": "json"
			] as [String : Any]
		
		Alamofire.request("https://oauth.reddit.com/api/comment", method: .post, parameters: parameters, headers: headers)
			.responseString(completionHandler: {response in
				print(response.result.value)
			})
			.response { reponse in
				print("Got \(reponse.response?.statusCode)")
		}
	}
}
