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
    
    let editorFontSize = ["15", "17", "20", "22", "25", "30", "35", "40", "48", "56", "72"]
    let editorFontColor = ["black", "red", "blue", "yellow", "gray", "green"]
    let editorAlignment = ["left", "center", "right"]
    
    var bold = false
    var italic = false
    var underline = false
    var textAlign = 1
    
    
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
                button = EditorButton(image: #imageLiteral(resourceName: "EditorBold"), tappedImage: #imageLiteral(resourceName: "EditorBoldTapped"), index: i)//bold
            case 1:
                button = EditorButton(image: #imageLiteral(resourceName: "EditorItalic"), tappedImage: #imageLiteral(resourceName: "EditorItalicTapped"), index: i)//italic
            case 2:
                button = EditorButton(image: #imageLiteral(resourceName: "EditorUnderline"), tappedImage: #imageLiteral(resourceName: "EditorUnderlineTapped"), index: i)//underline
            case 4:
                button = EditorButton(image: #imageLiteral(resourceName: "EditorAlignLeft"), tappedImage: #imageLiteral(resourceName: "EditorAlignLeftTapped"), index: i)//left
            case 5:
                button = EditorButton(image: #imageLiteral(resourceName: "EditorAlignCenter"), tappedImage: #imageLiteral(resourceName: "EditorAlignCenterTapped"), index: i)//center
            case 6:
                button = EditorButton(image: #imageLiteral(resourceName: "EditorAlignRight"), tappedImage: #imageLiteral(resourceName: "EditorAlignRightTapped"), index: i)//right
            case 8:
                button = EditorButton(image: #imageLiteral(resourceName: "EditorSize15"), tappedImage: #imageLiteral(resourceName: "EditorSize15Tapped"), index: i)//15
            case 9:
                button = EditorButton(image: #imageLiteral(resourceName: "EditorSize20"), tappedImage: #imageLiteral(resourceName: "EditorSize20Tapped"), index: i)//20
            case 10:
                button = EditorButton(image: #imageLiteral(resourceName: "EditorSize36"), tappedImage: #imageLiteral(resourceName: "EditorSize36Tapped"), index: i)//36
            case 11:
                button = EditorButton(image: #imageLiteral(resourceName: "EditorSize72"), tappedImage: #imageLiteral(resourceName: "EditorSize72Tapped"), index: i)//72
            case 13:
                button = EditorButton(image: #imageLiteral(resourceName: "EditorColorBlack"), tappedImage: #imageLiteral(resourceName: "EditorColorBlackTapped"), index: i)//black
            case 14:
                button = EditorButton(image: #imageLiteral(resourceName: "EditorColorRed"), tappedImage: #imageLiteral(resourceName: "EditorColorRedTapped"), index: i)//red
            case 15:
                button = EditorButton(image: #imageLiteral(resourceName: "EditorColorBlue"), tappedImage: #imageLiteral(resourceName: "EditorColorBlueTapped"), index: i)//blue
            case 16:
                button = EditorButton(image: #imageLiteral(resourceName: "EditorColorYellow"), tappedImage: #imageLiteral(resourceName: "EditorColorYellowTapped"), index: i)//yellow
            case 17:
                button = EditorButton(image: #imageLiteral(resourceName: "EditorColorGray"), tappedImage: #imageLiteral(resourceName: "EditorColorGrayTapped"), index: i)//gray
            case 18:
                button = EditorButton(image: #imageLiteral(resourceName: "EditorColorGreen"), tappedImage: #imageLiteral(resourceName: "EditorColorGreenTapped"), index: i)//green
            case 19:
                button = EditorButton(image: #imageLiteral(resourceName: "EditorColorPink"), tappedImage: #imageLiteral(resourceName: "EditorColorPinkTapped"), index: i)//pink
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
