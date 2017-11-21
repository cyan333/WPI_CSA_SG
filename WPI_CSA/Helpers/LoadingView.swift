//
//  LoadingView.swift
//  WPI_CSA
//
//  Created by Fangming Ning on 10/16/17.
//  Copyright © 2017 fangming. All rights reserved.
//

import UIKit

class LoadingView: UIView {
    var serverDownView: UIView!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = .white
        self.clipsToBounds = true
        
        //Setting up loading label and indicator
        let loadingIndicator = UIActivityIndicatorView(frame: CGRect(x: frame.width/2 - 60, y: frame.height/2 - 15,
                                                                     width: 30, height: 30))
        loadingIndicator.activityIndicatorViewStyle = .gray
        loadingIndicator.startAnimating()
        self.addSubview(loadingIndicator)
        
        let loadingLabel = UILabel(frame: CGRect(x: frame.width/2 - 30, y: frame.height/2 - 15,
                                                 width: 80, height: 30))
        loadingLabel.text = "Loading ..."
        loadingLabel.textColor = .gray
        self.addSubview(loadingLabel)
        
        //Setting up server down view
        serverDownView = UIView(frame: CGRect(x: frame.width/2 - 150, y: frame.height/2 - 100,
                                              width: 300, height: 200))
        serverDownView.backgroundColor = .white
        
        let refreshImg = UIImageView(frame: CGRect(x: 90, y: 0, width: 120, height: 120))
        refreshImg.image = #imageLiteral(resourceName: "Reload")
        serverDownView.addSubview(refreshImg)
        
        //Setting up warning view
        let warningView = UITextView(frame: CGRect(x: 0, y: 130, width: 300, height: 50))
        warningView.text = "There is a network issue. Click anywhere to refresh the page.\nIf still doesn't work, please contact admin@fmning.com"
        warningView.font = UIFont(name: (warningView.font?.fontName)!, size: 10)
        warningView.textColor = .gray
        warningView.textAlignment = .center
        warningView.dataDetectorTypes = .all
        warningView.isEditable = false
        serverDownView.addSubview(warningView)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func showServerDownView() {
        self.addSubview(serverDownView)
    }
    
    func removeServerDownView() {
        serverDownView.removeFromSuperview()
    }
    
}
