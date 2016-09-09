//
//  ISMenuViewController.swift
//  TimeDePrimeira
//
//  Created by Daniel Amaral on 29/07/15.
//  Copyright (c) 2015 ilhasoft. All rights reserved.
//

import UIKit
import FBSDKLoginKit
import MBProgressHUD

class ISMenuViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UIPickerViewDelegate, UIPickerViewDataSource {
    
    @IBOutlet weak var lbStoriesAndPolls: UILabel!
    @IBOutlet weak var lbPoints: UILabel!
    @IBOutlet weak var lbNickName: UILabel!
    @IBOutlet weak var topView: UIView!
    @IBOutlet weak var roundedView: ISRoundedView!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var txtSwitchCountryProgram: UITextField!
    @IBOutlet weak var imgProfile: UIImageView!
    @IBOutlet weak var bgImageProfile: UIImageView!
    @IBOutlet weak var btLogin: UIButton!
        
    var countryProgramChanged:URCountryProgram!
    var user:URUser!
    var appDelegate:AppDelegate!
    var menuList:[ISMenu] = []
    
    var pickerCountryProgram:UIPickerView?
//    let countries:[URCountry]? = URCountry.getCountries(URCountryCodeType.ISO3) as? [URCountry]
    let countryPrograms:[URCountryProgram] = URCountryProgramManager.getAvailableCountryPrograms()
    var country = URCountry()
    
    static let instance = ISMenuViewController(nibName:"ISMenuViewController",bundle:nil)
    
