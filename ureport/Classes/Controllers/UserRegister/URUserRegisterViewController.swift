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
    var birthDay:Date?
    var localizedGender:String?
    var gender:String?
    let genders:[String]? = ["user_gender_male".localized,"user_gender_female".localized]
    var countries:[URCountry]!
    var states:[URState]!
    var districts:[URDistrict] = [URDistrict]()
    var auxDistricts:[URDistrict] = [URDistrict]()
    var stateBoundary:String!
    
    var hasDistrict:Bool!
    
    let termsViewController:ISTermsViewController = ISTermsViewController(fileName: "terms", fileExtension: "rtf", btAcceptColor: UIColor(rgba:"#49D080"), btCancelColor: UIColor(rgba:"#D0D0D0"), btAcceptTitle: "Accept", btCancelTitle: "Cancel", btAcceptTitleColor: UIColor.white, btCancelTitleColor: UIColor.black, setupButtonAsRounded: true, setupBackgroundViewAsRounded: true)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.appDelegate = UIApplication.shared.delegate as! AppDelegate
        
        countries = URCountry.getCountries(URCountryCodeType.iso2) as [URCountry]
        
        hasDistrict = false
        setupUI()
        setupUIWithUserData()
        checkUserCountry()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.navigationController!.setNavigationBarHidden(false, animated: false)
        
        let tracker = GAI.sharedInstance().defaultTracker
        tracker?.set(kGAIScreenName, value: "User Register")
        
        if let builder = GAIDictionaryBuilder.createScreenView().build() as? [AnyHashable: Any] {
            tracker?.send(builder)
        }
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        MBProgressHUD.hide(for: self.view, animated: true)
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
    
    func userDidAcceptTerms(_ accept: Bool) {
        
        self.termsViewController.closeWithCompletion { (closed) in }
        
        if accept == true {
            let settings = URSettings.getSettings()
            settings.firstRun = false
            URSettings.saveSettingsLocaly(settings)
        }
    }
    
    //MARK: Button Events
    
    @IBAction func btNextTapped(_ sender: AnyObject) {
        
        if ((self.txtPassword.text!.isEmpty) && (self.userInput == nil)) {
            showEmptyTextFieldAlert(self.txtPassword)
            return
        } else if ((self.txtDistrict.text!.isEmpty) && (hasDistrict == true)) {
            showEmptyTextFieldAlert(self.txtDistrict)
            return
        } else if let textField = self.view.findTextFieldEmptyInView(self.view) {
            
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
                self.birthDay = self.birthDay == nil ? Date() : self.birthDay
                self.txtState.text = self.txtState.text == nil ? "" : self.txtState.text
            }
            
            MBProgressHUD.showAdded(to: self.view, animated: true)
            
            if (self.userInput != nil) {
                user = self.userInput!
                if user.key == nil {
                    user.key = user.socialUid
                }
                self.saveUser(buildUserFields(user))
            } else {
                
                user = buildUserFields(user)
                user.type = URType.UReport
                
                URFireBaseManager.createUser(email: user.email!, password: self.txtPassword.text!, completion: { (newUser, error) in
                    MBProgressHUD.hide(for: self.view, animated: true)
                    if let newUser = newUser {
                        
                        user.key = newUser.key
                        
                        self.saveUser(user)                        
                        
                        URFireBaseManager.authUserWithPassword(email: user.email!, password: self.txtPassword.text!, completion: { (user, error) in
                            if let _ = user {
                                URNavigationManager.setupNavigationControllerWithMainViewController(URMainViewController())
                            }
                        })
                        
                    }else if let error = error {
                        switch error {
                        case URFireBaseManagerAuthError.emailTaken:
                            ISAlertMessages.displaySimpleMessage("error_email_already_exists".localized, fromController: self)
                            break
                        default:
                            ISAlertMessages.displaySimpleMessage("error_no_internet".localized, fromController: self)
                            break
                        }
                    }
                })
            }
            
        }
        
    }
    
    //MARK: Class Methods
    
    func buildUserFields(_ user: URUser) -> URUser {
        user.nickname = self.txtNick.text!
        user.email = self.txtEmail.text!
        user.district = self.txtDistrict.text != nil ? self.txtDistrict.text! : nil
        user.gender = gender!
        user.birthday = NSNumber(value: Int64(self.birthDay!.timeIntervalSince1970 * 1000) as Int64)
        user.country = countryISO3?.code!
        user.state = self.txtState.text!
        user.publicProfile = true
        user.countryProgram = URCountryProgramManager.getCountryProgramByCountry(countryISO3!).code!
        URCountryProgramManager.setActiveCountryProgram(URCountryProgramManager.getCountryProgramByCountry(countryISO3!))
        return user
    }
    
    func showEmptyTextFieldAlert(_ textField:UITextField) {
        UIAlertView(title: nil, message: String(format: "is_empty".localized, arguments: [textField.placeholder!]), delegate: self, cancelButtonTitle: "OK").show()
    }
    
    func saveUser(_ user:URUser) {
        
        MBProgressHUD.showAdded(to: self.view, animated: true)
        URUserManager.save(user)
        MBProgressHUD.hide(for: self.view, animated: true)
        
        if updateMode == true {
            UIAlertView(title: nil, message: "message_success_user_update".localized, delegate: self, cancelButtonTitle: "OK").show()
            URNavigationManager.navigation.popViewController(animated: true)
        }
        
        URRapidProContactUtil.buildRapidProUserDictionaryWithContactFields(user, country: URCountry(code:updateMode == true ? "" :self.country!.code!)) { (rapidProUserDictionary) -> Void in

            guard let _ = rapidProUserDictionary else {
                URNavigationManager.setupNavigationControllerWithMainViewController(URMainViewController())
                return
            }
            
            URRapidProManager.saveUser(user, country: URCountry(code:user.country!),setupGroups: !self.updateMode, completion: { (response) -> Void in
                URRapidProContactUtil.rapidProUser = NSMutableDictionary()
                URRapidProContactUtil.groupList = []
                URNavigationManager.setupNavigationControllerWithMainViewController(URMainViewController())
            })
        }
        
    }
    
    func setupUIWithUserData() {
        if self.userInput != nil {
            
            self.viewPassword.isHidden = true
            self.txtPassword.placeholder = nil
            
            if let nickName = self.userInput!.nickname {
                self.txtNick.text = nickName
            }
            
            if let email = self.userInput!.email {
                self.txtEmail.text = email
            }
            
            if let gender = self.userInput!.gender {
                
                self.gender = gender
                
                if gender == "Male" {
                    self.localizedGender = URGender.Male
                }else{
                    self.localizedGender = URGender.Female
                }
                
                self.txtGender.text = self.localizedGender
                
            }
            
            if let birthDay = self.userInput!.birthday {
                let convertedDate = Date(timeIntervalSince1970: NSNumber(value: birthDay.doubleValue/1000 as Double) as TimeInterval)
                
                self.birthDay = convertedDate
                self.txtBirthDay.text = URDateUtil.birthDayFormatter(convertedDate)
                
                self.pickerDate?.setDate(convertedDate, animated: false)
                
            }
        }
    }
    
    fileprivate func checkUserCountry() {
        
        self.txtState.isEnabled = true
        
        if updateMode != nil && updateMode == true {
            self.country = URCountry(code: URCountry.getISO2CountryCodeByISO3Code(self.userInput!.country!))
            self.txtCountry.text = URCountryProgramManager.getCountryProgramByCountry(URCountry(code: self.userInput!.country!)).name
            self.countryISO3 = URCountry(code:URCountry.getISO3CountryCodeByISO2Code(self.country!.code!))
        }else{
            self.country = URCountry.getCurrentURCountry()
            self.countryISO3 = URCountry(code:URCountry.getISO3CountryCodeByISO2Code(self.country!.code!))
            self.txtCountry.text = self.country?.name
        }
        
        if self.userInput != nil{
            loadState(false)
            
            if self.userInput!.state != nil && !self.userInput!.state!.isEmpty {
                self.txtState.text! = self.userInput!.state!
                
            }
            
            if self.userInput!.district != nil && !self.userInput!.district!.isEmpty {
                hasDistrict = true
                self.txtDistrict.placeholder = "district".localized
                self.topDisctrictView.constant = 8
                self.heightDisctrictView.constant = 50
                
                self.txtDistrict.text! = self.userInput!.district!
                self.txtDistrict.isEnabled = true
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
    
    func setupTextFieldLoading(_ textField:UITextField) {
        textField.placeholder = "loading_states".localized
        textField.isEnabled = false
    }
    
    func setupFinishLoadingTextField(_ textField:UITextField,placeholder:String) {
        textField.text = ""
        textField.placeholder = placeholder
        textField.isEnabled = true
    }
    
    func loadState(_ updateUI:Bool) {
        
        self.states = []
        
        if updateUI == true {
            setupTextFieldLoading(self.txtState)
        }
        
        URGeonamesAPI.getGeonameID(countryCode: self.country!.code!) { (geonameId) in
            if let geonameId = geonameId {
                URGeonamesAPI.getStatesByGeonameID(geonameId: geonameId, completion: { (states) in
                    if let states = states {
                        if updateUI == true {
                            self.setupFinishLoadingTextField(self.txtState, placeholder: "state".localized)
                        }
                        self.states = states
                        self.pickerStates?.reloadAllComponents()
                    }else {
                        if updateUI == true {
                            self.setupFinishLoadingTextField(self.txtState, placeholder: "state".localized)
                        }
                    }
                })
            }
        }
    }
    
    fileprivate func setupUI() {
        
        self.txtNick.placeholder = "sign_up_nickname".localized
        self.txtBirthDay.placeholder = "sign_up_birthday".localized
        self.txtCountry.placeholder = "country".localized
        self.txtEmail.placeholder = "sign_up_email".localized
        self.txtGender.placeholder = "gender".localized
        self.txtPassword.placeholder = "login_password".localized
        self.txtState.placeholder = "state".localized
        self.btNext.setTitle("next".localized, for: UIControlState())
        
        URNavigationManager.setupNavigationBarWithCustomColor(self.color!)
        self.btNext.backgroundColor = self.color
        
        self.pickerDate = UIDatePicker()
        self.pickerGender = UIPickerView()
        self.pickerCities = UIPickerView()
        self.pickerStates = UIPickerView()
        self.pickerDistricts = UIPickerView()
        
        self.pickerDate!.datePickerMode = UIDatePickerMode.date
        self.pickerDate!.maximumDate = Calendar.current.date(byAdding: .year, value: -10, to: Date())
        self.pickerDate!.addTarget(self, action: #selector(dateChanged), for: UIControlEvents.valueChanged)
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
            self.txtNick.textColor = UIColor.gray.withAlphaComponent(0.4)
            self.txtEmail.textColor = UIColor.gray.withAlphaComponent(0.4)
            self.txtCountry.textColor = UIColor.gray.withAlphaComponent(0.4)
            
            self.txtNick.isEnabled = false
            self.txtEmail.isEnabled = false
            self.txtCountry.isEnabled = false
        }
        
    }
    
    func setNeedDistrict(_ needDistrict:Bool) {
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
    
    func dateChanged(_ sender:AnyObject) {
        let datePicker:UIDatePicker? = sender as? UIDatePicker
        self.birthDay = datePicker!.date
        self.txtBirthDay.text = URDateUtil.birthDayFormatter(self.birthDay!)        
    }
    
    //MARK: TextFieldDelegate
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool {
        if textField == self.txtBirthDay || textField == self.txtGender || textField == self.txtCountry{
            return false
        }else{
            return true
        }
    }
    
    //MARK: Picker DataSource and Delegate
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if pickerView == self.pickerCities {
            return URCountry.getCountries(URCountryCodeType.iso2).count
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
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
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
            if self.txtState.text!.isEmpty {
                self.txtState.text = self.states[row].name
            }
            filterDistricts()
            return self.states[row].name
        }else if pickerView == self.pickerDistricts {
            self.txtDistrict.text = self.districts[row].name
            return self.districts[row].name
        }else{
            return ""
        }
    }
    
    
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if pickerView == self.pickerCities {
            
            country = (URCountry.getCountries(URCountryCodeType.iso2)[row]) as URCountry
            countryISO3 = (URCountry.getCountries(URCountryCodeType.iso3)[row]) as URCountry
            
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
