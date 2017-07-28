//
//  Article.swift
//  WPI_CSA
//
//  Created by NingFangming on 3/29/17.
//  Copyright © 2017 fangming. All rights reserved.
//

import Foundation
import UIKit

class Article{
    var menuId = 0 //Default ID for the SG cover page
    var content: String
    var paragraphs: [Paragraph]
    
    init(content: String){
        self.content = content
        paragraphs = [Paragraph]()
    }
    
    init(title: String, content: String){
        self.content = content
        paragraphs = [Paragraph]()
        if title.range(of: "<") != nil {
            paragraphs.append(Paragraph(content: title.htmlAttributedString(ratio: .Normal), type: .Plain))
        }else{
            let processedTitle = "<center><span style=\"font-weight:bold;font-size:20px;\">" + title + "</span></center>"
            paragraphs.append(Paragraph(content: processedTitle.htmlAttributedString(ratio: .Normal), type: .Plain))
        }
    }
    
    /* 4 possible conditions
     | img  | tab  | check | condition in code |
     | 0    | null | img   |        1          |
     | null | 0    | tab   |        2          |
     | 0    | 1    | img   |        3          |
     | 1    | 0    | tab   |        4          |
     */
    func processContent(){
        var imgTagRange: Range<String.Index>? = content.range(of: "<img")
        var listTagRange: Range<String.Index>? = content.range(of: "<tab>")
        var formatCheck = 0
        
        while let rangeCheck = imgTagRange ??  listTagRange {
            let contentLength = content.characters.count
            if let imgRange = imgTagRange {
                if let listRange = listTagRange {
                    if imgRange.lowerBound < listRange.lowerBound { //Condition 3
                        if formatCheck == contentLength {
                            print("Malformatted. Exist 3")
                            break
                        }
                        processImageTag(range: imgRange);
                        imgTagRange = content.range(of: "<img")
                    }else{                                          //Condition 4
                        if formatCheck == contentLength {
                            print("Malformatted. Exist 4")
                            break
                        }
                        processListTag(range: listRange);
                        listTagRange = content.range(of: "<tab>")
                    }
                }else{                                              //Condition 1
                    if formatCheck == contentLength {
                        print("Malformatted. Exist 1")
                        break
                    }
                    processImageTag(range: rangeCheck);
                    imgTagRange = content.range(of: "<img")
                }
            }else{                                                  //Condition 2
                if formatCheck == contentLength {
                    print("Malformatted. Exist 2")
                    break
                }
                processListTag(range: rangeCheck);
                listTagRange = content.range(of: "<tab>")
            }
            formatCheck = contentLength
        }
        if content != "" {
            paragraphs.append(Paragraph(content: content.htmlAttributedString(ratio: .Enlarged)))
        }
    }
    
    /* 5 possible conditions
     | imgClose | imageTextClose | choose  | condition in code |
     | 10       | null           | img     |        1          |
     | null     | 10             | imgText |        2          |
     | 10       | 20             | img     |        3          |
     | 10       | 5              | imgText |        4          |
     */
    func processImageTag(range: Range<String.Index>){
        let currentContent = content.substring(to: range.lowerBound)
        if currentContent != "" {
            paragraphs.append(Paragraph(content: currentContent.htmlAttributedString(ratio: .Enlarged)))
            content = content.substring(from: range.lowerBound)
        }
        
        let imgTagCloseRange: Range<String.Index>? = content.range(of: "/>")
        let imgTextTagCloseRange: Range<String.Index>? = content.range(of: "</img>")
        if let imgCloseRange = imgTagCloseRange {
            if let imgTextCloseRange = imgTextTagCloseRange {
                if imgCloseRange.lowerBound < imgTextCloseRange.lowerBound { //Condition 3
                    let imgStr = content.substring(to: imgCloseRange.upperBound)
                    content = content.substring(from: imgCloseRange.upperBound)
                    paragraphs.append(Paragraph(content: "".htmlAttributedString(ratio: .Enlarged), type: .Image, properties: convertTagToDictionary(text: imgStr)))
                }else{                                                       //Condition 4
                    let imgStr = content.substring(to: imgTextCloseRange.lowerBound)
                    let tagEndRange: Range<String.Index>? = imgStr.range(of: ">")
                    content = content.substring(from: imgTextCloseRange.upperBound)
                    if let range = tagEndRange {
                        paragraphs.append(Paragraph(content: imgStr.substring(from: range.upperBound).htmlAttributedString(ratio: .Enlarged),
                                                    type: .ImageText,
                                                    properties: convertTagToDictionary(text: imgStr.substring(to: range.upperBound))))
                    }
                }
            }else{                                                           //Condition 1
                let imgStr = content.substring(to: imgCloseRange.upperBound)
                content = content.substring(from: imgCloseRange.upperBound)
                paragraphs.append(Paragraph(content: "".htmlAttributedString(ratio: .Enlarged),
                                            type: .Image, properties: convertTagToDictionary(text: imgStr)))
            }
        }else{                                                               //Condition 2
            if let imgTextCloseRange = imgTextTagCloseRange {
                let imgStr = content.substring(to: imgTextCloseRange.lowerBound)
                let tagEndRange: Range<String.Index>? = imgStr.range(of: ">")
                content = content.substring(from: imgTextCloseRange.upperBound)
                if let range = tagEndRange {
                    paragraphs.append(Paragraph(content: imgStr.substring(from: range.upperBound).htmlAttributedString(ratio: .Enlarged),
                                                type: .ImageText,
                                                properties: convertTagToDictionary(text: imgStr.substring(to: range.upperBound))))
                }
                
            }
            
        }
        
    }
    
