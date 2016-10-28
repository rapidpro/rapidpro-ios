//
//  URStoriesTableViewController.swift
//  ureport
//
//  Created by Daniel Amaral on 14/07/15.
//  Copyright (c) 2015 ilhasoft. All rights reserved.
//

import UIKit
import Alamofire
import AlamofireObjectMapper
import MBProgressHUD

class URStoriesTableViewController: UITableViewController, URStoryManagerDelegate, URStoriesTableViewCellDelegate, URWriteStoryViewDelegate {
    
    let imgViewHistoryHeight:CGFloat = 188.0
    let fullHeightTableViewCell:CGFloat = 497
    let contentViewBottom = 2
    let storyManager = URStoryManager()
    var storyList:[URStory] = []
    var newsList:[URNews] = []
    var filterStoriesToModerate:Bool!
    var modalProfileViewController:URModalProfileViewController!
    var index = 1
    var lastQueryItemIndex = 0
    var isLastPost = false
    
    init (filterStoriesToModerate:Bool) {
        self.storyList.removeAll()
        self.filterStoriesToModerate = filterStoriesToModerate
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupTableView()
        
        if filterStoriesToModerate == false {
            loadNews()
        }else{
            self.reloadDataWithStories()
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        MBProgressHUD.hide(for: self.view, animated: true)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController!.setNavigationBarHidden(false, animated: true)
        dump(URCountryProgramManager.activeCountryProgram())
        URNavigationManager.setupNavigationBarWithCustomColor(URCountryProgramManager.activeCountryProgram()!.themeColor!)
        
        let tracker = GAI.sharedInstance().defaultTracker
        tracker?.set(kGAIScreenName, value: "Stories")
        
        let builder = GAIDictionaryBuilder.createScreenView().build()
        tracker?.send(builder as [NSObject : AnyObject]!)
        
    }
    
    //MARK: URWriteStoryTableViewCellDelegate
    
    func writeStoryDidTap(_ cell: URWriteStoryView) {
        if URUser.activeUser() != nil {
            
            if URUserManager.userHasPermissionToAccessTheFeature(false) == true {
                self.navigationController?.pushViewController(URAddStoryViewController(), animated: true)
            }else {
                let alertController = UIAlertController(title: nil, message: "feature_without_permission".localized, preferredStyle: .alert)
                alertController.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
                self.present(alertController, animated: true, completion: {})
            }
            
        }else{
            URLoginAlertController.show(self)
        }
    }
    
    //MARK: URStoriesTableViewCellDelegate
    
    func openProfile(_ user: URUser) {
        self.modalProfileViewController = URModalProfileViewController(user: user)
        self.modalProfileViewController.modalPresentationStyle = UIModalPresentationStyle.overCurrentContext
        self.navigationController!.present(modalProfileViewController, animated: true) { () -> Void in
            UIView.animate(withDuration: 0.3, animations: { () -> Void in
                self.modalProfileViewController.view.backgroundColor  = UIColor.black.withAlphaComponent(0.5)
            }) 
        }
    }
    
    //MARK: MenuDelegateMethods
    
    func countryProgramDidChanged(_ countryProgram: URCountryProgram) {
        storyList.removeAll()
        storyManager.getStoriesWithCompletion(filterStoriesToModerate, initQueryFromItem: storyList.count) { (storyList) in
            self.storyList = storyList.reversed()
            self.tableView.reloadData()
            self.storyManager.getStories(self.filterStoriesToModerate, initQueryFromItem: storyList.count)
        }
    }
    
    // MARK: - Table view data source
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if (filterStoriesToModerate == false){
            return 58
        }else{
            return 0
        }
    }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let viewHeader =  Bundle.main.loadNibNamed("URWriteStoryView", owner: 0, options: nil)?[0] as! URWriteStoryView
        viewHeader.delegate = self
        
        if (filterStoriesToModerate == false){
            self.tableView.tableHeaderView = viewHeader
            sizeHeaderToFit()
        }else{
            viewHeader.frame = CGRect(x: 0, y: 0, width: 0, height: 0)
        }
        
