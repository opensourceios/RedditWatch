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
	
	let sorts = ["Best", "Top", "New", "Controversial", "Old"]
	override func awake(withContext context: Any?) {
		print("We out her")
		if let selectedPost = context as? String{
			post = selectedPost
			commentSortTable.setNumberOfRows(5, withRowType: "commentSort")
			for (index, element) in sorts.enumerated(){
				if let row = commentSortTable.rowController(at: index) as? sortCell{
					row.sortLab.setText(sorts[index	])
				}
			}
		} else{
			self.dismiss()
		}
	}
	override func table(_ table: WKInterfaceTable, didSelectRowAt rowIndex: Int) {
		UserDefaults.standard.set(sorts[rowIndex], forKey: post)
		self.dismiss()
	}
}
