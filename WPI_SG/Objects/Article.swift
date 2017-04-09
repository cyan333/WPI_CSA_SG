//
//  Article.swift
//  WPI_SG
//
//  Created by NingFangming on 3/29/17.
//  Copyright © 2017 fangming. All rights reserved.
//

import Foundation

class Article{
    var content: String
    var paragraphs: [Paragraph]
    
    init(title: String, content: String){
        self.content = content
        paragraphs = [Paragraph]()
        paragraphs.append(Paragraph(content: title))
        processArticleContent()
    }
    
    /* 4 possible conditions
     | img  | tab  | check | condition in code |
     | 0    | null | img   |        1          |
     | null | 0    | tab   |        2          |
     | 0    | 1    | img   |        3          |
     | 1    | 0    | tab   |        4          |
     */
    func processArticleContent(){
        content = "hahaha<img src=\"1_1.jpg\" height=\"450\" weight=\"450\">This is the close</img>This is the re/>al close"
        var imgTagRange: Range<String.Index>? = content.range(of: "<img")
        var listTagRange: Range<String.Index>? = content.range(of: "<tab")
        var previousTagRange: Range<String.Index>?
        
        while let rangeCheck = imgTagRange ??  listTagRange {
            if let imgRange = imgTagRange{
                if let listRange = listTagRange{
                    if(imgRange.lowerBound < listRange.lowerBound){ //Condition 3
                        if let previousRange = previousTagRange{
                            if (previousRange.lowerBound == imgRange.lowerBound){
                                print("Malformatted. Exist 3")
                                break
                            }
                        }
                        previousTagRange = imgRange
                        processImageTag(range: imgRange);
                        imgTagRange = content.range(of: "<img")
                    }else{                                          //Condition 4
                        if let previousRange = previousTagRange{
                            if (previousRange.lowerBound == listRange.lowerBound){
                                print("Malformatted. Exist 4")
                                break
                            }
                        }
                        previousTagRange = listRange
                        processListTag(range: listRange);
                        listTagRange = content.range(of: "<tab")
                    }
                }else{                                              //Condition 1
                    if let previousRange = previousTagRange{
                        if (previousRange.lowerBound == rangeCheck.lowerBound){
                            print("Malformatted. Exist 1")
                            break
                        }
                    }
                    previousTagRange = rangeCheck
                    processImageTag(range: rangeCheck);
                    imgTagRange = content.range(of: "<img")
                }
            }else{                                                  //Condition 2
                if let previousRange = previousTagRange{
                    if (previousRange.lowerBound == rangeCheck.lowerBound){
                        print("Malformatted. Exist 2")
                        break
                    }
                }
                previousTagRange = rangeCheck
                processListTag(range: rangeCheck);
                listTagRange = content.range(of: "<tab")
            }
        }
        if (content != ""){
            paragraphs.append(Paragraph(content: content))
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
        if(currentContent != ""){
            paragraphs.append(Paragraph(content: currentContent))
            content = content.substring(from: range.lowerBound)
        }
        
        let imgTagCloseRange: Range<String.Index>? = content.range(of: "/>")
        let imgTextTagCloseRange: Range<String.Index>? = content.range(of: "</img>")
        if let imgCloseRange = imgTagCloseRange {
            if let imgTextCloseRange = imgTextTagCloseRange {
                if(imgCloseRange.lowerBound < imgTextCloseRange.lowerBound){ //Condition 3
                    let imgStr = content.substring(to: imgCloseRange.upperBound)
                    content = content.substring(from: imgCloseRange.upperBound)
                    paragraphs.append(Paragraph(content: "", type: .Image, properties: convertTagToDictionary(text: imgStr)))
                }else{                                                       //Condition 4
                    print("4")
                    let imgStr = content.substring(to: imgTextCloseRange.lowerBound)
                    let tagEndRange: Range<String.Index>? = imgStr.range(of: ">")
                    content = content.substring(from: imgTextCloseRange.upperBound)
                    if let range = tagEndRange{
                        paragraphs.append(Paragraph(content: imgStr.substring(from: range.upperBound),
                                                    type: .ImageText,
                                                    properties: convertTagToDictionary(text: imgStr.substring(to: range.upperBound))))
                    }
                }
            }else{                                                           //Condition 1
                let imgStr = content.substring(to: imgCloseRange.upperBound)
                content = content.substring(from: imgCloseRange.upperBound)
                paragraphs.append(Paragraph(content: "", type: .Image, properties: convertTagToDictionary(text: imgStr)))
            }
        }else{                                                               //Condition 2
            if let imgTextCloseRange = imgTextTagCloseRange {
                let imgStr = content.substring(to: imgTextCloseRange.lowerBound)
                let tagEndRange: Range<String.Index>? = imgStr.range(of: ">")
                content = content.substring(from: imgTextCloseRange.upperBound)
                if let range = tagEndRange{
                    paragraphs.append(Paragraph(content: imgStr.substring(from: range.upperBound),
                                                type: .ImageText,
                                                properties: convertTagToDictionary(text: imgStr.substring(to: range.upperBound))))
                }
                
            }
            
        }
        
    }
    
    func processListTag(range: Range<String.Index>){
    }
    
    func convertTagToDictionary(text: String) -> [String: Any]? {
        let processedText = text.replacingOccurrences(of: "<img ", with: "{\"")
                                .replacingOccurrences(of: "/>", with: "}")
                                .replacingOccurrences(of: " />", with: "}")
                                .replacingOccurrences(of: ">", with: "}")
                                .replacingOccurrences(of: " >", with: "}")
                                .replacingOccurrences(of: "=\"", with: "\":\"")
                                .replacingOccurrences(of: "\" ", with: "\",\"")
        if let data = processedText.data(using: .utf8) {
            do {
                return try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
            } catch {
                print(error.localizedDescription)
            }
        }
        return nil
    }
    
}

class Paragraph{
    var content: String
    var type: ParagraphType
    var properties: [String: Any]?
    
    init(content: String){
        self.content = content
        self.type = .Plain
    }
    
    init(content: String, type: ParagraphType){
        self.content = content
        self.type = type
    }
    
    init(content: String, type: ParagraphType, properties: [String: Any]?){
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
