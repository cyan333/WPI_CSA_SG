//
//  FeedEditorViewController.swift
//  WPI_CSA
//
//  Created by Fangming Ning on 11/12/17.
//  Copyright © 2017 fangming. All rights reserved.
//

import UIKit

class FeedEditorViewController: UIViewController {
    
    var feedType = "Blog"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let viewWidth = screenWidth - 40
        
        let titleView = UIView(frame: CGRect(x: 20, y: 50, width: viewWidth, height: 250))
        
        titleView.backgroundColor = .white
        titleView.layer.shadowColor = UIColor.lightGray.cgColor
        titleView.layer.shadowOpacity = 1
        titleView.layer.shadowOffset = CGSize.zero
        titleView.layer.shadowRadius = 5
        titleView.layer.shadowPath = UIBezierPath(rect: titleView.bounds).cgPath
        titleView.layer.shouldRasterize = true
        
        let items = ["Blog", "Trade"]
        let picker = UISegmentedControl(items: items)
        picker.selectedSegmentIndex = 0
        picker.frame = CGRect(x: viewWidth/2 - 50, y: 40, width: 100, height: 25)
        picker.addTarget(self, action: #selector(selectFeedType(sender:)), for: .valueChanged)
        titleView.addSubview(picker)
        
        
        let titleField = UITextField(frame: CGRect(x: 20, y: 80, width: viewWidth - 40, height: 25))
        titleField.textAlignment = .center
        titleField.placeholder = "Enter the title for the blog"
        titleView.addSubview(titleField)
        
        let titleLine = UIView(frame: CGRect(x: 40, y: 110, width: viewWidth - 80, height: 1))
        titleLine.backgroundColor = .lightGray
        titleView.addSubview(titleLine)
        
        let nextButton = UIButton(frame: CGRect(x: viewWidth/2 - 25, y: 150, width: 50, height: 50))
        nextButton.setImage(#imageLiteral(resourceName: "Next.png"), for: .normal)
        titleView.addSubview(nextButton)
        
        self.view.addSubview(titleView)
    }
    
    @objc func selectFeedType(sender: UISegmentedControl){
        if sender.selectedSegmentIndex == 0 {
            feedType = "Blog"
            print(1)
        } else {
            feedType = "Trade"
            print(2)
        }
    }
    
}

