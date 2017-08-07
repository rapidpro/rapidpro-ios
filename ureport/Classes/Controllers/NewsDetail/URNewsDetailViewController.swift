//
//  URNewsDetailViewController.swift
//  ureport
//
//  Created by Daniel Amaral on 29/10/15.
//  Copyright © 2015 ilhasoft. All rights reserved.
//

import UIKit
import NYTPhotoViewer
import ISScrollViewPageSwift

class URNewsDetailViewController: UIViewController {

    @IBOutlet weak var lbTitle: UILabel!
    @IBOutlet weak var viewOpacityImage: UIView!
    @IBOutlet weak var lbMarkers: UILabel!
    @IBOutlet weak var lbContent: UILabel!
    @IBOutlet weak var imgView: UIImageView!
    @IBOutlet weak var scrollViewMedias: ISScrollViewPage!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var contentViewHeight: NSLayoutConstraint!
    
    var news:URNews!
    var photos:[PhotoShow]!
    
    init(news:URNews) {
        self.news = news
        super.init(nibName: "URNewsDetailViewController", bundle: nil)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.photos = []
        setupScrollViewMedias()
        setupUI()
        
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        let scrollViewHeight = self.lbContent.frame.size.height + 181 + self.scrollViewMedias.frame.height + 35
        
        self.contentViewHeight.constant = scrollViewHeight
        self.scrollView.contentSize = CGSize(width: UIScreen.main.bounds.width,height: scrollViewHeight)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        URNavigationManager.setupNavigationBarWithType(.clear)
        self.navigationController?.hidesBarsOnSwipe = true
        
        let tracker = GAI.sharedInstance().defaultTracker
        tracker?.set(kGAIScreenName, value: "News")
        
        if let builder = GAIDictionaryBuilder.createScreenView().build() as? [AnyHashable: Any] {
            tracker?.send(builder)
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.navigationController?.hidesBarsOnSwipe = false
        self.navigationController?.setNavigationBarHidden(false, animated: true)
    }
    
    //MARK: Class Methods
    
    func setupUI() {
        self.scrollView.contentInset = UIEdgeInsetsMake(-64, 0, 0, 0)        
        self.lbContent.setSizeFont(14)        
        self.viewOpacityImage.backgroundColor = UIColor.black.withAlphaComponent(0.38)
        
        self.lbTitle.text = news.title
        self.lbMarkers.text = news.tags
        self.lbContent.text = news.summary
        
        if let images = news.images {
            if images.count > 0 {
                self.imgView.sd_setImage(with: URL(string: images[0]))
            }
        }
        
    }
    
    func setupScrollViewMedias() {
        
        scrollViewMedias.setFillContent(false)
        scrollViewMedias.setEnableBounces(false)
        scrollViewMedias.setPaging(false)
        scrollViewMedias.scrollViewPageType = ISScrollViewPageType.horizontally
        
        if self.news.images != nil && self.news.images.count > 0{
            var photoIndex = 0
            
            for imageURL in self.news.images {
                
                let imgView = UIImageView(frame: CGRect(x: 0, y: 0, width: 100, height: 115))
                imgView.layer.borderWidth = 2
                imgView.layer.borderColor = UIColor.white.cgColor
                imgView.contentMode = UIViewContentMode.scaleAspectFill
                imgView.isUserInteractionEnabled = true
                
                let tapGesture = UITapGestureRecognizer(target: self, action: #selector(imgViewTapped))
                tapGesture.numberOfTouchesRequired = 1
                
                imgView.addGestureRecognizer(tapGesture)
                
                imgView.sd_setImage(with: URL(string:imageURL), completed: { (image, _, _, _) -> Void in
                    self.scrollViewMedias.addCustomView(imgView)
                    imgView.tag = photoIndex
                    
                    let title = NSAttributedString(string: "\(photoIndex + 1)", attributes: [NSForegroundColorAttributeName: UIColor.white])
                    let photo = PhotoShow(image: imgView.image, attributedCaptionTitle: title)
                    photo.index = photoIndex
                    
                    self.photos.append(photo)
                    
                    photoIndex += 1
                })
                
            }
            
        }
    }
    
    func imgViewTapped(_ sender:UITapGestureRecognizer) {        
        let photosViewController = NYTPhotosViewController(photos: self.photos, initialPhoto:self.photos[sender.view!.tag])
        present(photosViewController, animated: true, completion: nil)
        
    }
    
    
    //MARK: Button Events

}
