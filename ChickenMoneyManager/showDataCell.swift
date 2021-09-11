//
//  showDataCell.swift
//  ChickenMoneyManager
//
//  Created by Mac on 2019/1/5.
//  Copyright © 2019年 CYCU. All rights reserved.
//

import UIKit

class showDataCell: UITableViewCell {

    @IBOutlet var itemLabel: UILabel!
    @IBOutlet var moneyLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        itemLabel.text = ""
        moneyLabel.text = ""
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
