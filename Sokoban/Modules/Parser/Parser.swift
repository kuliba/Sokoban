//
//  Parser.swift
//  Sokoban
//
//  Created by Valentin Ozerov on 06.05.2025.
//

import Foundation

@MainActor
final class Parser: NSObject, @preconcurrency ParserProtocol, @preconcurrency XMLParserDelegate {
    // MARK: Collection fields
    private var title = ""
    private var desciption = ""
    private var copyright = ""
    private var levels: [Level] = []
    
    // MARK: XML Parser fields
    private var tag = ""
    private var foundCharacters = ""
    private var levelID = ""
    
    // MARK: Level parser fields
    private var table = Array<Array<Cell>>()
}
 
// MARK: Parse collection
extension Parser {
    func parseCollection(name: String, data: Data) -> Collection? {
        let parser = XMLParser(data: data as Data)
        parser.delegate = self
        
        guard parser.parse() else { return nil }
        
        return .init(
            name: name,
            title: title,
            desciption: desciption,
            copyright: copyright,
            levels: levels
        )
    }
    
    func parser(
        _ parser: XMLParser,
        didStartElement elementName: String,
        namespaceURI: String?,
        qualifiedName qName: String?,
        attributes attributeDict: [String: String]
    ) {
        if elementName.uppercased() == "LEVELCOLLECTION",
           let copyright = attributeDict["Copyright"] {
            self.copyright = copyright.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
        } else if elementName.uppercased() == "LEVEL", let id = attributeDict["Id"] {
            levelID = id
        }
        tag = elementName
    }
    
