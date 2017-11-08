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
    @IBOutlet weak var viewGender: UIView!
    @IBOutlet weak var btNext: UIButton!
    @IBOutlet weak var txtPassword: UITextField!
    @IBOutlet weak var txtNick: UITextField!
    @IBOutlet weak var txtEmail: UITextField!
    @IBOutlet weak var txtBirthDay: UITextField!
    @IBOutlet weak var txtGender: UITextField!
    
    let color:UIColor = UIColor(red:0.53, green:0.31, blue:0.63, alpha:1.0)
    
    var appDelegate:AppDelegate!
    
    var userInput:URUser?
    var updateMode:Bool!
    
    var pickerGender:UIPickerView?
    var pickerDate:UIDatePicker?
    
    var country:URCountry?
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
        
        let builder = GAIDictionaryBuilder.createScreenView().build()
        tracker?.send(builder as [NSObject : AnyObject]!)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        MBProgressHUD.hide(for: self.view, animated: true)
    }
    
    init(color:UIColor,user:URUser,updateMode:Bool) {
        self.userInput = user
        self.updateMode = updateMode
        super.init(nibName: "URUserRegisterViewController", bundle: nil)
    }
    
    init(color:UIColor) {
        self.updateMode = false
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
        } else if let textField = self.view.findTextFieldEmptyInView(self.view) {
            if !(URSettings.getSettings().reviewMode == true && (textField == self.txtBirthDay || textField == self.txtGender)) {
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
                    } else if let error = error {
                        switch error {
                        case URFireBaseManagerAuthError.emailTaken:
                            ISAlertMessages.displaySimpleMessage("error_email_already_exists".localized, fromController: self)
                        default:
                            ISAlertMessages.displaySimpleMessage("error_no_internet".localized, fromController: self)
                        }
                    }
                })
            }
        }
    }
    
    //MARK: Class Methods
    func buildUserFields(_ user:URUser) -> URUser {
        user.nickname = self.txtNick.text!
        user.email = self.txtEmail.text!
        user.gender = gender!
        user.birthday = NSNumber(value: Int64(self.birthDay!.timeIntervalSince1970 * 1000) as Int64)
        user.country = self.country!.code
        user.publicProfile = true
        user.countryProgram = URCountryProgramManager.getCountryProgramByCountry(self.country!).code!
        URCountryProgramManager.setActiveCountryProgram(URCountryProgramManager.getCountryProgramByCountry(self.country!))
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
        
        URRapidProContactUtil.buildRapidProUserDictionaryWithContactFields(user, country: URCountry(code:updateMode == true ? "" : self.country!.code!)) { (rapidProUserDictionary:NSDictionary?) -> Void in
            
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
                } else {
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
        self.country = URCountry(code: "OTM")
        self.country?.name = "On The Move"
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
    
    fileprivate func setupUI() {
        self.txtNick.placeholder = "sign_up_nickname".localized
        self.txtBirthDay.placeholder = "sign_up_birthday".localized
        self.txtEmail.placeholder = "sign_up_email".localized
        self.txtGender.placeholder = "gender".localized
        self.txtPassword.placeholder = "login_password".localized
        self.btNext.setTitle("next".localized, for: UIControlState())
        
        URNavigationManager.setupNavigationBarWithCustomColor(self.color)
        self.btNext.backgroundColor = self.color
        
        self.pickerDate = UIDatePicker()
        self.pickerGender = UIPickerView()
        
        self.pickerDate!.datePickerMode = UIDatePickerMode.date
        self.pickerDate!.maximumDate = Calendar.current.date(byAdding: .year, value: -10, to: Date())
        self.pickerDate!.addTarget(self, action: #selector(dateChanged), for: UIControlEvents.valueChanged)
        self.txtBirthDay.inputView = self.pickerDate!
        
        self.pickerGender!.dataSource = self
        self.pickerGender!.delegate = self
        self.pickerGender!.showsSelectionIndicator = true
        self.txtGender.inputView = self.pickerGender
        
        if updateMode != nil && updateMode == true {
            self.txtNick.textColor = UIColor.gray.withAlphaComponent(0.4)
            self.txtEmail.textColor = UIColor.gray.withAlphaComponent(0.4)
            self.txtNick.isEnabled = false
            self.txtEmail.isEnabled = false
        }
    }
    
    func dateChanged(_ sender:AnyObject) {
        let datePicker:UIDatePicker? = sender as? UIDatePicker
        self.birthDay = datePicker!.date
        self.txtBirthDay.text = URDateUtil.birthDayFormatter(self.birthDay!)
    }
    
    //MARK: TextFieldDelegate
    func textFieldDidBeginEditing(_ textField: UITextField) {}
    
    func textField(_ textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool {
        if textField == self.txtBirthDay || textField == self.txtGender {
            return false
        } else {
            return true
        }
    }
    
    //MARK: Picker DataSource and Delegate
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if pickerView == self.pickerGender {
            return self.genders!.count
        } else {
            return 0
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if pickerView == self.pickerGender {
            localizedGender = (row == 0) ? URGender.Male : URGender.Female
            gender = row == 0 ? "Male" : "Female"
            self.txtGender.text = localizedGender
            return self.genders![row]
        } else {
            return ""
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if pickerView == self.pickerGender {
            if row == 0 {
                localizedGender = URGender.Male
                gender = "Male"
            } else {
                localizedGender = URGender.Female
                gender = "Female"
            }
            self.txtGender.text = self.genders![row]
        }
    }
    
}