    class func sharedInstance() -> ISMenuViewController{
        return instance
    }
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: NSBundle?) {
        super.init(nibName: "ISMenuViewController", bundle: nil)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupMenu()
        setupTableViewCell()
        setupGestureRecognizer()
        self.txtSwitchCountryProgram.tintColor = UIColor.clearColor()
        self.txtSwitchCountryProgram.textColor = URConstant.Color.PRIMARY
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(keyboardHideNotification(_:)), name:   UIKeyboardWillHideNotification, object: nil);
        self.appDelegate = (UIApplication.sharedApplication().delegate as! AppDelegate)
    }    

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.topView.backgroundColor = URCountryProgramManager.activeCountryProgram()?.themeColor!
        loadUserInfo()
        
        let tracker = GAI.sharedInstance().defaultTracker
        tracker.set(kGAIScreenName, value: "Menu")
        
        let builder = GAIDictionaryBuilder.createScreenView()
        tracker.send(builder.build() as [NSObject : AnyObject])
    }
    
    // MARK: - Table view data source
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.menuList.count
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 55
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(NSStringFromClass(ISMenuTableViewCell.self), forIndexPath: indexPath) as! ISMenuTableViewCell
        let menu:ISMenu! = self.menuList[indexPath.row]

        cell.setupCellWith(menu)
        
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let cell = tableView.cellForRowAtIndexPath(indexPath) as! ISMenuTableViewCell
        let menu = cell.menu
        
        switch menu!.menuItem as URMenuItem {
        case .Main:
            URNavigationManager.toggleMenu()
            URNavigationManager.setFrontViewController(URMainViewController.sharedInstance)
            break
        case .About:
            URNavigationManager.toggleMenu()
            URNavigationManager.setFrontViewController(URAboutViewController())
            break
        case .Settings:
            
            let settingsTableViewController = URSettingsTableViewController()
            
            if !URConstant.isIpad {
                URNavigationManager.toggleMenu()
                URNavigationManager.setFrontViewController(settingsTableViewController)
            }else{
                settingsTableViewController.view.backgroundColor = UIColor.whiteColor()
                var popOverViewController = UIPopoverController(contentViewController: settingsTableViewController)
                
                popOverViewController = UIPopoverController(contentViewController: settingsTableViewController)
                popOverViewController.popoverContentSize = CGSize(width: 320, height: 300)
                
                var frame = cell.frame
                frame.origin.x = frame.origin.x - 50
                
                popOverViewController.presentPopoverFromRect(frame, inView: self.tableView, permittedArrowDirections: UIPopoverArrowDirection.Any, animated: true)
            }
            break
        case .Moderation:
            
            if URUser.activeUser()!.masterModerator != nil && URUser.activeUser()!.masterModerator == true {
                URNavigationManager.setFrontViewController(URModerationViewController())
            }else if URUser.activeUser()!.moderator != nil && URUser.activeUser()!.moderator == true {
                let storyModerationViewController = URStoriesTableViewController(filterStoriesToModerate: true)
                storyModerationViewController.title = "stories_moderation".localized
                URNavigationManager.setFrontViewController(URStoriesTableViewController(filterStoriesToModerate: true))
            }
            else if URUserManager.isUserInYourOwnCountryProgram() == false {
                UIAlertView(title: nil, message: "feature_without_permission".localized, delegate: self, cancelButtonTitle: "Ok").show()
            }
            
            break
        case .Logout:
            URUserLoginManager.logoutFromSocialNetwork()
            URNavigationManager.toggleMenu()
            URUser.deactivateUser()
            URNavigationManager.setupNavigationControllerWithLoginViewController()
            
            break
        }
        
        
    }
    
    //MARK: TextFieldDelegate
    
    func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool {
        return false
    }
    
    //MARK: Picker DataSource and Delegate
    
    func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return countryPrograms.count
    }
    
    func pickerView(pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return countryPrograms[row].name
    }
    
    func pickerView(pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        countryProgramChanged = self.countryPrograms[row] 
        txtSwitchCountryProgram.text = countryProgramChanged.name!
    }
    
    
    //MARK: Button Events
    
    @IBAction func btLoginTapped(sender: AnyObject) {
        URNavigationManager.setupNavigationControllerWithLoginViewController()
    }
    
    //MARK: Class Methods
    
    func setupGestureRecognizer() {
        let gesture = UITapGestureRecognizer(target: self, action: #selector(openProfile))
        gesture.numberOfTapsRequired = 1
        self.topView.addGestureRecognizer(gesture)
    }
    
    func openProfile() {
        if let _ = URUser.activeUser() {
            URNavigationManager.setupNavigationControllerWithMainViewController(URProfileViewController(enterInTabType:.MyStories))
        }else {
            URLoginAlertController.show(self)
        }
    }
    
    func keyboardHideNotification(notification: NSNotification) {
        if let countryProgram = countryProgramChanged {
            checkIfIsADifferentCountryProgram(countryProgram)
        }
    }
    
    func checkIfIsADifferentCountryProgram(countryProgram:URCountryProgram) {
        if URCountryProgramManager.activeCountryProgram()?.code != countryProgram.code {
            URCountryProgramManager.setSwitchActiveCountryProgram(countryProgram)
            
            
            URNavigationManager.setupNavigationControllerWithMainViewController(URMainViewController())
            
        }
    }
    
    func setupUI() {
        
        self.btLogin.setTitle("login_now".localized, forState: UIControlState.Normal)
        
        self.pickerCountryProgram = UIPickerView()
        self.pickerCountryProgram!.backgroundColor = UIColor.whiteColor()
        self.pickerCountryProgram!.dataSource = self
        self.pickerCountryProgram!.delegate = self
        self.pickerCountryProgram!.showsSelectionIndicator = true
        self.txtSwitchCountryProgram.inputView = self.pickerCountryProgram
        self.txtSwitchCountryProgram.attributedPlaceholder = NSAttributedString(string: "switch_country_program".localized, attributes: [NSForegroundColorAttributeName: URConstant.Color.PRIMARY])
        
        self.btLogin.layer.cornerRadius = 4
        self.roundedView.layer.borderWidth = 2
        self.roundedView.layer.borderColor = UIColor.whiteColor().CGColor
    }
    
    func loadUserInfo() {
        
        self.lbPoints.text = String(format: "menu_points".localized, arguments: [0])
        self.lbStoriesAndPolls.text = String(format: "profile_stories".localized, arguments: [0])
        
        if let user = URUser.activeUser() {
            self.user = user
            
            self.lbNickName.text = user.nickname
            
            if let points = user.points {
                self.lbPoints.text = String(format: "menu_points".localized, arguments: [Int(points)])
            }
            
            if let stories = user.stories {
                self.lbStoriesAndPolls.text = String(format: "profile_stories".localized, arguments: [Int(stories)])
            }
            
            if let polls = user.polls {
                self.lbStoriesAndPolls.text = "\(self.lbStoriesAndPolls.text!) \(String(format: "profile_polls".localized, arguments: [Int(polls)]))"
            }
            
            if let picture = user.picture {
                self.roundedView.backgroundColor = UIColor.whiteColor().colorWithAlphaComponent(1)
                self.imgProfile.sd_setImageWithURL(NSURL(string: picture))
                self.bgImageProfile.contentMode = UIViewContentMode.ScaleAspectFill
                self.bgImageProfile.sd_setImageWithURL(NSURL(string: picture))
            }else{
                setupUserImageAsDefault()
            }
            
            self.lbStoriesAndPolls.hidden = false
            self.lbPoints.hidden = false
            self.lbNickName.hidden = false
            self.btLogin.hidden = true
        }else {
            self.lbStoriesAndPolls.hidden = true
            self.lbPoints.hidden = true
            self.lbNickName.hidden = true
            self.btLogin.hidden = false
            
            setupUserImageAsDefault()
        }
        
        self.txtSwitchCountryProgram.text = (URCountryProgramManager.activeCountryProgram()!.name!)
        
    }
    
    func setupUserImageAsDefault() {
        self.roundedView.backgroundColor = UIColor.grayColor().colorWithAlphaComponent(0.2)
        self.imgProfile.contentMode = UIViewContentMode.ScaleAspectFill
        self.imgProfile.image = UIImage(named: "ic_person")
    }
    
    private func setupMenu() {
        
        var menuItem1,menuItem2,menuItem3,menuItem4,menuItem5:ISMenu?
        
        menuItem1 = ISMenu()
        menuItem1?.title = URMenuItem.Main.rawValue.localized
        menuItem1?.menuItem = .Main
        
        menuList.append(menuItem1!)
        
        menuItem2 = ISMenu()
        menuItem2?.title = URMenuItem.About.rawValue.localized
        menuItem2?.menuItem = .About
        
        menuList.append(menuItem2!)
        
        if URUser.activeUser() != nil && URUserManager.userHasPermissionToAccessTheFeature(true) == true {
            menuItem3 = ISMenu()
            menuItem3!.title = URMenuItem.Moderation.rawValue.localized
            menuItem3!.menuItem = .Moderation
            menuList.append(menuItem3!)
        }
        
        menuItem4 = ISMenu()
        menuItem4?.title = URMenuItem.Settings.rawValue.localized
        menuItem4!.menuItem = .Settings

        menuList.append(menuItem4!)
        
        menuItem5 = ISMenu()
        menuItem5?.title = URMenuItem.Logout.rawValue.localized
        menuItem5!.menuItem = .Logout
        
        menuList.append(menuItem5!)
        
    }
    
    private func setupTableViewCell() {
        self.tableView.registerNib(UINib(nibName: "ISMenuTableViewCell", bundle: nil), forCellReuseIdentifier: NSStringFromClass(ISMenuTableViewCell.self))
        self.tableView.separatorColor = UIColor.clearColor()
    }
}
