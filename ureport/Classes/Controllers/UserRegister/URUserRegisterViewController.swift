//
//  URUserRegisterViewController.swift
//  ureport
//
//  Created by Daniel Amaral on 07/07/15.
//  Copyright (c) 2015 ilhasoft. All rights reserved.
//

import UIKit
import Firebase
import Alamofire
import IlhasoftCore
import MBProgressHUD

class URUserRegisterViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource, ISTermsViewControllerDelegate {
    
    @IBOutlet weak var viewPassword: UIView!
    @IBOutlet weak var viewNick: UIView!
    @IBOutlet weak var viewEmail: UIView!
    @IBOutlet weak var viewBirthDay: UIView!
    @IBOutlet weak var viewDistrict: UIView!
    @IBOutlet weak var viewCountry: UIView!
    @IBOutlet weak var viewGender: UIView!
    @IBOutlet weak var btNext: UIButton!
    @IBOutlet weak var txtPassword: UITextField!
    @IBOutlet weak var txtNick: UITextField!
    @IBOutlet weak var txtEmail: UITextField!
    @IBOutlet weak var txtBirthDay: UITextField!
    @IBOutlet weak var txtCountry: UITextField!
    @IBOutlet weak var txtGender: UITextField!
    @IBOutlet weak var txtState: UITextField!
    @IBOutlet weak var txtDistrict: UITextField!
    @IBOutlet weak var topDisctrictView: NSLayoutConstraint!
    @IBOutlet weak var heightDisctrictView: NSLayoutConstraint!
    
    var appDelegate:AppDelegate!
    
    var userInput:URUser?
    var color:UIColor?
    var updateMode:Bool!
    
    var pickerGender:UIPickerView?
    var pickerDate:UIDatePicker?
    var pickerCities:UIPickerView?
    var pickerStates:UIPickerView?
    var pickerDistricts:UIPickerView?
    
    var country:URCountry?
    var countryISO3:URCountry?
    var birthDay:NSDate?
    var localizedGender:String?
    var gender:String?
    let genders:[String]? = ["user_gender_male".localized,"user_gender_female".localized]
    var countries:[URCountry]!
    var states:[URState]!
    var districts:[URDistrict] = [URDistrict]()
    var auxDistricts:[URDistrict] = [URDistrict]()
    var stateBoundary:String!
    
    var hasDistrict:Bool!
    
    let termsViewController:ISTermsViewController = ISTermsViewController(fileName: "terms", fileExtension: "rtf", btAcceptColor: UIColor(rgba:"#49D080"), btCancelColor: UIColor(rgba:"#D0D0D0"), btAcceptTitle: "Accept", btCancelTitle: "Cancel", btAcceptTitleColor: UIColor.whiteColor(), btCancelTitleColor: UIColor.blackColor(), setupButtonAsRounded: true, setupBackgroundViewAsRounded: true)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        
        countries = URCountry.getCountries(URCountryCodeType.ISO2) as [URCountry]
        
        hasDistrict = false
        setupUI()
        setupUIWithUserData()
        checkUserCountry()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        self.navigationController!.setNavigationBarHidden(false, animated: false)
        
        let tracker = GAI.sharedInstance().defaultTracker
        tracker.set(kGAIScreenName, value: "User Register")
        
