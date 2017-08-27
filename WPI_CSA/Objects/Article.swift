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
    
    var prevMenuId: Int?
    var prevMenuText: String?
    var nextMenuId: Int?
    var nextMenuText: String?
    
    init(content: String){
        self.content = content
        paragraphs = [Paragraph]()
    }
    
    func processContent(){
        
        let regex = try! NSRegularExpression(pattern:
            "(<img.*?\\/>)|(<imgtxt.*?<\\/imgtxt>)|(<txtimg.*?<\\/txtimg>)|(<tab.*?<\\/tab>)")
        let matchs = regex.matches(in: content, range: NSRange(location: 0, length: content.characters.count))
            .map{(content as NSString).substring(with: $0.range)}
        let count = matchs.count
        
        for i in 0 ..< count {
            let parts = content.components(separatedBy: matchs[i])
            let first = parts[0]
            var paraType = ParagraphType.Plain
            if first.characters.count > 0 {
                paraType = getParagraphType(string: first)
                paragraphs.append(Paragraph(content: first.htmlAttributedString(ratio: .Enlarged), type: paraType))
            }
            
            paraType = getParagraphType(string: matchs[i])
            switch paraType {
            case .Image:
                paragraphs.append(Paragraph(content: "".htmlAttributedString(ratio: .Enlarged), type: .Image, properties: convertTagToDictionary(text: matchs[i])))
                break
            case .ImageText, .TextImage:
                let imgStr = matchs[i].substring(to: matchs[i].index(matchs[i].endIndex, offsetBy: -9))
                let separator = imgStr.range(of: ">")
                paragraphs.append(Paragraph(content: imgStr.substring(from: separator!.upperBound)
                    .htmlAttributedString(ratio: .Enlarged),
                                            type: paraType,
                                            properties: convertTagToDictionary(text:
                                                imgStr.substring(to: separator!.lowerBound))))
                break
            case .Table:
                let listItems = matchs[i].replacingOccurrences(of: "<tab>", with: "")
                    .replacingOccurrences(of: "</tab>", with: "")
                    .components(separatedBy: "<tbr>")
                if(listItems.count > 0){
                    paragraphs[paragraphs.count - 1].separatorType = .Full //This is valid because of the title cell
                    for str in listItems as [String]{
                        let p = Paragraph(content: str.htmlAttributedString(ratio: .Enlarged), type: .Plain)
                        p.separatorType = .Normal
                        paragraphs.append(p)
                    }
                    paragraphs[paragraphs.count - 1].separatorType = .Full
                }
                break
            default:
                break
            }
            
            content = parts[1]
        }
        
        if content != "" {
            paragraphs.append(Paragraph(content: content.htmlAttributedString(ratio: .Enlarged)))
        }

        
    }
    
    func getParagraphType(string: String) -> ParagraphType {
        if !string.hasPrefix("<") {
            return .Plain
        }else if string.hasPrefix("<imgtxt") {
            return .ImageText
        } else if string.hasPrefix("<img") {
            return .Image
        } else if string.hasPrefix("<tab") {
            return .Table
        } else if string.hasPrefix("<txtimg") {
            return .TextImage
        } else {
            return .Plain
        }
    }
    
        
    func convertTagToDictionary(text: String) -> [String: Any]? {
        let preText = text.hasSuffix(">") ? text : text + ">"
        let processedText = preText.replacingOccurrences(of: "<img ", with: "{\"")
            .replacingOccurrences(of: "<imgtxt ", with: "{\"")
            .replacingOccurrences(of: "<txtimg ", with: "{\"")
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
    case TextImage
    case Table
}

enum SeparatorType{
    case None
    case Full
    case Normal
}


