//
//  URPollTextTableViewCell.swift
//  ureport
//
//  Created by Daniel Amaral on 13/08/15.
//  Copyright (c) 2015 ilhasoft. All rights reserved.
//

import UIKit

class URClosedPollTableViewCell: UITableViewCell {

    @IBOutlet weak var lbCategoryName: UILabel!
    @IBOutlet weak var lbDescr: UILabel!
    @IBOutlet weak var lbClosedDate: UILabel!
    @IBOutlet weak var viewTop: UIView!
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var viewSeparator: UIView!
    @IBOutlet weak var lbSeeResults:UILabel!
    
    var poll:URPoll!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.containerView.layer.cornerRadius = 5
        self.lbSeeResults.text = "polls_see_results".localized
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        super.selectionStyle = UITableViewCellSelectionStyle.none
        self.layoutMargins = UIEdgeInsets.zero
        self.separatorInset = UIEdgeInsets.zero
        // Configure the view for the selected state
    }        
    
    //MARK: Class Methods
    
    func setupCellWithData(_ poll:URPoll, at indexPath: IndexPath) {
        self.poll = poll
        self.lbCategoryName.text = poll.category.name
        self.lbDescr.text = poll.title
        self.lbClosedDate.text = poll.expiration_date
        
        var color: UIColor!
        #if ONTHEMOVE
            let evenIndex = indexPath.row % 2 == 0
            color = evenIndex ? UIColor(rgba: "#c19cd2") : UIColor(rgba: "#f2d400")
        #else
            color = poll.category.color
        #endif
        
        self.viewTop.backgroundColor = color
    }
    
}
