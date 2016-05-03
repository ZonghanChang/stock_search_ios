//
//  CustomCellTableViewCell.swift
//  hw9
//
//  Created by ZONGHAN CHANG on 4/30/16.
//  Copyright © 2016 ZONGHAN CHANG. All rights reserved.
//

import UIKit

class DetailCellTableViewCell: UITableViewCell {

    @IBOutlet weak var field: UILabel!
    @IBOutlet weak var content: UILabel!
    @IBOutlet weak var arrow: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
