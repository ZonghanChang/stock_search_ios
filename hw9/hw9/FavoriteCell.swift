//
//  FavoriteCell.swift
//  hw9
//
//  Created by ZONGHAN CHANG on 5/2/16.
//  Copyright © 2016 ZONGHAN CHANG. All rights reserved.
//

import UIKit

class FavoriteCell: UITableViewCell {

    
    @IBOutlet weak var symbol: UILabel!
    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var price: UILabel!
    @IBOutlet weak var change: UILabel!
    @IBOutlet weak var cap: UILabel!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
