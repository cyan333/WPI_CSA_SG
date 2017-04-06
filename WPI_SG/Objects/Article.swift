//
//  Article.swift
//  WPI_SG
//
//  Created by NingFangming on 3/29/17.
//  Copyright © 2017 fangming. All rights reserved.
//

import Foundation

class Article{
    var text: String = ""
    
    init(text: String){
        self.text = text
    }
    
    func processArticleString(){
        var t = "hahahaha wtf <font a b> and now it should be done"
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
            print(t)
            
            var c = "{\"resource\":\"font\",\"length\":\"9\"}"
            
            if let data = c.data(using: .utf8) {
                do {
                    let a = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
                    if let b = a?["resource"] as? String{
                        print(b)
                    }
                } catch {
                    print(error.localizedDescription)
                }
            }
        }
        
        
        //print(text[(a?.upperBound)!])
        //print(text[(a?.lowerBound)!])
    }
    
}

class Paragraph{
    var text: String = ""
    
    init(text: String){
        self.text = text
    }
}
