//
//  EditorView.swift
//  WPI_CSA
//
//  Created by Fangming Ning on 11/6/17.
//  Copyright © 2017 fangming. All rights reserved.
//

import UIKit

open class EditorView: UIView {
    private var toolbarScroll: UIScrollView
    private var toolbar: UIToolbar
    private var backgroundToolbar: UIToolbar
    
    private var flag = true
    
    public override init(frame: CGRect) {
        toolbarScroll = UIScrollView()
        toolbar = UIToolbar()
        backgroundToolbar = UIToolbar()
        super.init(frame: frame)
        setup()
    }
    
    public required init?(coder aDecoder: NSCoder) {
        toolbarScroll = UIScrollView()
        toolbar = UIToolbar()
        backgroundToolbar = UIToolbar()
        super.init(coder: aDecoder)
        setup()
    }
    
    private func setup() {
        autoresizingMask = .flexibleWidth
        backgroundColor = .clear
        
        backgroundToolbar.frame = bounds
        backgroundToolbar.autoresizingMask = [.flexibleHeight, .flexibleWidth]
        
        toolbar.autoresizingMask = .flexibleWidth
        toolbar.backgroundColor = .clear
        toolbar.setBackgroundImage(UIImage(), forToolbarPosition: .any, barMetrics: .default)
        toolbar.setShadowImage(UIImage(), forToolbarPosition: .any)
        
        toolbarScroll.frame = bounds
        toolbarScroll.autoresizingMask = [.flexibleHeight, .flexibleWidth]
        toolbarScroll.showsHorizontalScrollIndicator = false
        toolbarScroll.showsVerticalScrollIndicator = false
        toolbarScroll.backgroundColor = .clear
        
        toolbarScroll.addSubview(toolbar)
        
        addSubview(backgroundToolbar)
        addSubview(toolbarScroll)
        
        
        var buttons = [UIBarButtonItem]()
        for i in 0 ... 15 {
            let button = EditorButton(image: #imageLiteral(resourceName: "menuExpanded.png"), index: i)
            button.delegate = self
            buttons.append(button)
            
        }
        
        toolbar.items = buttons
        
        
        let defaultIconWidth: CGFloat = 30
        let barButtonItemMargin: CGFloat = 11
        let width: CGFloat = buttons.reduce(0) {sofar, new in
            if let image = new.image {
                return sofar + image.size.width + barButtonItemMargin
            } else {
                return sofar + (defaultIconWidth + barButtonItemMargin)
            }
        }
        
        if width < frame.size.width {
            toolbar.frame.size.width = frame.size.width
        } else {
            toolbar.frame.size.width = width
        }
        toolbar.frame.size.height = 44
        toolbarScroll.contentSize.width = width
    }
    
    
}

extension EditorView: EditorButtonClickDelegate {
    func buttonClickedOnIndex(index: Int) {
        print(index)
        if flag {
            let button = toolbar.items![index]
            button.image = #imageLiteral(resourceName: "verified.png").withRenderingMode(.alwaysOriginal)
            flag = false
        } else {
            let button = toolbar.items![index]
            button.image = #imageLiteral(resourceName: "menuExpanded.png").withRenderingMode(.alwaysOriginal)
            flag = true
            
        }
    }
    
    
}
