//
//  commentSort.swift
//  watchapp Extension
//
//  Created by Will Bishop on 18/1/18.
//  Copyright © 2018 Will Bishop. All rights reserved.
//

import UIKit
import WatchKit

class commentSort: WKInterfaceController {
	
	@IBOutlet var commentSortTable: WKInterfaceTable!
	var post = String()
	var type = String()
	var sorts = [String]() //Changes based on the type of thing you're sorting
	var subreddit = String()
	override func awake(withContext context: Any?) {
		print("We out her")
		if let cont = context as? [String: Any]{
			if let sub = cont["subreddit"] as? String{
				subreddit = sub
			}
			if let type = cont["type"] as? String{
				self.type = type
				if type == "comment"{
					print("SORTING COMMENTS")
					guard let sort = cont["sorts"] as? [String] else { print("No sorts"); return }
					sorts = sort
					guard let pos = cont["title"] as? String else { return}
					post = pos
						
					commentSortTable.setNumberOfRows(sort.count, withRowType: "commentSort")
					for (index, element) in sort.enumerated(){
						print("setting \([sort[index]])")
						if let row = commentSortTable.rowController(at: index) as? sortCell{
							row.sortLab.setText(sort[index])
						} else{
							print("No way bro")
						}
					}
				} else if type == "subreddit"{
					guard let sort = cont["sorts"] as? [String] else { print("No sorts"); return }
					sorts = sort
					commentSortTable.setNumberOfRows(sort.count, withRowType: "commentSort")
					for (index, element) in sort.enumerated(){
						print("setting \([sort[index]])")
						if let row = commentSortTable.rowController(at: index) as? sortCell{
							row.sortLab.setText(sort[index])
						} else{
							print("No way bro")
						}
					}
				}
			}
			
		}
		
	}
	
	
	
	override func table(_ table: WKInterfaceTable, didSelectRowAt rowIndex: Int) {
		if type == "comment"{
			UserDefaults.standard.set(sorts[rowIndex], forKey: post)
		} else if type == "subreddit"{
			UserDefaults.standard.set(sorts[rowIndex].lowercased(), forKey: subreddit + "sort")
		}
		self.dismiss()
	}
}
