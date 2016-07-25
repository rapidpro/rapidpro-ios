//
//  URInviteTableViewController.swift
//  ureport
//
//  Created by Daniel Amaral on 21/08/15.
//  Copyright (c) 2015 ilhasoft. All rights reserved.
//

import UIKit
import SwiftAddressBook
import MessageUI

class URInviteTableViewController: UITableViewController, MFMessageComposeViewControllerDelegate, URInviteTableViewCellDelegate {
    
    let addressBook : SwiftAddressBook? = swiftAddressBook
    var addressBookList:[NSDictionary] = []
    let inviteMessage = "invite_message".localized
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "chat_contact_invite_button".localized
        setupTableView()
        requestAuthorizationToAddressBook()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        URNavigationManager.setupNavigationBarWithCustomColor(URCountryProgramManager.activeCountryProgram()!.themeColor!)
        
        let tracker = GAI.sharedInstance().defaultTracker
        tracker.set(kGAIScreenName, value: "Invite")
        
        let builder = GAIDictionaryBuilder.createScreenView()
        tracker.send(builder.build() as [NSObject : AnyObject])        
    }
    
    // MARK: - Table view data source
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 67
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.addressBookList.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(NSStringFromClass(URInviteTableViewCell.self), forIndexPath: indexPath) as! URInviteTableViewCell
        
        let dictionary = self.addressBookList[indexPath.row]

        cell.delegate = self
        cell.lbContactName.text = dictionary["name"] as? String
        cell.lbPhoneNumber.text = (dictionary["phone"] as! [AnyObject])[0] as? String
        
        return cell
    }
    
    //MARK: MFMessageComposeViewControllerDelegate
    
    func messageComposeViewController(controller: MFMessageComposeViewController, didFinishWithResult result: MessageComposeResult) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    //MARK: URInviteTableViewCellDelegate
    
    func inviteButtonDidTapped(cell: URInviteTableViewCell) {
        if (MFMessageComposeViewController.canSendText()) {
            let controller = MFMessageComposeViewController()
            controller.body = inviteMessage
            controller.recipients = [cell.lbPhoneNumber.text!]
            controller.messageComposeDelegate = self
            self.presentViewController(controller, animated: true, completion: nil)
        }
    }
    
    //MARK: Class Methods
    
    func requestAuthorizationToAddressBook() {

        SwiftAddressBook.requestAccessWithCompletion({ (success, error) -> Void in
            if success {
                self.readContacts()
            }else {
                print("erro on access addressbook")
            }
        })
        
    }
    
    func readContacts() {
        addressBookList = []
        if let people : [SwiftAddressBookPerson]? = swiftAddressBook?.allPeople {
            for person in people! {
                let phoneNumber = person.phoneNumbers?.map( {$0.value})
                if phoneNumber != nil && person.firstName != nil{
                    addressBookList.append(["name":person.lastName != nil ? "\(person.firstName!) \(person.lastName!)" : person.firstName!,"phone":phoneNumber!])
                }
            }
            
            addressBookList = addressBookList.sort({ (dictionary1, dictionary2) -> Bool in
                return (dictionary1["name"] as! String) < (dictionary2["name"] as! String)
            })
            
            self.tableView.reloadData()
        }
    }
    
    private func setupTableView() {
        self.tableView.contentInset = UIEdgeInsetsMake(0, 0, 49, 0);
        self.tableView.backgroundColor = UIColor.whiteColor()
        self.tableView.registerNib(UINib(nibName: "URInviteTableViewCell", bundle: nil), forCellReuseIdentifier: NSStringFromClass(URInviteTableViewCell.self))
        self.tableView.separatorColor = UIColor.clearColor()
    }

}