    func processListTag(range: Range<String.Index>){
        let currentContent = content.substring(to: range.lowerBound)
        if currentContent != "" {
            paragraphs.append(Paragraph(content: currentContent.htmlAttributedString(ratio: .Enlarged)))
            content = content.substring(from: range.upperBound)
        }
        let listTagCloseRange: Range<String.Index>? = content.range(of: "</tab>")
        if let listCloseRange = listTagCloseRange{
            let listContent = content.substring(to: listCloseRange.lowerBound)
            let listItems = listContent.components(separatedBy: "<tbr>")
            if(listItems.count > 0){
                paragraphs[paragraphs.count - 1].separatorType = .Full //This is valid because of the title cell
                for str in listItems as [String]{
                    let p = Paragraph(content: str.htmlAttributedString(ratio: .Enlarged), type: .Plain)
                    p.separatorType = .Normal
                    paragraphs.append(p)
                }
                paragraphs[paragraphs.count - 1].separatorType = .Full
            }
            
            content = content.substring(from: listCloseRange.upperBound)
        }
    }
    
    func convertTagToDictionary(text: String) -> [String: Any]? {
        let processedText = text.replacingOccurrences(of: "<img ", with: "{\"")
            .replacingOccurrences(of: "/>", with: "}")
            .replacingOccurrences(of: " />", with: "}")
            .replacingOccurrences(of: ">", with: "}")
            .replacingOccurrences(of: " >", with: "}")
            .replacingOccurrences(of: "=\"", with: "\":\"")
            .replacingOccurrences(of: "\" ", with: "\",\"")
        //print(processedText)
        if let data = processedText.data(using: .utf8) {
            do {
                return try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
            } catch {
                //TODO: show friendly message?
                print(error.localizedDescription)
            }
        }
        return nil
    }
    
}

class Paragraph{
    var content: NSAttributedString?
    var type: ParagraphType
    var separatorType = SeparatorType.None
    var properties: [String: Any]?
    
    var cellHeight: CGFloat = 0.0
    var textViewY: CGFloat = 10.0
    var textViewHeight: CGFloat = 130.0
    var imgViewY: CGFloat = 10.0
    var imgViewHeight: CGFloat = 130.0
    
    init(){
        self.content = NSAttributedString(string: "")
        self.type = .Plain
    }
    
    init(content: NSAttributedString?){
        self.content = content
        self.type = .Plain
    }
    
    init(content: NSAttributedString?, type: ParagraphType){
        self.content = content
        self.type = type
    }
    
    init(content: NSAttributedString?, type: ParagraphType, properties: [String: Any]?){
        self.content = content
        self.type = type
        self.properties = properties
    }
}

enum ParagraphType{
    case Plain
    case Image
    case ImageText
    case Table
}

enum SeparatorType{
    case None
    case Full
    case Normal
}


