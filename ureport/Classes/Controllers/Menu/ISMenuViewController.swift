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
    
    var lastCountryProgramIndexSelected = 0
    
    var pickerCountryProgram:UIPickerView?
//    let countries:[URCountry]? = URCountry.getCountries(URCountryCodeType.ISO3) as? [URCountry]
    let countryPrograms:[URCountryProgram] = URCountryProgramManager.getAvailableCountryPrograms()
    var country = URCountry()
    
    static let instance = ISMenuViewController(nibName:"ISMenuViewController",bundle:nil)
    
    class func sharedInstance() -> ISMenuViewController{
        return instance
    }
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
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
        self.txtSwitchCountryProgram.tintColor = UIColor.clear
        self.txtSwitchCountryProgram.textColor = URConstant.Color.PRIMARY
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardHideNotification(_:)), name:   NSNotification.Name.UIKeyboardWillHide, object: nil);
        self.appDelegate = (UIApplication.shared.delegate as! AppDelegate)
    }    

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.topView.backgroundColor = URCountryProgramManager.activeCountryProgram()?.themeColor!
        loadUserInfo()
        
        let tracker = GAI.sharedInstance().defaultTracker
        tracker?.set(kGAIScreenName, value: "Menu")
        
        let builder = GAIDictionaryBuilder.createScreenView().build()
        tracker?.send(builder as [NSObject : AnyObject]!)
    }
    
    // MARK: - Table view data source
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.menuList.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 55
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: NSStringFromClass(ISMenuTableViewCell.self), for: indexPath) as! ISMenuTableViewCell
        let menu:ISMenu! = self.menuList[(indexPath as NSIndexPath).row]

        cell.setupCellWith(menu)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath) as! ISMenuTableViewCell
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
                settingsTableViewController.view.backgroundColor = UIColor.white
                var popOverViewController = UIPopoverController(contentViewController: settingsTableViewController)
                
                popOverViewController = UIPopoverController(contentViewController: settingsTableViewController)
                popOverViewController.contentSize = CGSize(width: 320, height: 300)
                
                var frame = cell.frame
                frame.origin.x = frame.origin.x - 50
                
                popOverViewController.present(from: frame, in: self.tableView, permittedArrowDirections: UIPopoverArrowDirection.any, animated: true)
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
    
    func textField(_ textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool {
        return false
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        if textField == self.txtSwitchCountryProgram {
            self.pickerCountryProgram!.selectRow(lastCountryProgramIndexSelected, inComponent: 0, animated: true)
        }
    }
    
    //MARK: Picker DataSource and Delegate
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return countryPrograms.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return countryPrograms[row].name
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        self.lastCountryProgramIndexSelected = row
        countryProgramChanged = self.countryPrograms[row] 
        txtSwitchCountryProgram.text = countryProgramChanged.name!
    }
    
    
    //MARK: Button Events
    
    @IBAction func btLoginTapped(_ sender: AnyObject) {
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
            URNavigationManager.setupNavigationControllerWithMainViewController(URProfileViewController(enterInTabType:.myStories))
        }else {
            URLoginAlertController.show(self)
        }
    }
    
    func keyboardHideNotification(_ notification: Notification) {
        if let countryProgram = countryProgramChanged {
            checkIfIsADifferentCountryProgram(countryProgram)
        }
    }
    
    func checkIfIsADifferentCountryProgram(_ countryProgram:URCountryProgram) {
        if URCountryProgramManager.activeCountryProgram()?.code != countryProgram.code {
            URCountryProgramManager.setSwitchActiveCountryProgram(countryProgram)
            
            
            URNavigationManager.setupNavigationControllerWithMainViewController(URMainViewController())
            
        }
    }
    
    func setupUI() {
        
        self.btLogin.setTitle("login_now".localized, for: UIControlState())
        
        self.pickerCountryProgram = UIPickerView()
        self.pickerCountryProgram!.backgroundColor = UIColor.white
        self.pickerCountryProgram!.dataSource = self
        self.pickerCountryProgram!.delegate = self
        self.pickerCountryProgram!.showsSelectionIndicator = true
        self.txtSwitchCountryProgram.inputView = self.pickerCountryProgram
        self.txtSwitchCountryProgram.attributedPlaceholder = NSAttributedString(string: "switch_country_program".localized, attributes: [NSForegroundColorAttributeName: URConstant.Color.PRIMARY])
        
        self.btLogin.layer.cornerRadius = 4
        self.roundedView.layer.borderWidth = 2
        self.roundedView.layer.borderColor = UIColor.white.cgColor
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
                self.roundedView.backgroundColor = UIColor.white.withAlphaComponent(1)
                self.imgProfile.contentMode = UIViewContentMode.scaleAspectFill
                self.imgProfile.sd_setImage(with: URL(string: picture))
                self.bgImageProfile.contentMode = UIViewContentMode.scaleAspectFill
                self.bgImageProfile.sd_setImage(with: URL(string: picture))
            }else{
                setupUserImageAsDefault()
            }
            
            self.lbStoriesAndPolls.isHidden = false
            self.lbPoints.isHidden = false
            self.lbNickName.isHidden = false
            self.btLogin.isHidden = true
        }else {
            self.lbStoriesAndPolls.isHidden = true
            self.lbPoints.isHidden = true
            self.lbNickName.isHidden = true
            self.btLogin.isHidden = false
            
            setupUserImageAsDefault()
        }
        
        self.txtSwitchCountryProgram.text = (URCountryProgramManager.activeCountryProgram()!.name!)
        if !countryPrograms.isEmpty {
            lastCountryProgramIndexSelected = self.countryPrograms.index(where: {$0.code == URCountryProgramManager.activeCountryProgram()?.code})!
        }
    }
    
    func setupUserImageAsDefault() {
        self.roundedView.backgroundColor = UIColor.gray.withAlphaComponent(0.2)
        self.imgProfile.contentMode = UIViewContentMode.center
        self.imgProfile.image = UIImage(named: "ic_person")
    }
    
    fileprivate func setupMenu() {
        
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
    
    fileprivate func setupTableViewCell() {
        self.tableView.register(UINib(nibName: "ISMenuTableViewCell", bundle: nil), forCellReuseIdentifier: NSStringFromClass(ISMenuTableViewCell.self))
        self.tableView.separatorColor = UIColor.clear
    }
}
