//
//  CustomTableViewCell.swift
//  FliPho
//
//  Created by Petre Vane on 04/09/2019.
//  Copyright © 2019 Petre Vane. All rights reserved.
//

import UIKit

class CustomTableViewCell: UITableViewCell {
    
    
    @IBOutlet weak var tableImageView: UIImageView!
    @IBOutlet weak var imageLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
