//
//  URPollQuestionViewController.swift
//  ureport
//
//  Created by Daniel Amaral on 10/09/15.
//  Copyright (c) 2015 ilhasoft. All rights reserved.
//

import UIKit

class URPollQuestionViewController: UIViewController, URRapidProManagerDelegate {

    @IBOutlet weak var lbWelcome: UILabel!
    @IBOutlet weak var lbQuestion: UILabel!
    @IBOutlet weak var txtFieldAnswer: UITextField!    
    @IBOutlet weak var btSeePollsResults: UIButton!
    @IBOutlet weak var lbLastestResults: UILabel!
    @IBOutlet weak var scrollView: UIScrollView!
    
    var rapidProManager = URRapidProManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupWelcomeMessage()
        rapidProManager.getPollMessage()
        rapidProManager.delegate = self
    }    

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        URNavigationManager.setupNavigationBarWithType(.clear)
    }
    
    //MARK: Class Methods
    
    func setupWelcomeMessage() {
        self.lbWelcome.text = "\("Hi".localized) \(URUser.activeUser()!.nickname)"
        self.lbQuestion.alpha = 1
        self.lbQuestion.text = "poll_message".localized
        
    }
    
    func setupUI() {
        self.btSeePollsResults.layer.cornerRadius = 4
        self.scrollView.contentInset = UIEdgeInsets(top: -64, left: 0, bottom: 49, right: 0)
    }
    
    //MARK: Button Events
    
    @IBAction func btSeePollsResultsTapped(_ sender: AnyObject) {
        self.navigationController?.pushViewController(URClosedPollTableViewController(), animated: true)
    }
        
    //MARK: TextFieldDelegate
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {   //delegate method
        textField.resignFirstResponder()
        
        if !textField.text!.isEmpty {
            URRapidProManager.sendPollResponse(textField.text)
            textField.text = ""
        }
        
        return true
    }
    
    //MARK: RapidProManagerDelegate
    
    func newMessageReceived(_ message: String) {
        
        UIView.animate(withDuration: 0.5, delay: 0.5, options: UIViewAnimationOptions.curveEaseOut, animations: {
            self.lbQuestion.alpha = 1.0
        }, completion:nil)
        
        self.lbQuestion.text = message
    }
    
}
