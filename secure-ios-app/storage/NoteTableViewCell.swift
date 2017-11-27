//
//  NoteTableViewCell.swift
//  secure-ios-app
//
//  Created by Tom Jackman on 22/11/2017.
//  Copyright © 2017 Wei Li. All rights reserved.
//

import UIKit

class NoteTableViewCell: UITableViewCell {
    @IBOutlet var title: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
}
