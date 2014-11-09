//
//  ArtViewCell.swift
//  Silkscreen
//
//  Created by Vlasov Illia on 09.11.14.
//  Copyright (c) 2014 vaisoft. All rights reserved.
//

import UIKit

class ArtViewCell: UITableViewCell {
    
    
    @IBOutlet weak var artImage: UIImageView!
    @IBOutlet weak var artistName: UILabel!
    @IBOutlet weak var cityLabel: UILabel!

    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
