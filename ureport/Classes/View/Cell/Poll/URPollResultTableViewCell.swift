//
//  URPollResultTableViewCell.swift
//  ureport
//
//  Created by Daniel Amaral on 22/09/15.
//  Copyright © 2015 ilhasoft. All rights reserved.
//

import UIKit
import DBSphereTagCloud
fileprivate func < <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l < r
  case (nil, _?):
    return true
  default:
    return false
  }
}

fileprivate func > <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l > r
  default:
    return rhs < lhs
  }
}


class URPollResultTableViewCell: UITableViewCell {

    @IBOutlet weak var lbDate: UILabel!
    @IBOutlet weak var lbTitle: UILabel!
    @IBOutlet weak var lbDetails: UILabel!
    @IBOutlet var sphereView: DBSphereView!
    @IBOutlet var viewSeparator: UIView!
    @IBOutlet var choiceView: UIView!
    @IBOutlet var containerView: UIView!
    
    var poll:URPoll!
    var pollResult:URPollResult!
    
    var viewChoiceHeight = 61
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.viewSeparator.layer.cornerRadius = 5
        self.containerView.layer.cornerRadius = 5
        self.containerView.layer.borderColor = UIColor.lightGray.cgColor
        self.containerView.layer.borderWidth = 0.5
        
        let panGesture = UIPanGestureRecognizer(target: sphereView, action: #selector(DBSphereView.handlePanGesture(_:)))
        sphereView.addGestureRecognizer(panGesture)
        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        super.selectionStyle = UITableViewCellSelectionStyle.none
        self.layoutMargins = UIEdgeInsets.zero
        self.separatorInset = UIEdgeInsets.zero
    }
    
    //MARK: Class Methods
    
    func setupCellWithData(_ pollResult:URPollResult) {
        self.pollResult = pollResult
        self.lbDate.text = pollResult.date
        self.lbDetails.text = String(format: "polls_responded_info".localized, arguments: [pollResult.responded,pollResult.polled])
        self.lbTitle.text = pollResult.title
                
        if pollResult.type == "Keywords" {
            var indexKeywords = 1
            self.sphereView.isHidden = false
            self.choiceView.isHidden = true
            var tagList = [UIButton]()
            var results = pollResult.results
            
            if results?.count > 10 {
                results.removeSubrange((10 ..< pollResult.results.count))
            }
            
            for view in sphereView.subviews {
                view.removeFromSuperview()
            }
            
            for dictionary in results! {
                let tagSize = CGFloat(150 - (indexKeywords * 5))
                let tag = dictionary.object(forKey: "keyword") as! String
                let btnTag = UIButton(frame: CGRect(x: 0, y: 0, width: tagSize, height: tagSize))
                btnTag.layer.cornerRadius = tagSize/2
                btnTag.backgroundColor = URConstant.Color.PRIMARY
                let buttonTitle = "\(indexKeywords). \(tag)"
                btnTag.setTitle(buttonTitle, for: UIControlState())
                btnTag.titleLabel!.numberOfLines = 2
                btnTag.titleLabel!.lineBreakMode = NSLineBreakMode.byClipping
                tagList.append(btnTag)
                sphereView.addSubview(btnTag)
                indexKeywords += 1
            }
            
            sphereView.setCloudTags(tagList)
            
        } else if pollResult.type == "Choices"{
            var indexChoices = 0
            self.sphereView.isHidden = true
            self.choiceView.isHidden = false
            
            let array = self.choiceView.subviews as [UIView];

            for view in array {
                view.removeFromSuperview()
            }
            
                for dictionary in pollResult.results {
                    let choiceResultView = Bundle.main.loadNibNamed("URChoiceResultView", owner: 0, options: nil)?[0] as? URChoiceResultView

                    choiceResultView!.frame = CGRect(x: 0, y: CGFloat(indexChoices * viewChoiceHeight), width: UIScreen.main.bounds.width, height: CGFloat(viewChoiceHeight))
                    
                    let percent = dictionary.object(forKey: "value") as? String
                    let title = dictionary.object(forKey: "title") as? String
                    var color:UIColor!
                    
                    choiceResultView!.lbChoice.text = title
                    choiceResultView!.lbPercent.text = "\(percent!)%"
                    
                    if indexChoices >= URPollManager.getColors().count {
                        color = UIColor.yellow
                    }else {
                        color = UIColor(rgba:URPollManager.getColors()[indexChoices])
                    }
                    
                    choiceResultView!.viewPercent.backgroundColor = color
                    
                    let maxWidth = self.contentView.frame.size.width
                    var widthCell:CGFloat = self.contentView.frame.size.width   
                    
                    if Int(percent!) > 80 {
                        widthCell = maxWidth - 70
                    }
                    
                    let percentValue = Float(percent!)
                    
                    self.choiceView.addSubview(choiceResultView!)
                    choiceResultView!.viewPercentWidth.constant = (CGFloat(percentValue!/100)) * widthCell
                    
                    indexChoices += 1                
                }
        }
        
    }
    
}
