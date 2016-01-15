//
//  URPointsScoredViewController.swift
//  ureport
//
//  Created by Daniel Amaral on 05/10/15.
//  Copyright © 2015 ilhasoft. All rights reserved.
//

import UIKit

enum PointsScoredType {
    case Story
    case Poll
    case Contribution
}

class URPointsScoredViewController: UIViewController {

    @IBOutlet weak var backgroundView: UIView!
    @IBOutlet weak var lbYouCreated: UILabel!
    @IBOutlet weak var lbYouWent: UILabel!
    @IBOutlet weak var imgBadge: UIImageView!
    @IBOutlet weak var lbPoints: UILabel!
    @IBOutlet weak var btGoToRanking: UIButton!
    @IBOutlet weak var btClose: UIButton!
    
    var scoreType:PointsScoredType!
    
    init(scoreType:PointsScoredType){
        self.scoreType = scoreType
        super.init(nibName: "URPointsScoredViewController", bundle: nil)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.backgroundView.layer.cornerRadius = 5
        self.btGoToRanking.layer.cornerRadius = 4
        
        setupUI()
    }

    //MARK: Class Methods    
    
    func close() {
        
        UIView.animateWithDuration(0.3, animations: { () -> Void in
            self.view.backgroundColor = self.view.backgroundColor?.colorWithAlphaComponent(0)
            }) { (finished) -> Void in
                NSNotificationCenter.defaultCenter().postNotificationName("pointsScoredDidClosed", object: nil)                
                self.dismissViewControllerAnimated(true, completion: nil)
        }
        
    }
    
    func setupUI() {
        
        self.lbPoints.text = "\("points_earning_count_title".localized) +5"
        self.lbYouCreated.text = "points_earning_title".localized
        self.lbYouWent.text = "points_earning_subtitle".localized
        self.btGoToRanking.setTitle("points_earning_ranking".localized, forState: UIControlState.Normal)
        self.btClose.setTitle("points_earning_close".localized, forState: UIControlState.Normal)
        
        if scoreType == .Story {
            self.imgBadge.image = UIImage(named: "points_orange")
        }else {
            self.imgBadge.image = UIImage(named: "img_points_green")
        }
    }
    
    
    //MARK: Button Events
    
    @IBAction func btGoToRankingTapped(sender: AnyObject) {
        URNavigationManager.setupNavigationControllerWithMainViewController(URProfileViewController(enterInTabType:.Ranking))
    }
    
    @IBAction func btCloseTapped(sender: AnyObject) {
        self.close()
    }
    
}