        return viewHeader
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.storyList.count + self.newsList.count
    }
    
    override func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0.0
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        if (indexPath as NSIndexPath).row < self.storyList.count {
            let story = storyList[(indexPath as NSIndexPath).row]
            
            if story.cover != nil && story.cover?.url != nil {
                return fullHeightTableViewCell
            }else {
                return fullHeightTableViewCell - imgViewHistoryHeight
            }
        }else {
            return 245
        }
        
    }
    
    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if (indexPath as NSIndexPath).row == storyList.count - 1 && storyList.count >= storyManager.itensByQuery && isLastPost == false {
            storyManager.getStoriesWithCompletion(filterStoriesToModerate, initQueryFromItem: storyList.count) { (storyList) in
                self.isLastPost = self.storyList.last?.key == storyList.first?.key
                self.storyList = storyList.reversed()
                self.tableView.reloadData()
            }
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if (indexPath as NSIndexPath).row < self.storyList.count {
        
            let cell = tableView.dequeueReusableCell(withIdentifier: NSStringFromClass(URStoriesTableViewCell.self), for: indexPath) as! URStoriesTableViewCell
            
            let story = storyList[(indexPath as NSIndexPath).row]
            cell.delegate = self
            cell.viewController = self
            cell.setupCellWith(story,moderateUserMode: self.filterStoriesToModerate)
            return cell
        }else {
            let cell = tableView.dequeueReusableCell(withIdentifier: NSStringFromClass(URNewsTableViewCell.self), for: indexPath) as! URNewsTableViewCell
            let news = newsList[(indexPath as NSIndexPath).row - self.storyList.count]
            cell.setupCellWith(news)
            return cell
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath)
        
        if cell is URStoriesTableViewCell {
            if let _ = URUser.activeUser() {
                self.navigationController?.pushViewController(URStoryContributionViewController(story: (cell as! URStoriesTableViewCell).story), animated: true)
            }else {
                URLoginAlertController.show(self)
            }
        }else if cell is URNewsTableViewCell {
            self.navigationController?.pushViewController(URNewsDetailViewController(news:(cell as! URNewsTableViewCell).news),animated: true)
        }
    }
    
    //MARK: Class Methods
    
    func sizeHeaderToFit() {
        let headerView = self.tableView.tableHeaderView!
        headerView.setNeedsLayout()
        headerView.layoutIfNeeded()
        
        let height = headerView.systemLayoutSizeFitting(UILayoutFittingCompressedSize).height
        
        var frame = headerView.frame
        frame.size.height = height
        headerView.frame = frame
        
        self.tableView.tableHeaderView = headerView
    }
    
    func loadNews() {
        
        if let org = URCountryProgramManager.activeCountryProgram()!.org {
            let url = "\(URCountryProgramManager.activeCountryProgram()!.ureportHostAPI!)\(org)"
            
            Alamofire.request(url, method: .get, parameters: nil, encoding: JSONEncoding.default, headers: nil).responseArray(queue: nil, keyPath: "results", context: nil, completionHandler: { (response:DataResponse<[URNews]>) in
                    if let response = response.result.value {
                        self.newsList = response
                        self.tableView.reloadData()
                        self.reloadDataWithStories()
                    }
            })
            
        }
    }
    
    func reloadDataWithStories() {
        storyManager.delegate = self
        
        storyList.removeAll()
        self.storyManager.getStories(self.filterStoriesToModerate, initQueryFromItem: self.storyList.count)
        
        MBProgressHUD.showAdded(to: self.view, animated: true)
        storyManager.getStoriesWithCompletion(filterStoriesToModerate, initQueryFromItem: storyList.count) { (storyList) in
            MBProgressHUD.hide(for: self.view, animated: true)
            self.storyList = storyList.reversed()
            self.tableView.reloadData()
        }
    }
    
    fileprivate func setupTableView() {
        self.tableView.separatorStyle = UITableViewCellSeparatorStyle.none
        self.tableView.delegate = self
        self.tableView.backgroundColor = UIColor.groupTableViewBackground
        self.tableView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 49, right: 0)
        
        self.tableView.register(UINib(nibName: "URStoriesTableViewCell", bundle: nil), forCellReuseIdentifier: NSStringFromClass(URStoriesTableViewCell.self))
        self.tableView.register(UINib(nibName: "URNewsTableViewCell", bundle: nil), forCellReuseIdentifier: NSStringFromClass(URNewsTableViewCell.self))
        self.tableView.separatorColor = UIColor.clear
    }
    
    //MARK: StoryManagerDelegate
    
    func removeCell(_ cell: URStoriesTableViewCell) {
        let indexPath = self.tableView.indexPath(for: cell)!
        self.storyList.remove(at: (indexPath as NSIndexPath).row)
        self.tableView.deleteRows(at: [indexPath], with: UITableViewRowAnimation.fade)
    }
    
    func newStoryReceived(_ story: URStory) {
        let hasStory = self.storyList.index{($0.key == story.key)}
        
        if hasStory == nil {
            storyList.insert(story, at: 0)
            self.tableView.insertRows(at: [IndexPath(row: storyList.count - index, section: 0)], with: UITableViewRowAnimation.automatic)
            index += 1
        }
    }
    
}