    func parser(
        _ parser: XMLParser,
        didEndElement elementName: String,
        namespaceURI: String?,
        qualifiedName qName: String?
    ) {
        if elementName.uppercased() == "TITLE" {
            title = foundCharacters.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
            tag = ""
            foundCharacters = ""
        } else if elementName.uppercased() == "DESCRIPTION" {
            desciption = foundCharacters.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
            tag = ""
            foundCharacters = ""
        } else if elementName.uppercased() == "LEVEL" {
            let level = parseLevel(foundCharacters, id: levelID)
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

// MARK: Parse level
extension Parser {
    func parseLevel(_ raw: String, id: String) -> Level {
        var tempArray: Array<String> = raw.components(separatedBy: "\n")
        
        // Level compression algorithm:
        // 1. Remove empty lines
        // 2. Trim leading spaces from all lines
        // 3. Determine the maximum level width
        // 4. Pad all lines with spaces to match the maximum width
        
        // 1. Remove empty lines
        // TODO: переписать на let levelStringsArray = tempArray.filter {...}
        var levelStringsArray: Array<String> = []
        for string in tempArray {
            guard string.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines).count > 0 else {
                continue
            }
            levelStringsArray.append(string)
        }

        // 2. Trim leading spaces from all lines
        // TODO: переписать через map
        while isLeadSpacesExists(array: levelStringsArray) {
            levelStringsArray = deleteLeadSpaces(array: levelStringsArray)
        }

        // 3. Determine the maximum level width
        // TODO: переписать
        var maxColumnsCount = 1
        for string in levelStringsArray {
            if string.count > maxColumnsCount {
                maxColumnsCount = string.count
            }
        }

        // TODO: переписать через map
        tempArray.removeAll()
        var rowString: String
        // 4. Pad all lines with spaces to match the maximum width
        for string in levelStringsArray {
            rowString = string
            if rowString.count < maxColumnsCount {
                for _ in rowString.count...maxColumnsCount - 1 {
                    rowString += " "
                }
            }
            tempArray.append(rowString)
        }

        // TODO: переписать через map
        table.removeAll()
        for string in tempArray {
            table.append(initRow(row: string))
        }
        
        // Initialize the appearance of the walls
        for (i, row) in table.enumerated() {
            for (j, cell) in row.enumerated() {
                guard cell.type == .wall else { continue }
                let wallTopExists = i > 0 && table[i - 1][j].type == .wall
                let wallRightExists = j < table[i].count - 1 && table[i][j + 1].type == .wall
                let wallBottomExists = i < table.count - 1 && table[i + 1][j].type == .wall
                let wallLeftExists = j > 0 && table[i][j - 1].type == .wall

                if wallTopExists && wallRightExists && !wallBottomExists && !wallLeftExists {
                    table[i][j].wallFigure = .topRight
                } else if  wallTopExists &&  wallRightExists && !wallBottomExists &&  wallLeftExists {
                    table[i][j].wallFigure = .topRigthLeft
                } else if  wallTopExists && !wallRightExists && !wallBottomExists &&  wallLeftExists {
                    table[i][j].wallFigure = .topLeft
                } else if  wallTopExists &&  wallRightExists &&  wallBottomExists && !wallLeftExists {
                    table[i][j].wallFigure = .topRightBottom
                } else if  wallTopExists &&  wallRightExists &&  wallBottomExists &&  wallLeftExists {
                    table[i][j].wallFigure = .topRightBottomLeft
                } else if  wallTopExists && !wallRightExists &&  wallBottomExists &&  wallLeftExists {
                    table[i][j].wallFigure = .topBottomLeft
                } else if !wallTopExists &&  wallRightExists &&  wallBottomExists && !wallLeftExists {
                    table[i][j].wallFigure = .rightBottom
                } else if !wallTopExists &&  wallRightExists &&  wallBottomExists &&  wallLeftExists {
                    table[i][j].wallFigure = .rightBottomLeft
                } else if !wallTopExists && !wallRightExists &&  wallBottomExists &&  wallLeftExists {
                    table[i][j].wallFigure = .bottomLeft
                } else if !wallTopExists && !wallRightExists && !wallBottomExists && !wallLeftExists {
                    table[i][j].wallFigure = .center
                } else if !wallTopExists &&  wallRightExists && !wallBottomExists && !wallLeftExists {
                    table[i][j].wallFigure = .right
                } else if !wallTopExists &&  wallRightExists && !wallBottomExists &&  wallLeftExists {
                    table[i][j].wallFigure = .rightLeft
                } else if !wallTopExists && !wallRightExists && !wallBottomExists &&  wallLeftExists {
                    table[i][j].wallFigure = .left
                } else if  wallTopExists && !wallRightExists && !wallBottomExists && !wallLeftExists {
                    table[i][j].wallFigure = .top
                } else if  wallTopExists && !wallRightExists &&  wallBottomExists && !wallLeftExists {
                    table[i][j].wallFigure = .topBottom
                } else if !wallTopExists && !wallRightExists &&  wallBottomExists && !wallLeftExists {
                    table[i][j].wallFigure = .bottom
                } else {
                    table[i][j].wallFigure = .undefined
                }
            }
        }
        
        return .init(
            id: levelID,
            table: table
        )
    }
    
    private func initRow(row: String) -> [Cell] {
        var rowArray: Array<Cell> = []
        
        for character in row {
            let cell = Cell()
            
            switch character {
            case " ":
                cell.type = .empty
            case "#":
                cell.type = .wall
            case "@":
                cell.type = .player
            case "$":
                cell.type = .box
            case ".":
                cell.type = .goal
            case "+":
                cell.type = .playerOnAGoal
            case "*":
                cell.type = .boxOnAGoal
            default:
                cell.type = .undefined
            }
            
            rowArray.append(cell)
        }
        return rowArray
    }

    private func isLeadSpacesExists(array: Array<String>) -> Bool {
        for string in array {
            if string.count > 0 && string.first != " " { return false }
        }
        
        return true
    }
    
    private func deleteLeadSpaces(array: Array<String>) -> Array<String> {
        var result: Array<String> = []
        for string in array {
            var newString: String = string
            newString.remove(at: newString.startIndex)
            result.append(newString)
        }
        return result
    }
}
