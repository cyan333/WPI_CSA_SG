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
     | 0    | null | 0     |        1          |
     | null | 0    | 0     |        2          |
     | 0    | 1    | 0     |        3          |
     | 1    | 0    | 1     |        4          |
     */
    func processArticleContent(){
        content = "hahaha<img src=\"1_1.jpg\" height=\"450\" weight=\"450\"/>This is the close"
        var imgTagRange: Range<String.Index>? = content.range(of: "<img")
        let listTagRange: Range<String.Index>? = content.range(of: "<tab")
        
        while let rangCheck = imgTagRange ??  listTagRange {
            if let imgRange = imgTagRange{
                if let listRange = listTagRange{
                    if(imgRange.lowerBound < listRange.lowerBound){ //Condition 3
                        processImageTag(range: imgRange);
                    }else{                                          //Condition 4
                        processListTag(range: listRange);
                    }
                }else{                                              //Condition 1
                    processImageTag(range: rangCheck);
                    imgTagRange = content.range(of: "<img")
                }
            }else{                                                  //Condition 2
                processListTag(range: rangCheck);
            }
        }
        if (content != ""){
            paragraphs.append(Paragraph(content: content))
        }
    }
    
    /* 5 possible conditions
     | imgClose | imageTextClose | choose | condition in code |
     | 10       | null           | 10     |        1          |
     | null     | 10             | 10     |        2          |
     | 10       | 20             | 10     |        3          |
     | 10       | 5              | 5      |        4          |
     | null     | null           | TBD    |        5          |
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
                if(imgTextCloseRange.lowerBound < imgCloseRange.lowerBound){ //Condition 3
                }else{                                                       //Condition 4
                }
            }else{                                                           //Condition 1
                var imgStr = content.substring(to: imgCloseRange.upperBound)
                content = content.substring(from: imgCloseRange.upperBound)
                imgStr = imgStr.replacingOccurrences(of: "<img ", with: "{\"")
                    .replacingOccurrences(of: "/>", with: "}")
                    .replacingOccurrences(of: " />", with: "}")
                    .replacingOccurrences(of: "=\"", with: "\":\"")
                    .replacingOccurrences(of: "\" ", with: "\",\"")
                paragraphs.append(Paragraph(content: "", type: .Image, properties: convertToDictionary(text: imgStr)))
            }
        }else{
            if let imgTextCloseRange = imgTextTagCloseRange {                //Condition 2
                
            }else{                                                           //Condition 5
                
            }
        }
        
    }
    
    func processListTag(range: Range<String.Index>){
    }
    
    func processArticleContent11(){
        content = "<img src=\"1_1.jpg\" height=\"450\" weight=\"450\"/>This is the close"
        let imgTagCloseRange: Range<String.Index>? = content.range(of: "/>")
        let imgTextTagCloseRange: Range<String.Index>? = content.range(of: "</img>")
        if let imgCloseRange = imgTagCloseRange {
            if let imgTextCloseRange = imgTextTagCloseRange {
                if(imgCloseRange.lowerBound < imgTextCloseRange.lowerBound){ //Condition 3
                    print("3")
                }else{                                                       //Condition 4
                    print("4")
                }
            }else{                                                           //Condition 1
                
            }
        }else{                                                               //Condition 2
            print("2")
        }
        //...................................................................................
        var t = "hahahaha wtf1<font a b> and now it should be done"
        var a: Range<String.Index>? = t.range(of: "<font")
        
        if let b = a {
            
            var counter: Int = 0;
            for i in t.characters.indices[b.upperBound..<t.endIndex]{
                counter += 1
                if(t[i] == ">"){
                    break
                }
            }
            let end = t.index((a?.upperBound)!, offsetBy: counter)
            let myRange = (a?.lowerBound)!..<end
            t.removeSubrange(myRange)
            //print(t)
            
            var c = "{\"resource\":\"font\",\"length\":\"9\"}"
            
            if let data = c.data(using: .utf8) {
                do {
                    let a = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
                    if let b = a?["resource"] as? String{
                        //print(b)
                    }
                } catch {
                    print(error.localizedDescription)
                }
            }
        }
        
        
        //print(content[(a?.upperBound)!])
        //print(content[(a?.lowerBound)!])
    }
    
    func convertToDictionary(text: String) -> [String: Any]? {
        if let data = text.data(using: .utf8) {
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
