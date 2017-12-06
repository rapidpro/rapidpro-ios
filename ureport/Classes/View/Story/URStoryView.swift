//
//  URStoryView.swift
//  ureport
//
//  Created by Yves Bastos on 06/12/17.
//  Copyright © 2016 ilhasoft. All rights reserved.
//

import UIKit
import AVFoundation
import MBProgressHUD

class URStoryView: UIView {
    @IBOutlet weak var holderView: UIView!
    @IBOutlet weak var storyImgView: UIImageView!
    @IBOutlet weak var storyImageHeightConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var lbBody: UILabel!
    
    @IBOutlet weak var lbAuthor: UILabel!
    @IBOutlet weak var lbDate: UILabel!
    
    @IBOutlet weak var lbOrganization: UILabel!
    @IBOutlet weak var lbCountry: UILabel!
    
    @IBOutlet weak var widthConstraint: NSLayoutConstraint!
    
    fileprivate var story: URStory?
    static let defaultWidth = UIScreen.main.bounds.width - 20

    //MARK: Init/setup
    convenience init() {
        self.init(frame: CGRect(x: 0, y: 0, width: URStoryView.defaultWidth, height: 800))
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)!
        initSubviews()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        initSubviews()
    }
    
    func initSubviews() {
        let nib = UINib(nibName: "URStoryView", bundle: Bundle(for: URStoryView.self))
        nib.instantiate(withOwner: self, options: nil)
        holderView.frame = bounds
        addSubview(holderView)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        widthConstraint.constant = URStoryView.defaultWidth
    }
    
    func setup(with story: URStory, userName: String?) {
        setNeedsDisplay()
        self.story = story
        
        lbBody.text = story.content
        lbAuthor.text = userName
        let programName = URCountryProgramManager.activeCountryProgram()?.name ?? ""
        var organization = "U-Report"
        
        var authorColor: UIColor!
        #if ONTHEMOVE
            organization = programName
            lbCountry.text = ""
            authorColor = UIColor(rgba: "#874FA0")
        #else
            lbCountry.text = programName
            authorColor = UIColor(rgba: "#1AC8D2")
        #endif
        
        lbOrganization.text = organization
        lbAuthor.textColor = authorColor
        
        if let createdDate = story.createdDate {
            let interval = Int(createdDate)
            let date =  Date(timeIntervalSince1970: TimeInterval(interval/1000))
            self.lbDate.text = "- \(URDateUtil.birthDayFormatter(date))"
        } else {
            self.lbDate.text = ""
        }
        
        if story.cover != nil && story.cover?.url != nil {
            self.storyImgView.isHidden = false
            self.storyImageHeightConstraint.constant = 188
            if story.cover?.type == URConstant.Media.VIDEOPHONE {
                self.storyImgView.sd_setImage(with: URL(string: (story.cover?.thumbnail)!))
                
            } else if story.cover?.type == URConstant.Media.PICTURE || story.cover?.type == URConstant.Media.VIDEO {
                self.storyImgView.sd_setImage(with: URL(string: (story.cover?.url)!))
            }
        } else {
            self.storyImgView.image = nil
            self.storyImgView.isHidden = true
            self.storyImageHeightConstraint.constant = 0
        }
    }
    
    //MARK: Util
    /**
     Returns the necessary height so all the content can be properly displayed. Only call this method after calling `setup(with story: URStory, userName: String?)`
     */
    func getNecessarySize() -> CGSize {
        let lines = CGFloat(lbBody.lineCount())
        let imageHeight = CGFloat(storyImageHeightConstraint.constant)
        //calculus
        //15 + imageHeight + 20 + 30 + lines*17 + 25 + 17 + 5 + 20 + 20
        let height: CGFloat = 152 + imageHeight + lines*17
        return CGSize(width: URStoryView.defaultWidth, height: height)
    }
}

extension UIImage {
    convenience init(view: UIView) {
        UIGraphicsBeginImageContextWithOptions(view.frame.size, false, 0)
        view.layer.render(in: UIGraphicsGetCurrentContext()!)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        self.init(cgImage: image!.cgImage!)
    }
}
