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
    weak var delegate: EditorButtonClickDelegate?
    
    convenience init(image: UIImage, index: Int) {
        self.init(image: image.withRenderingMode(.alwaysOriginal), style: .plain, target: nil, action: nil)
        target = self
        action = #selector(clicked)
        self.index = index
        
        
    }
    
    
    @objc private func clicked () {
        delegate?.buttonClickedOnIndex(index: index)
    }
}