        let builder = GAIDictionaryBuilder.createScreenView()
        tracker.send(builder.build() as [NSObject : AnyObject])
        
    }
    
    override func viewDidDisappear(animated: Bool) {
        super.viewDidDisappear(animated)
        MBProgressHUD.hideHUDForView(self.view, animated: true)
    }
    
    init(color:UIColor,user:URUser,updateMode:Bool) {
        self.color = color
        self.userInput = user
        self.updateMode = updateMode
        super.init(nibName: "URUserRegisterViewController", bundle: nil)
    }
    
    init(color:UIColor) {
        self.updateMode = false
        self.color = color
        super.init(nibName: "URUserRegisterViewController", bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK: ISTermsViewControllerDelegate
    
    func userDidAcceptTerms(accept: Bool) {
        
        self.termsViewController.closeWithCompletion { (closed) in
        }
        
        if accept == true {
            let settings = URSettings.getSettings()
            settings.firstRun = false
            URSettings.saveSettingsLocaly(settings)
        }
    }
    
    //MARK: Button Events
    
    @IBAction func btNextTapped(sender: AnyObject) {
        
        if ((self.txtPassword.text!.isEmpty) && (self.userInput == nil)) {
            showEmptyTextFieldAlert(self.txtPassword)
            return
        }else if ((self.txtDistrict.text!.isEmpty) && (hasDistrict == true)) {
            showEmptyTextFieldAlert(self.txtDistrict)
            return
        }else if let textField = self.view.findTextFieldEmptyInView(self.view) {
            
            if !(URSettings.getSettings().reviewMode == true && (textField == self.txtBirthDay || textField == self.txtState || textField == self.txtGender)) {
                showEmptyTextFieldAlert(textField)
                return
            }
        }
        
        self.view.endEditing(true)
        
        if URSettings.checkIfTermsIsAccepted(termsViewController, viewController: self) == true {
            
            var user:URUser = URUser()
            
            if URSettings.getSettings().reviewMode == true {
                gender = gender == nil ? "" : gender
                self.birthDay = self.birthDay == nil ? NSDate() : self.birthDay
                self.txtState.text = self.txtState.text == nil ? "" : self.txtState.text
            }
            
            MBProgressHUD.showHUDAddedTo(self.view, animated: true)
            
            if (self.userInput != nil) {
                user = self.userInput!
                self.saveUser(buildUserFields(user))
                
            }else {
                
                user = buildUserFields(user)
                user.type = URType.UReport
                
                URFireBaseManager.sharedInstance().createUser(user.email, password: self.txtPassword.text,
                                                              withValueCompletionBlock: { error, result in
                                                                MBProgressHUD.hideHUDForView(self.view, animated: true)
                                                                if error != nil {
                                                                    var msg = ""
                                                                    
                                                                    switch (error.code) {
                                                                    case -9:
                                                                        msg = "error_email_already_exists".localized
                                                                        break;
                                                                    case -5:
                                                                        msg = "2".localized
                                                                        break;
                                                                    default:
                                                                        break
                                                                    }
                                                                    
                                                                    if msg.isEmpty {
                                                                        print(error)
                                                                        UIAlertView(title: "Error", message: "error_no_internet".localized, delegate: self, cancelButtonTitle: "OK").show()
                                                                    }else {
                                                                        UIAlertView(title: nil, message: msg, delegate: self, cancelButtonTitle: "OK").show()
                                                                    }
                                                                    
                                                                } else {
                                                                    let uid = result["uid"] as? String
                                                                    user.key = uid
                                                                    
                                                                    if (error != nil) {
                                                                        print(error)
                                                                    }else{
                                                                        
                                                                        self.saveUser(user)
                                                                        
                                                                        URUserLoginManager.login(user.email!,password: self.txtPassword.text!, completion: { (FAuthenticationError,success) -> Void in
                                                                            MBProgressHUD.hideHUDForView(self.view, animated: true)
                                                                            if success {
                                                                                URNavigationManager.setupNavigationControllerWithMainViewController(URMainViewController())
                                                                            }
                                                                        })
                                                                    }
                                                                }
                })
                
            }
            
        }
        
    }
    
    //MARK: Class Methods
    
    func buildUserFields(user:URUser) -> URUser {
        user.nickname = self.txtNick.text
        user.email = self.txtEmail.text
        user.district = self.txtDistrict.text != nil ? self.txtDistrict.text : nil
        user.gender = gender
        user.birthday = NSNumber(longLong:Int64(self.birthDay!.timeIntervalSince1970 * 1000))
        user.country = countryISO3?.code
        user.state = self.txtState.text
        user.publicProfile = true
        user.countryProgram = URCountryProgramManager.getCountryProgramByCountry(countryISO3!).code
        URCountryProgramManager.setActiveCountryProgram(URCountryProgramManager.getCountryProgramByCountry(countryISO3!))
        return user
    }
    
    func showEmptyTextFieldAlert(textField:UITextField) {
        UIAlertView(title: nil, message: String(format: "is_empty".localized, arguments: [textField.placeholder!]), delegate: self, cancelButtonTitle: "OK").show()
    }
    
    func saveUser(user:URUser) {
        
        MBProgressHUD.showHUDAddedTo(self.view, animated: true)
        URUserManager.save(user)
        MBProgressHUD.hideHUDForView(self.view, animated: true)
        
        if updateMode == true {
            UIAlertView(title: nil, message: "message_success_user_update".localized, delegate: self, cancelButtonTitle: "OK").show()
            URNavigationManager.navigation.popViewControllerAnimated(true)
        }
        
        URRapidProContactUtil.buildRapidProUserDictionaryWithContactFields(user, country: URCountry(code:updateMode == true ? "" :self.country!.code!)) { (rapidProUserDictionary:NSDictionary) -> Void in
            
            URRapidProManager.saveUser(user, country: URCountry(code:user.country),setupGroups: !self.updateMode, completion: { (response) -> Void in
                URRapidProContactUtil.rapidProUser = NSMutableDictionary()
                URRapidProContactUtil.groupList = []
                print(response)
                URNavigationManager.setupNavigationControllerWithMainViewController(URMainViewController())
            })
        }
        
    }
    
    func setupUIWithUserData() {
        if self.userInput != nil {
            
            self.viewPassword.hidden = true
            self.txtPassword.placeholder = nil
            
            if let nickName = self.userInput!.nickname {
                self.txtNick.text = nickName
            }
            
            if let email = self.userInput!.email {
                self.txtEmail.text = email
            }
            
            if let gender = self.userInput!.gender {
                
                if gender == "Male" {
                    self.localizedGender = URGender.Male
                }else{
                    self.localizedGender = URGender.Female
                }
                
                self.txtGender.text = self.localizedGender
                
            }
            
            if let birthDay = self.userInput!.birthday {
                let convertedDate = NSDate(timeIntervalSince1970: NSNumber(double: birthDay.doubleValue/1000) as NSTimeInterval)
                
                self.birthDay = convertedDate
                self.txtBirthDay.text = URDateUtil.birthDayFormatter(convertedDate)
                
                self.pickerDate?.setDate(convertedDate, animated: false)
                
            }
        }
    }
    
    private func checkUserCountry() {
        
        self.txtState.enabled = true
        
        if updateMode != nil && updateMode == true {
            self.country = URCountry(code: URCountry.getISO2CountryCodeByISO3Code(self.userInput!.country))
            self.txtCountry.text = URCountryProgramManager.getCountryProgramByCountry(URCountry(code: self.userInput!.country)).name
            self.countryISO3 = URCountry(code:URCountry.getISO3CountryCodeByISO2Code(self.country!.code!))
        }else{
            self.country = URCountry.getCurrentURCountry()
            self.countryISO3 = URCountry(code:URCountry.getISO3CountryCodeByISO2Code(self.country!.code!))
            self.txtCountry.text = self.country?.name
        }
        
        if self.userInput != nil{
            loadState(false)
            
            if self.userInput!.state != nil && !self.userInput!.state!.isEmpty {
                self.txtState.text! = self.userInput!.state
                
            }
            
            if self.userInput!.district != nil && !self.userInput!.district!.isEmpty {
                hasDistrict = true
                self.txtDistrict.placeholder = "district".localized
                self.topDisctrictView.constant = 8
                self.heightDisctrictView.constant = 50
                
                self.txtDistrict.text! = self.userInput!.district
                self.txtDistrict.enabled = true
            }else {
                hasDistrict = false
                self.txtDistrict.placeholder = nil
                self.topDisctrictView.constant = 0
                self.heightDisctrictView.constant = 0
            }
            
        }else {
            self.topDisctrictView.constant = 0
            self.heightDisctrictView.constant = 0
            loadState(true)
        }
    }
    
    func setupTextFieldLoading(textField:UITextField) {
        textField.placeholder = "loading_states".localized
        textField.enabled = false
    }
    
    func setupFinishLoadingTextField(textField:UITextField,placeholder:String) {
        textField.text = ""
        textField.placeholder = placeholder
        textField.enabled = true
    }
    
    func loadState(updateUI:Bool) {
        
        self.states = []
        
        if updateUI == true {
            setupTextFieldLoading(self.txtState)
        }
        
        Alamofire.request(.GET, "http://api.geonames.org/countryInfoJSON?country=\(self.country!.code!)&username=ureport").responseJSON() {
            (_, _, JSON) in
            if let dictionary = (JSON.value as? NSDictionary)?.objectForKey("geonames") {
                
                let geonameId:Int = dictionary.objectAtIndex(0)["geonameId"]! as! Int
                
                Alamofire.request(.GET, "http://api.geonames.org/childrenJSON?geonameId=\(geonameId)&username=ureport").responseJSON() {
                    (_, _, data) in
                    
                    if data.value != nil {
                        
                        if updateUI == true {
                            self.setupFinishLoadingTextField(self.txtState, placeholder: "state".localized)
                        }
                        
                        if data.value!.objectForKey("geonames") != nil && data.value!.objectForKey("totalResultsCount") as! Int > 0 {
                            
                            for index in 0...data.value!.objectForKey("geonames")!.count-1 {
                                let geoName:NSDictionary = data.value!.objectForKey("geonames")!.objectAtIndex(index) as! NSDictionary
                                self.states.append(URState(name: geoName["adminName1"] as! String, boundary: nil))
                            }
                            
                            self.states = self.states.sort(){$0.name < $1.name}
                            
                            self.pickerStates?.reloadAllComponents()
                        }else {
                            print("geonames key not found")
                        }
                    }else {
                        print("error on http://api.geonames.org/childrenJSON?geonameId=\(geonameId)&username=ureport")
                    }
                }
            }
            
        }
    }
    
    private func setupUI() {
        
        self.txtNick.placeholder = "sign_up_nickname".localized
        self.txtBirthDay.placeholder = "sign_up_birthday".localized
        self.txtCountry.placeholder = "country".localized
        self.txtEmail.placeholder = "sign_up_email".localized
        self.txtGender.placeholder = "gender".localized
        self.txtPassword.placeholder = "login_password".localized
        self.txtState.placeholder = "state".localized
        self.btNext.setTitle("next".localized, forState: UIControlState.Normal)
        
        URNavigationManager.setupNavigationBarWithCustomColor(self.color!)
        self.btNext.backgroundColor = self.color
        
        self.pickerDate = UIDatePicker()
        self.pickerGender = UIPickerView()
        self.pickerCities = UIPickerView()
        self.pickerStates = UIPickerView()
        self.pickerDistricts = UIPickerView()
        
        self.pickerDate!.datePickerMode = UIDatePickerMode.Date
        self.pickerDate!.addTarget(self, action: #selector(dateChanged), forControlEvents: UIControlEvents.ValueChanged)
        self.txtBirthDay.inputView = self.pickerDate!
        
        self.pickerGender!.dataSource = self
        self.pickerGender!.delegate = self
        self.pickerGender!.showsSelectionIndicator = true
        self.txtGender.inputView = self.pickerGender
        
        self.pickerCities!.dataSource = self
        self.pickerCities!.delegate = self
        self.pickerCities!.showsSelectionIndicator = true
        self.txtCountry.inputView = self.pickerCities
        
        self.pickerStates!.dataSource = self
        self.pickerStates!.delegate = self
        self.pickerStates!.showsSelectionIndicator = true
        self.txtState.inputView = self.pickerStates
        
        self.pickerDistricts!.dataSource = self
        self.pickerDistricts!.delegate = self
        self.pickerDistricts!.showsSelectionIndicator = true
        self.txtDistrict.inputView = self.pickerDistricts
        
        if updateMode != nil && updateMode == true {
            self.txtNick.textColor = UIColor.grayColor().colorWithAlphaComponent(0.4)
            self.txtEmail.textColor = UIColor.grayColor().colorWithAlphaComponent(0.4)
            self.txtCountry.textColor = UIColor.grayColor().colorWithAlphaComponent(0.4)
            
            self.txtNick.enabled = false
            self.txtEmail.enabled = false
            self.txtCountry.enabled = false
        }
        
    }
    
    func setNeedDistrict(needDistrict:Bool) {
        if needDistrict == true {
            self.hasDistrict = true
            
            self.txtDistrict.placeholder = "district".localized
            
            self.topDisctrictView.constant = 8
            self.heightDisctrictView.constant = 50
            
            self.pickerDistricts!.reloadAllComponents()
        }else {
            self.hasDistrict = false
            self.txtDistrict.placeholder = nil
            self.topDisctrictView.constant = 0
            self.heightDisctrictView.constant = 0
        }
        
        self.view.layoutIfNeeded()
        
    }
    
    func filterDistricts() {
        
        self.txtDistrict.text = ""
        
        districts = auxDistricts.filter {
            return $0.parent == stateBoundary
        }
        
        if districts.isEmpty {
            setNeedDistrict(false)
        }else{
            setNeedDistrict(true)
        }
    }
    
    func dateChanged(sender:AnyObject) {
        let datePicker:UIDatePicker? = sender as? UIDatePicker
        self.birthDay = datePicker!.date
        self.txtBirthDay.text = URDateUtil.birthDayFormatter(self.birthDay!)
    }
    
    //MARK: TextFieldDelegate
    
    func textFieldDidBeginEditing(textField: UITextField) {
        
    }
    
    func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool {
        if textField == self.txtBirthDay || textField == self.txtGender || textField == self.txtCountry{
            return false
        }else{
            return true
        }
    }
    
    //MARK: Picker DataSource and Delegate
    
    func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if pickerView == self.pickerCities {
            return URCountry.getCountries(URCountryCodeType.ISO2).count
        }else if pickerView == self.pickerGender {
            return self.genders!.count
        }else if pickerView == self.pickerStates {
            return self.states.count
        }else if pickerView == self.pickerDistricts{
            return self.districts.count
        }else {
            return 0
        }
    }
    
    func pickerView(pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if pickerView == self.pickerCities {
            //            self.txtCountry.text = self.countries![row].name
            return self.countries![row].name
        }else if pickerView == self.pickerGender {
            localizedGender = (row == 0) ? URGender.Male : URGender.Female
            gender = row == 0 ? "Male" : "Female"
            self.txtGender.text = localizedGender
            return self.genders![row]
        }else if pickerView == self.pickerStates {
            self.stateBoundary = self.states[row].boundary
            self.txtState.text = self.states[row].name
            filterDistricts()
            return self.states[row].name
        }else if pickerView == self.pickerDistricts {
            self.txtDistrict.text = self.districts[row].name
            return self.districts[row].name
        }else{
            return ""
        }
    }
    
    
    
    func pickerView(pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if pickerView == self.pickerCities {
            
            country = (URCountry.getCountries(URCountryCodeType.ISO2)[row]) as URCountry
            countryISO3 = (URCountry.getCountries(URCountryCodeType.ISO3)[row]) as URCountry
            
            self.txtCountry.text = country!.name
            
            setupTextFieldLoading(self.txtState)
            
            self.txtState.text = ""
            self.txtDistrict.text = ""
            
            URRapidProManager.getStatesByCountry(countryISO3!, completion: { (states:[URState]?, districts:[URDistrict]?) -> Void in
                
                self.setupFinishLoadingTextField(self.txtState, placeholder: "state".localized)
                
                if let states = states {
                    self.states = states
                    self.pickerStates?.reloadAllComponents()
                }else {
                    self.loadState(true)
                }
                
                if let districts = districts {
                    if !districts.isEmpty {
                        self.districts = districts
                        self.auxDistricts = self.districts
                    }
                }else {
                    self.setNeedDistrict(false)
                }
                
            })
            
            
        }else if pickerView == self.pickerGender {
            if row == 0 {
                localizedGender = URGender.Male
                gender = "Male"
            }else {
                localizedGender = URGender.Female
                gender = "Female"
            }
            self.txtGender.text = self.genders![row]
        }else if pickerView == self.pickerStates {
            self.stateBoundary = self.states[row].boundary
            self.txtState.text = self.states[row].name
            
            filterDistricts()
            
        }
    }
    
}