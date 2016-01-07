//
//  URGroupDetailsViewController.swift
//  ureport
//
//  Created by Daniel Amaral on 06/10/15.
//  Copyright © 2015 ilhasoft. All rights reserved.
//

import UIKit

class URGroupDetailsViewController: UIViewController, URChatTableViewCellDelegate {

    @IBOutlet weak var imgGroupPic: UIImageView!
    @IBOutlet weak var lbGroupTitle: UILabel!
    @IBOutlet weak var lbSubject: UILabel!
    @IBOutlet weak var lbCreatedBy: UILabel!
    @IBOutlet weak var roundedView: UIView!
    @IBOutlet weak var btAddUreporter: UIButton!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var btAddUreporterHeight: NSLayoutConstraint!
    
    var isUserAdmin:Bool!
    var listUser:[URUser] = []
    var groupChatRoom:URGroupChatRoom!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.isUserAdmin = false
        URNavigationManager.setupNavigationBarWithType(.Clear)
        setupTableView()
        setupGroupInfo()
    }

    init(groupChatRoom:URGroupChatRoom,members:[URUser]){
        self.groupChatRoom = groupChatRoom
        self.listUser = members
        super.init(nibName: "URGroupDetailsViewController", bundle: nil)
    }

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationItem.rightBarButtonItems = self.addRightBarButtons()
        
        let tracker = GAI.sharedInstance().defaultTracker
        tracker.set(kGAIScreenName, value: "Group Details")
        
        let builder = GAIDictionaryBuilder.createScreenView()
        tracker.send(builder.build() as [NSObject : AnyObject])
        
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Table view data source
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 65
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.listUser.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(NSStringFromClass(URChatTableViewCell.self), forIndexPath: indexPath) as! URChatTableViewCell
        
        cell.setupCellWithUserList(self.listUser,createGroupOption: false, myChatsMode: false, indexPath: indexPath, checkGroupOption: false)
        
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        self.view.endEditing(true)
        //        let cell = tableView.cellForRowAtIndexPath(indexPath) as! URChatTableViewCell
    }
    
    //MARK: Class Methods
    
    func addRightBarButtons() -> [UIBarButtonItem]{
        
        self.navigationItem.rightBarButtonItem = nil
        let btnInfo: UIButton = UIButton(type: UIButtonType.Custom)
        btnInfo.frame = CGRectMake(0, 0, 6, 20)
        btnInfo.setBackgroundImage(UIImage(named:"icon_overflow"), forState: UIControlState.Normal)
        btnInfo.addTarget(self, action: "openActionSheet", forControlEvents: UIControlEvents.TouchUpInside)
        let container: UIView = UIView(frame: CGRectMake(0, 0, 23, 23))
        container.addSubview(btnInfo)
//        let infoItem = UIBarButtonItem(customView: container)
        
        let infoButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.Organize, target: self, action: "openActionSheet")
        
        return [infoButtonItem]
    }
    
    func openActionSheet() {
        let alertController: UIAlertController = UIAlertController(title: nil, message: "Choose an option below", preferredStyle: .ActionSheet)
        
        let cancelAction: UIAlertAction = UIAlertAction(title: "Cancel", style: .Cancel) { action -> Void in
            
        }
        
        let leaveAction: UIAlertAction = UIAlertAction(title: isUserAdmin == true ? "Delete Group" : "Leave", style: .Default) { action -> Void in
            if self.isUserAdmin == true {
                URChatMemberManager.removeChatRoom(URUser.activeUser()!.key, chatRoomKey: self.groupChatRoom.key)
            }else {
                URChatMemberManager.removeMemberByChatRoomKey(URUser.activeUser()!.key, chatRoomKey: self.groupChatRoom.key)
            }
        }
        
        let editAction: UIAlertAction = UIAlertAction(title: "Edit", style: .Default) { action -> Void in
            URNavigationManager.navigation.pushViewController(URNewGroupViewController(groupChatRoom: self.groupChatRoom, members: self.listUser), animated: true)
        }
        
        alertController.addAction(leaveAction)
        alertController.addAction(cancelAction)
        
        if isUserAdmin == true {
            alertController.addAction(editAction)
        }
        
        URNavigationManager.navigation.presentViewController(alertController, animated: true, completion: nil)
    }
    
    private func setupTableView() {
        self.scrollView.contentInset = UIEdgeInsetsMake(-64, 0, 0, 0)
        self.tableView.backgroundColor = URConstant.Color.WINDOW_BACKGROUND
        self.tableView.separatorColor = UIColor.clearColor()
        self.tableView.registerNib(UINib(nibName: "URChatTableViewCell", bundle: nil), forCellReuseIdentifier: NSStringFromClass(URChatTableViewCell.self))
    }
    
    func setupGroupInfo() {
        
        if groupChatRoom.administrator.key == URUser.activeUser()?.key {
            self.isUserAdmin = true
        }else {
            self.btAddUreporterHeight.constant = 0
            self.btAddUreporter.hidden = true
        }
        
        self.lbGroupTitle.text = groupChatRoom.title
        self.lbSubject.text = groupChatRoom.subject
        self.lbCreatedBy.text = "\("chat_group_created".localized) \(groupChatRoom.administrator.nickname)"
        
        if let createdDate = groupChatRoom.createdDate {
             self.lbCreatedBy.text = "\( self.lbCreatedBy.text!) in \(URDateUtil.birthDayFormatterRapidPro(NSDate(timeIntervalSince1970: NSNumber(double: createdDate.doubleValue/1000) as NSTimeInterval)))"
        }
        
        if self.groupChatRoom.picture != nil && self.groupChatRoom.picture.url != nil {
            self.roundedView.backgroundColor = UIColor.whiteColor().colorWithAlphaComponent(1)
            self.imgGroupPic.contentMode = UIViewContentMode.ScaleAspectFill
            self.imgGroupPic.sd_setImageWithURL(NSURL(string: self.groupChatRoom.picture.url))
        }else {
            self.roundedView.backgroundColor = UIColor.whiteColor().colorWithAlphaComponent(0.2)
            self.imgGroupPic.image = UIImage(named: "default_group")
        }
        
    }
    
    //MARK: Button Events
    
    @IBAction func btAddUreporterTapped(sender: AnyObject) {
        URNavigationManager.navigation.pushViewController(URNewGroupViewController(groupChatRoom: self.groupChatRoom, members: self.listUser), animated: true)
    }
    
}
