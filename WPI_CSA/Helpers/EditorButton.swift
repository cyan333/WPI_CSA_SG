//
//  EditorButton.swift
//  WPI_CSA
//
//  Created by Fangming Ning on 11/6/17.
//  Copyright © 2017 fangming. All rights reserved.
//

import UIKit

protocol EditorButtonClickDelegate: class {
    func buttonClickedOnIndex(index: Int)
}


class EditorButton: UIBarButtonItem {
    var index = 0
    var tapped = false
    var untappedImage = UIImage()
    var tappedImage = UIImage()
    
    weak var delegate: EditorButtonClickDelegate?
    
    convenience init(image: UIImage, tappedImage: UIImage, index: Int) {
        self.init(image: image.withRenderingMode(.alwaysOriginal), style: .plain, target: nil, action: nil)
        target = self
        action = #selector(clicked)
        self.index = index
        
        untappedImage = image
        self.tappedImage = tappedImage
        
    }
    
    
    @objc private func clicked () {
        if tapped {
            self.image = untappedImage.withRenderingMode(.alwaysOriginal)
        } else {
            self.image = tappedImage.withRenderingMode(.alwaysOriginal)
        }
        tapped = !tapped
        
        delegate?.buttonClickedOnIndex(index: index)
    }
}
