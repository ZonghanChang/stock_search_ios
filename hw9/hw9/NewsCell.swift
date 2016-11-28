//
//  NewsCell.swift
//  hw9
//
//  Created by ZONGHAN CHANG on 5/1/16.
//  Copyright © 2016 ZONGHAN CHANG. All rights reserved.
//

import UIKit

class NewsCell: UITableViewCell {

   
    @IBOutlet weak var title: UILabel!
    @IBOutlet weak var content: UILabel!
    @IBOutlet weak var publisher: UILabel!
    @IBOutlet weak var date: UILabel!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
