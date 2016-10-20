//
//  URNewsTableViewCell.swift
//  ureport
//
//  Created by Daniel Amaral on 21/08/15.
//  Copyright (c) 2015 ilhasoft. All rights reserved.
//

import UIKit

class URNewsTableViewCell: UITableViewCell {

    @IBOutlet weak var lbTitle: UILabel!
    @IBOutlet weak var lbDescription: UILabel!
    @IBOutlet weak var imgNew: UIImageView!
    @IBOutlet weak var bgView: UIView!
    @IBOutlet weak var viewSeparator: UIView!
    @IBOutlet weak var viewCategory: UIView!
    @IBOutlet weak var viewOpacityImage: UIView!
    @IBOutlet weak var lbCategory: UILabel!
    @IBOutlet weak var lbTags: UILabel!
    
    var news:URNews!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.viewOpacityImage.backgroundColor = UIColor.black.withAlphaComponent(0.38)
        self.bgView.layer.cornerRadius = 5
        self.viewSeparator.layer.cornerRadius = 5
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        super.selectionStyle = UITableViewCellSelectionStyle.none
        // Configure the view for the selected state
    }
    
    func setupCellWith(_ news:URNews){
        self.news = news
        
        self.lbTitle.text = news.title
        self.lbCategory.text = news.category.name
        self.lbDescription.text = news.summary
        self.lbTags.text = news.tags
        
        if let images = news.images {
            if images.count > 0 {
                self.imgNew.sd_setImage(with: URL(string: images[0]))
            }
        }        
    }
    
}
