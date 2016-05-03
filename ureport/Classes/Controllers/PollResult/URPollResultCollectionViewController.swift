//
//  URPollResultCollectionViewController.swift
//  ureport
//
//  Created by Daniel Amaral on 02/05/16.
//  Copyright © 2016 ilhasoft. All rights reserved.
//

import UIKit

private let reuseIdentifier = "Cell"

class URPollResultCollectionViewController: UICollectionViewController, UICollectionViewDelegateFlowLayout, URPollManagerDelegate {

    let pollManager = URPollManager()
    var pollResultList:[URPollResult] = []
    
    var poll:URPoll?
    
    init() {
        super.init(collectionViewLayout: UICollectionViewFlowLayout())
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
//        self.collectionView!.collectionViewLayout.invalidateLayout()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.self.collectionView!.registerNib(UINib(nibName: "URPollResultCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: NSStringFromClass(URPollResultCollectionViewCell.self))
        self.collectionView!.backgroundColor = UIColor.clearColor()
        self.collectionView!.delegate = self
        self.collectionView!.dataSource = self
        self.collectionView!.contentInset = UIEdgeInsetsMake(64, 0, 0, 0);
    }
    
    //MARK: Class Methods
    
    func setPoll(poll:URPoll,frame:CGRect) {
        self.collectionView!.frame = frame
        self.poll = poll
        pollManager.delegate = self
        self.pollResultList = []
        pollManager.getPollsResults(poll.key)
    }
    
    //MARK: URPollManagerDelegate
    
    func newPollResultReceived(pollResult: URPollResult) {
        pollResultList.insert(pollResult, atIndex: 0)
        self.collectionView!.reloadData()
    }
    
    func newPollReceived(poll: URPoll) {}

    override func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of items
        return pollResultList.count
    }

    override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(NSStringFromClass(URPollResultCollectionViewCell.self), forIndexPath: indexPath) as! URPollResultCollectionViewCell
    
        let pollResult = self.pollResultList[indexPath.item]
        
        cell.setupCellWithData(pollResult)
    
        return cell
    }

    //MARK: UICollectionViewDelegateFlowLayout
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        
        let pollResult = pollResultList[indexPath.item]
        
        if pollResult.type == "Choices" {
            return CGSize(width: (self.collectionView!.frame.size.width - 20) / 2, height: 189 + CGFloat(pollResult.results.count * 61))
        }else {
            return CGSize(width: (self.collectionView!.frame.size.width - 20) / 2, height: 500)
        }
    }
    
    // MARK: UICollectionViewDelegate

    /*
    // Uncomment this method to specify if the specified item should be highlighted during tracking
    override func collectionView(collectionView: UICollectionView, shouldHighlightItemAtIndexPath indexPath: NSIndexPath) -> Bool {
        return true
    }
    */

    /*
    // Uncomment this method to specify if the specified item should be selected
    override func collectionView(collectionView: UICollectionView, shouldSelectItemAtIndexPath indexPath: NSIndexPath) -> Bool {
        return true
    }
    */

    /*
    // Uncomment these methods to specify if an action menu should be displayed for the specified item, and react to actions performed on the item
    override func collectionView(collectionView: UICollectionView, shouldShowMenuForItemAtIndexPath indexPath: NSIndexPath) -> Bool {
        return false
    }

    override func collectionView(collectionView: UICollectionView, canPerformAction action: Selector, forItemAtIndexPath indexPath: NSIndexPath, withSender sender: AnyObject?) -> Bool {
        return false
    }

    override func collectionView(collectionView: UICollectionView, performAction action: Selector, forItemAtIndexPath indexPath: NSIndexPath, withSender sender: AnyObject?) {
    
    }
    */

}
