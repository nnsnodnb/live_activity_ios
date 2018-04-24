//
//  WorkoutTableViewCell.swift
//  LiveActivity
//
//  Created by Oka Yuya on 2018/04/21.
//  Copyright © 2018年 Oka Yuya. All rights reserved.
//

import UIKit

class WorkoutTableViewCell: UITableViewCell {

    @IBOutlet weak var datetimeLabel: UILabel!
    @IBOutlet weak var caloryLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
}
