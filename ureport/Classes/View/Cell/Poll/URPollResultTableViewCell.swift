//
//  URPollResultTableViewCell.swift
//  ureport
//
//  Created by Daniel Amaral on 22/09/15.
//  Copyright © 2015 ilhasoft. All rights reserved.
//

import UIKit
import TagListView

class URPollResultTableViewCell: UITableViewCell, TagListViewDelegate {

    @IBOutlet weak var lbDate: UILabel!
    @IBOutlet weak var lbTitle: UILabel!
    @IBOutlet weak var lbDetails: UILabel!
    @IBOutlet var tagView: TagListView!
    @IBOutlet var choiceView: UIView!
    @IBOutlet var containerView: UIView!
    
    var poll:URPoll!
    var pollResult:URPollResult!
    
    var viewChoiceHeight = 61
    
//    override func layoutSubviews() {
//        super.layoutSubviews()
////        self.choiceView.setNeedsLayout()
////        self.choiceView.layoutIfNeeded()
////        self.cView.layoutIfNeeded()
//    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.tagView.tagBackgroundColor = URConstant.Color.PRIMARY
        self.tagView.cornerRadius = 12
        self.tagView.marginX = 3
        self.tagView.marginY = 3
        self.tagView.paddingX = 8
        self.tagView.paddingY = 8
        self.tagView.textFont = UIFont(name: "Helvetica Neue", size: 15)!
        
        self.containerView.layer.cornerRadius = 5
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        super.selectionStyle = UITableViewCellSelectionStyle.None
    }
    
    //MARK: Class Methods
    
    func setupCellWithData(pollResult:URPollResult) {
        self.pollResult = pollResult
        self.lbDate.text = pollResult.date
        self.lbDetails.text = "\(pollResult.responded) \("responded out of".localized) \(pollResult.polled) \("polled".localized)"
        self.lbTitle.text = pollResult.title
        
        if pollResult.type == "Keywords" {
            var indexKeywords = 1
            self.tagView.hidden = false
            self.choiceView.hidden = true
            
            var results = pollResult.results
            
            if results.count > 10 {
                results.removeRange(Range(start: 10, end: pollResult.results.count))
            }
            
            self.tagView.removeAllTags()
            
            for dictionary in results {
                let tag = dictionary.objectForKey("keyword") as! String
                self.tagView.addTag("\(indexKeywords).\(tag)")
                indexKeywords++
            }
            
        } else if pollResult.type == "Choices"{
            var indexChoices = 0
            self.tagView.hidden = true
            self.choiceView.hidden = false
            
            let array = self.choiceView.subviews as [UIView];

            for view in array {
                view.removeFromSuperview()
            }
            
                for dictionary in pollResult.results {
                    let choiceResultView = NSBundle.mainBundle().loadNibNamed("URChoiceResultView", owner: 0, options: nil)[0] as? URChoiceResultView

                    choiceResultView!.frame = CGRectMake(0, CGFloat(indexChoices * viewChoiceHeight), UIScreen.mainScreen().bounds.width, CGFloat(viewChoiceHeight))
                    
                    let percent = dictionary.objectForKey("value") as? String
                    let title = dictionary.objectForKey("title") as? String
                    var color:UIColor!
                    
                    choiceResultView!.lbChoice.text = title
                    choiceResultView!.lbPercent.text = "\(percent!)%"
                    
                    if indexChoices > URPollManager.getColors().count {
                        color = UIColor.yellowColor()
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
                    
                    indexChoices++                
                }
        }
        
    }
    
}
