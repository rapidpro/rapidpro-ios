//
//  URTermsViewController.swift
//  ureport
//
//  Created by Daniel Amaral on 14/03/16.
//  Copyright © 2016 ilhasoft. All rights reserved.
//

import UIKit

protocol URTermsViewControllerDelegate {
    func userDidAcceptTerms(accept:Bool)
}

class URTermsViewController: UIViewController {
    
    @IBOutlet weak var txtTerms: UITextView!
    @IBOutlet weak var btCancel: ISRoundedButton!
    @IBOutlet weak var btAccept: ISRoundedButton!
    @IBOutlet weak var viewBackground: UIView!
    
    var delegate:URTermsViewControllerDelegate?
    
    init() {
        super.init(nibName: "URTermsViewController", bundle: nil)        
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        viewBackground.layer.cornerRadius = 20
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        self.txtTerms.scrollRangeToVisible(NSMakeRange(0, 0))
    }
    
    //MARK: Class Methods
    
    func close() {
        
        UIView.animateWithDuration(0.3, animations: { () -> Void in
            self.view.backgroundColor = self.view.backgroundColor?.colorWithAlphaComponent(0)
            }) { (finished) -> Void in
                self.dismissViewControllerAnimated(true, completion: nil)
        }
        
    }
    
    //MARK: Button Events

    @IBAction func btCancelTapped(sender: AnyObject) {
        close()
        if let delegate = self.delegate {
            delegate.userDidAcceptTerms(false)
        }
    }
    
    @IBAction func btAcceptTapped(sender: AnyObject) {
        close()
        
        let settings = URSettings.getSettings()
        settings.firstRun = false
        URSettings.saveSettingsLocaly(settings)
        
        if let delegate = self.delegate {
            delegate.userDidAcceptTerms(true)
        }
    }
}
