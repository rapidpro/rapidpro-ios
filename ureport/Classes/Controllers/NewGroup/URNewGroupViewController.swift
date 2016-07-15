//
//  URNewGroupViewController.swift
//  ureport
//
//  Created by Daniel Amaral on 30/08/15.
//  Copyright (c) 2015 ilhasoft. All rights reserved.
//

import UIKit
import AWSS3

class URNewGroupViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate, UIActionSheetDelegate, URChatTableViewCellDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    @IBOutlet weak var viewTitleGroup: UIView!
    @IBOutlet weak var txtTitleGroup: UITextField!
    @IBOutlet weak var txtDescriptionGroup: UITextField!
    @IBOutlet weak var viewDescriptionGroup: UIView!
    @IBOutlet weak var lbPrivateGroup: UILabel!
    @IBOutlet weak var btAddPicture: UIButton!
    @IBOutlet weak var imgPicture: UIImageView!
    @IBOutlet weak var privateGroupSwitch: UISwitch!
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var scrollView: UIScrollView!
    var actionSheetPicture: UIActionSheet!
    
    var listUserSelectedToGroup:[URUser] = []
    var listUser:[URUser] = []
    var listMembers:[URUser] = []
    var listUserAux:[URUser] = []
    
    var groupChatRoom:URGroupChatRoom!
    
    init(groupChatRoom:URGroupChatRoom,members:[URUser]) {
        print(groupChatRoom.key)
        self.groupChatRoom = groupChatRoom
        self.listMembers = members
        super.init(nibName: "URNewGroupViewController", bundle: nil)
    }

    init() {
        super.init(nibName: "URNewGroupViewController", bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupActionSheet()
        setupUI()
        setupUIWithDatasIfPossible()
        self.tableView.registerNib(UINib(nibName: "URChatTableViewCell", bundle: nil), forCellReuseIdentifier: NSStringFromClass(URChatTableViewCell.self))
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        URNavigationManager.setupNavigationBarWithType(.Clear)
        
        let tracker = GAI.sharedInstance().defaultTracker
        tracker.set(kGAIScreenName, value: "Group Creation")
        
        let builder = GAIDictionaryBuilder.createScreenView()
        tracker.send(builder.build() as [NSObject : AnyObject])
        
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        setupTableView()
    }
    
    override func viewDidDisappear(animated: Bool) {
        super.viewDidDisappear(animated)
        ProgressHUD.dismiss()
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
        
        cell.delegate = self
        cell.setupCellWithUser(self.listUser[indexPath.row],createGroupOption: false, myChatsMode: false, indexPath: indexPath, checkGroupOption: true)
        
        let filtered = self.listUserSelectedToGroup.filter {
            return $0.key == self.listUser[indexPath.row].key
        }
        if !filtered.isEmpty {
            cell.setBtCheckSelected(true)
        }else{
            cell.setBtCheckSelected(false)
        }
        
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        self.view.endEditing(true)        
        let cell = tableView.cellForRowAtIndexPath(indexPath) as! URChatTableViewCell
        self.userSelected(cell.user!)
    }
    
    //MARK: Class Methods
    
    func removeMySelfFromMembers() {
        
        let filteredUserSelectedToGroup = self.listUserSelectedToGroup.filter {
            return $0.key != URUser.activeUser()!.key
        }
        
        let filteredUser = self.listUser.filter {
            return $0.key != URUser.activeUser()!.key
        }
        
        self.listUserSelectedToGroup = filteredUserSelectedToGroup
        self.listUser = filteredUser
        self.listUserAux = listUser
        self.tableView.reloadData()
    }
    
    func setupUIWithDatasIfPossible() {
        if groupChatRoom != nil {
            
            self.txtTitleGroup.text = groupChatRoom.title
            self.txtDescriptionGroup.text = groupChatRoom.subject
            self.privateGroupSwitch.on = groupChatRoom.privateAccess.boolValue
            
            if groupChatRoom.picture != nil && groupChatRoom.picture.url != nil {
                imgPicture.sd_setImageWithURL(NSURL(string: groupChatRoom.picture.url))
            }
            
            self.listUser = []
            
            URUserManager.getAllUserByCountryProgram({ (users) -> Void in
                self.listUser = users!
                
                for user in self.listMembers {
                    self.userSelected(user)
                }
                
                self.removeMySelfFromMembers()
                
            })
        }
    }
    
    func setupActionSheet() {
        actionSheetPicture = UIActionSheet(title: "title_media_source".localized, delegate: self, cancelButtonTitle: "cancel_dialog_button".localized, destructiveButtonTitle: nil, otherButtonTitles: "choose_camera".localized, "choose_take_picture".localized)
    }
    
    func setupUI() {
        
        self.txtTitleGroup.placeholder = "chat_group_title_hint".localized
        self.txtDescriptionGroup.placeholder = "chat_group_description_hint".localized
        self.lbPrivateGroup.text = "chat_private_group_title".localized
            
        txtTitleGroup.setValue(UIColor.whiteColor(), forKeyPath: "_placeholderLabel.textColor")
        txtDescriptionGroup.setValue(UIColor.whiteColor(), forKeyPath: "_placeholderLabel.textColor")
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "label_save".localized, style: UIBarButtonItemStyle.Done, target: self, action: #selector(newGroup))
    }
    
    func newGroup() {
        
        if let textfield = self.view.findTextFieldEmptyInView(self.view) {
            UIAlertView(title: nil, message: "\(textfield.placeholder!) is empty", delegate: self, cancelButtonTitle: "OK").show()
            return
        }
        
        if listUserSelectedToGroup.isEmpty {
            UIAlertView(title: nil, message: "group_no_user".localized, delegate: self, cancelButtonTitle: "OK").show()
            return
        }

        if listUserSelectedToGroup.count < 2 {
            UIAlertView(title: nil, message: "group_min_user".localized, delegate: self, cancelButtonTitle: "OK").show()
            return
        }
        
//        if imgPicture.image == nil {
//            UIAlertView(title: nil, message: "A group must have a picture", delegate: self, cancelButtonTitle: "OK").show()
//            return
//        }
        
        if imgPicture.image != nil {
            ProgressHUD.show(nil)
            URAWSManager.uploadImage(imgPicture.image!, uploadPath:.Chat, completion: { (picture:URMedia?) -> Void in
                self.save(picture)
            })
        }else {
            self.save(nil)
        }
    }
    
    func save(picture:URMedia?) {
        
        let groupChatRoom = URGroupChatRoom()
        groupChatRoom.title = self.txtTitleGroup.text
        groupChatRoom.subject = self.txtDescriptionGroup.text
        groupChatRoom.privateAccess = self.privateGroupSwitch.on
        groupChatRoom.administrator = URUser.activeUser()
        
        groupChatRoom.createdDate = self.groupChatRoom != nil && self.groupChatRoom.createdDate != nil && self.groupChatRoom.createdDate.integerValue > 0 ? self.groupChatRoom.createdDate : NSNumber(longLong:Int64(NSDate().timeIntervalSince1970 * 1000))
        groupChatRoom.type = "Group"
        
        if let pic = picture {
            groupChatRoom.picture = pic
        }

        self.listUserSelectedToGroup += [URUser.activeUser()!]
        
        let main = URMainViewController()
        URNavigationManager.addLeftButtonMenuInViewController(main)
        
        if self.groupChatRoom == nil {
            
            URChatRoomManager.save(groupChatRoom, members: self.listUserSelectedToGroup) { (chatRoom:URChatRoom) -> Void in
                ProgressHUD.show(nil)
                URNavigationManager.navigation.setViewControllers([main,URMessagesViewController(chatRoom: chatRoom, chatMembers: self.listUserSelectedToGroup,title: groupChatRoom.title)], animated: true)
            }
        }else {
            groupChatRoom.key = self.groupChatRoom.key
            URChatRoomManager.update(groupChatRoom, newMembers: self.listUserSelectedToGroup) { (chatRoom:URChatRoom) -> Void in
                ProgressHUD.show(nil)
                URNavigationManager.navigation.setViewControllers([main,URMessagesViewController(chatRoom: groupChatRoom, chatMembers: self.listUserSelectedToGroup,title: groupChatRoom.title)], animated: true)
            }
        }

    }

    private func setupTableView() {
        self.scrollView.contentInset = UIEdgeInsetsMake(0, 0.0, self.tabBarController != nil ? CGRectGetHeight(self.tabBarController!.tabBar.frame) : 0.0, 0.0);
        self.tableView.backgroundColor = UIColor.groupTableViewBackgroundColor()
        self.tableView.separatorColor = UIColor.clearColor()
    }
    
    //MARK: UIActionSheetDelegate
    
    func actionSheet(actionSheet: UIActionSheet, clickedButtonAtIndex buttonIndex: Int) {

        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        
        switch buttonIndex {
            
            case 0:
                print("cancel")
                break;
            case 1:
                
                imagePicker.allowsEditing = false;
                imagePicker.sourceType = .PhotoLibrary
                
                self.presentViewController(imagePicker, animated: true) { () -> Void in
                    
                }
                break;
            case 2:

                imagePicker.sourceType = .Camera
                imagePicker.cameraCaptureMode = UIImagePickerControllerCameraCaptureMode.Photo
                imagePicker.showsCameraControls = true
                imagePicker.allowsEditing = true
                
                self.presentViewController(imagePicker, animated: true) { () -> Void in
                    
                }
                
                break;
            default:
                print("Default")
                break;
                
        }
        
    }
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        if let pickedImage = info[UIImagePickerControllerOriginalImage] as? UIImage {
            imgPicture.image = pickedImage
        }
        
        dismissViewControllerAnimated(true, completion: nil)
    }

    //MARK: SearchBarDelegate
    
    func searchBar(searchBar: UISearchBar, textDidChange searchText: String) {
        if !searchText.isEmpty {
            listUser = listUser.filter({user in
                if user.nickname.rangeOfString(searchText) != nil {
                    return true
                }else {
                    return false
                }
            })
        }else {
            listUser = listUserAux
        }
     
        self.tableView.reloadData()
        
    }
    
    //MARK: URChatTableViewCellDelegate
    
    func userSelected(user: URUser) {
        
        self.view.endEditing(true)
        
        let filtered = listUserSelectedToGroup.filter {
            return $0.key == user.key
        }
        
        if !filtered.isEmpty {
            listUserSelectedToGroup.removeAtIndex(listUserSelectedToGroup.indexOf(filtered[0])!)
        }else{
            listUserSelectedToGroup.append(user)
        }
        
        self.tableView.reloadData()
        
    }
    
    //MARK: Button Events
    
    @IBAction func btAddPictureTapped(sender: AnyObject) {
        actionSheetPicture.showInView(self.view)
    }
    
}
