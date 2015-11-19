//
//  TPMenuTableViewCell.swift
//  TimeDePrimeira
//
//  Created by Daniel Amaral on 28/07/15.
//  Copyright (c) 2015 ilhasoft. All rights reserved.
//

import UIKit

class ISMenuTableViewCell: UITableViewCell {

    @IBOutlet weak var lbTitle: UILabel!
    var menu:ISMenu?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        super.selectionStyle = UITableViewCellSelectionStyle.None
    }        
    
    //MARK: Class Methods
    
    func setupCellWith(menu:ISMenu){
        self.menu = menu
        self.lbTitle.text = menu.title
    }
    
}
