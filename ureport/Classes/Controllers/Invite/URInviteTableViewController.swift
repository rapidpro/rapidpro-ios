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
    let inviteMessage = "invite_contact_text".localized
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "chat_contact_invite_button".localized
        setupTableView()
        requestAuthorizationToAddressBook()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        URNavigationManager.setupNavigationBarWithCustomColor(URCountryProgramManager.activeCountryProgram()!.themeColor!)
        
        let tracker = GAI.sharedInstance().defaultTracker
        tracker?.set(kGAIScreenName, value: "Invite")
        
        if let builder = GAIDictionaryBuilder.createScreenView().build() as? [AnyHashable: Any] {
            tracker?.send(builder)
        }
    }
    
    // MARK: - Table view data source
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 67
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.addressBookList.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: NSStringFromClass(URInviteTableViewCell.self), for: indexPath) as! URInviteTableViewCell
        
        let dictionary = self.addressBookList[(indexPath as NSIndexPath).row]

        cell.delegate = self
        cell.lbContactName.text = dictionary["name"] as? String
        cell.lbPhoneNumber.text = (dictionary["phone"] as! [AnyObject])[0] as? String
        
        return cell
    }
    
    //MARK: MFMessageComposeViewControllerDelegate
    
    func messageComposeViewController(_ controller: MFMessageComposeViewController, didFinishWith result: MessageComposeResult) {
        self.dismiss(animated: true, completion: nil)
    }
    
    //MARK: URInviteTableViewCellDelegate
    
    func inviteButtonDidTapped(_ cell: URInviteTableViewCell) {
        if (MFMessageComposeViewController.canSendText()) {
            let controller = MFMessageComposeViewController()
            controller.body = inviteMessage
            controller.recipients = [cell.lbPhoneNumber.text!]
            controller.messageComposeDelegate = self
            self.present(controller, animated: true, completion: nil)
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
            
            addressBookList = addressBookList.sorted(by: { (dictionary1, dictionary2) -> Bool in
                return (dictionary1["name"] as! String) < (dictionary2["name"] as! String)
            })
            
            self.tableView.reloadData()
        }
    }
    
    fileprivate func setupTableView() {
        self.tableView.contentInset = UIEdgeInsetsMake(0, 0, 49, 0);
        self.tableView.backgroundColor = UIColor.white
        self.tableView.register(UINib(nibName: "URInviteTableViewCell", bundle: nil), forCellReuseIdentifier: NSStringFromClass(URInviteTableViewCell.self))
        self.tableView.separatorColor = UIColor.clear
    }

}
