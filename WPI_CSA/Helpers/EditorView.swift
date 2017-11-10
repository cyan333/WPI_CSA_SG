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
        for i in 0 ... 19 {
            var button: EditorButton!
            
            switch (i){
            case 0:
                button = EditorButton(image: #imageLiteral(resourceName: "Bold.png"), tappedImage: #imageLiteral(resourceName: "BoldTapped.png"), index: i)//bold
            case 1:
                button = EditorButton(image: #imageLiteral(resourceName: "Italic.png"), tappedImage: #imageLiteral(resourceName: "ItalicTapped.png"), index: i)//italic
            case 2:
                button = EditorButton(image: #imageLiteral(resourceName: "Underline.png"), tappedImage: #imageLiteral(resourceName: "UnderlineTapped.png"), index: i)//underline
            case 4:
                button = EditorButton(image: #imageLiteral(resourceName: "AlignLeft.png"), tappedImage: #imageLiteral(resourceName: "AlignLeftTapped.png"), index: i)//left
            case 5:
                button = EditorButton(image: #imageLiteral(resourceName: "AlignCenter.png"), tappedImage: #imageLiteral(resourceName: "AlignCenterTapped.png"), index: i)//center
            case 6:
                button = EditorButton(image: #imageLiteral(resourceName: "AlignRight.png"), tappedImage: #imageLiteral(resourceName: "AlignRightTapped.png"), index: i)//right
            case 8:
                button = EditorButton(image: #imageLiteral(resourceName: "TextSize15.png"), tappedImage: #imageLiteral(resourceName: "TextSize15Tapped.png"), index: i)//15
            case 9:
                button = EditorButton(image: #imageLiteral(resourceName: "TextSize20.png"), tappedImage: #imageLiteral(resourceName: "TextSize20Tapped.png"), index: i)//20
            case 10:
                button = EditorButton(image: #imageLiteral(resourceName: "TextSize36.png"), tappedImage: #imageLiteral(resourceName: "TextSize36Tapped.png"), index: i)//36
            case 11:
                button = EditorButton(image: #imageLiteral(resourceName: "TextSize72.png"), tappedImage: #imageLiteral(resourceName: "TextSize72Tapped.png"), index: i)//72
            case 13:
                button = EditorButton(image: #imageLiteral(resourceName: "ColorBlack.png"), tappedImage: #imageLiteral(resourceName: "ColorBlackTapped.png"), index: i)//black
            case 14:
                button = EditorButton(image: #imageLiteral(resourceName: "ColorRed.png"), tappedImage: #imageLiteral(resourceName: "ColorRedTapped.png"), index: i)//red
            case 15:
                button = EditorButton(image: #imageLiteral(resourceName: "ColorBlue.png"), tappedImage: #imageLiteral(resourceName: "ColorBlueTapped.png"), index: i)//blue
            case 16:
                button = EditorButton(image: #imageLiteral(resourceName: "ColorYellow.png"), tappedImage: #imageLiteral(resourceName: "ColorYellowTapped.png"), index: i)//yellow
            case 17:
                button = EditorButton(image: #imageLiteral(resourceName: "ColorGray.png"), tappedImage: #imageLiteral(resourceName: "ColorGrayTapped.png"), index: i)//gray
            case 18:
                button = EditorButton(image: #imageLiteral(resourceName: "ColorGreen.png"), tappedImage: #imageLiteral(resourceName: "ColorGreenTapped.png"), index: i)//green
            case 19:
                button = EditorButton(image: #imageLiteral(resourceName: "ColorPink.png"), tappedImage: #imageLiteral(resourceName: "ColorPinkTapped.png"), index: i)//pink
            default:
                button = EditorButton(image: #imageLiteral(resourceName: "EditorSeparator.png"), tappedImage: #imageLiteral(resourceName: "EditorSeparator.png"), index: i)//separator
            }
            
            button.delegate = self
            buttons.append(button)
            
        }
        
        toolbar.items = buttons
        
        
        let defaultIconWidth: CGFloat = 30
        let barButtonItemMargin: CGFloat = 12
        let width: CGFloat = buttons.reduce(0) {sofar, new in
            if let image = new.image {
                return sofar + image.size.width + barButtonItemMargin
            } else {
                return sofar + defaultIconWidth + barButtonItemMargin
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
        
    }
    
    
}
