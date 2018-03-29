//
//  SpotTableViewCell.swift
//  iOSAppPractice
//
//  Created by Carter on 2018/3/29.
//  Copyright © 2018年 Carter. All rights reserved.
//

import UIKit

class SpotTableViewCell: UITableViewCell {

    @IBOutlet weak var parkNameLabel: UILabel!
    @IBOutlet weak var introductionLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
