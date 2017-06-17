//
//  SPLevelCollection.swift
//  Sokoban
//
//  Created by Valentin Ozerov on 06.06.17.
//  Copyright © 2017 Valentin Ozerov. All rights reserved.
//

import UIKit

class SPLevelCollection: NSObject, XMLParserDelegate {

    static let shared = SPLevelCollection()
    
    var title: String = ""
    var desciption: String = ""
    var copyright: String = ""
    var fileName: String = ""
    var levels: [SPLevel] = []
    var currentLevel: SPLevel {
        get {
            let currentLevelId = SPSettings.shared.CurrentLevelId
            for level in self.levels {
                if level.id == currentLevelId {
                    return level
                }
            }
            if levels.count > 0 {
                return levels.first!
            } else {
                return SPLevel()
            }
        }
    }
    
    func Load(FileName: String) {
        self.fileName = FileName
        let path = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0] as String
        let url = NSURL(fileURLWithPath: path)
        let filePath = url.appendingPathComponent("/Levels/" + FileName + ".slc")?.path
        if let data: NSData = NSData(contentsOfFile: filePath!) {
            let parser = XMLParser(data: data as Data)
            parser.delegate = self
            
            let success: Bool = parser.parse()
            
            if success {
//                print("parse success!")
            } else {
                print("parse failure!")
            }
        }
    }
    
    var tag = ""
    var foundCharacters = ""
    var levelId = ""
    
    func parser(_ parser: XMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [String : String]) {
        if elementName.uppercased() == "LEVELCOLLECTION" {
            if let copyright = attributeDict["Copyright"] {
                self.copyright = copyright.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
            }
        } else if elementName.uppercased() == "LEVEL" {
            if let Id = attributeDict["Id"] {
                levelId = Id
            }
        }
        tag = elementName
    }
    
    func parser(_ parser: XMLParser, didEndElement elementName: String, namespaceURI: String?, qualifiedName qName: String?) {
        if elementName.uppercased() == "TITLE" {
            title = foundCharacters.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
            tag = ""
            foundCharacters = ""
        } else if elementName.uppercased() == "DESCRIPTION" {
            desciption = foundCharacters.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
            tag = ""
            foundCharacters = ""
        } else if elementName.uppercased() == "LEVEL" {
            let level: SPLevel = SPLevel()
            level.Load(level: foundCharacters, id: levelId)
            levels.append(level)
            tag = ""
            foundCharacters = ""
        }
        
    }
    
    func parser(_ parser: XMLParser, parseErrorOccurred parseError: Error) {
        print("failure error: ", parseError.localizedDescription)
    }
    
    func parser(_ parser: XMLParser, foundCharacters string: String) {
        if !tag.isEmpty {
            foundCharacters += string
        }
    }
}
