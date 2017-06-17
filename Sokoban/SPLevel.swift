//
//  SPLevel.swift
//  Sokoban
//
//  Created by Valentin Ozerov on 13.06.17.
//  Copyright © 2017 Valentin Ozerov. All rights reserved.
//

import UIKit

class SPLevel: NSObject {

    var table = Array<Array<SPCell>>()
    var id = ""
    var width: Int {
        get { return table[0].count }
    }
    var height: Int {
        get { return table.count }
    }
    
    func Load(level: String, id: String) {
        
        self.id = id
        
        func initRow(rowString: String) -> (Array<SPCell>) {
            var rowArray: Array<SPCell> = []
            
            for character in rowString.characters {
                let cell = SPCell()
                
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
        
        func isLeadSpacesExists(array: Array<String>) -> Bool {
            for string in array {
                if string.characters.count > 0 && string.characters.first != " " { return false }
            }
            
            return true
        }
        
        func deleteLeadSpaces(array: Array<String>) -> Array<String> {
            var result: Array<String> = []
            for string in array {
                var newString: String = string
                newString.remove(at: newString.startIndex)
                result.append(newString)
            }
            return result
        }
        
        var tempArray: Array<String> = level.components(separatedBy: "\n")
        
        // Алгоритм компрессии уровня
        // 1. Удаляем пустые строки
        // 2. Удаляем ведущие пробелы во всех строках
        // 3. Вычисляем максимальную ширину уровня
        // 4. Дополняем пробелами строки до максимальной ширины

        // 1. Удаляем пустые строки
        var levelStringsArray: Array<String> = []
        for string in tempArray {
            guard string.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines).characters.count > 0 else { continue }
            levelStringsArray.append(string)
        }

        // 2. Удаляем ведущие пробелы во всех строках
        while isLeadSpacesExists(array: levelStringsArray) {
            levelStringsArray = deleteLeadSpaces(array: levelStringsArray)
        }

        // 3. Вычисляем максимальную ширину уровня
        var maxColumnsCount = 1
        for string in levelStringsArray {
            if string.characters.count > maxColumnsCount {
                maxColumnsCount = string.characters.count
            }
        }

        tempArray.removeAll()
        var rowString: String
        // 4. Дополняем пробелами строки до максимальной ширины
        for string in levelStringsArray {
            rowString = string
            if rowString.characters.count < maxColumnsCount {
                for _ in rowString.characters.count...maxColumnsCount - 1 {
                    rowString += " "
                }
            }
            tempArray.append(rowString)
        }

        table.removeAll()
        for string in tempArray {
            table.append(initRow(rowString: string))
        }
        
        // инициализируем внешний вид стенок
        for i in 0...table.count - 1 {
            for j in 0...table[i].count {
                guard table[i][j].type == .wall else { continue }
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
                    table[i][j].wallFigure = .topRigthLeft
                } else if  wallTopExists && !wallRightExists &&  wallBottomExists && !wallLeftExists {
                    table[i][j].wallFigure = .topBottom
                } else if !wallTopExists && !wallRightExists && !wallBottomExists && !wallLeftExists {
                    table[i][j].wallFigure = .bottom
                }
            }
        }
    }
}
