//
//  SPLevel.swift
//  Sokoban
//
//  Created by Valentin Ozerov on 13.06.17.
//  Copyright © 2017 Valentin Ozerov. All rights reserved.
//

import UIKit
import AVFoundation

class SPLevel: NSObject {

    var table = Array<Array<SPCell>>()
    var id = ""
    var width: Int {
        get { return table[0].count }
    }
    var height: Int {
        get { return table.count }
    }
    var staticElements: Array<UIImageView>?
    var shownPossibleMoves = false
    var shownPossiblePushes = false
    var isProcessing = false
    var selectedBox: SPCell? {
        get {
            for (_, row) in table.enumerated() {
                for (_, cell) in row.enumerated() {
                    if cell.boxSelected { return cell }
                }
            }
            return nil
        }
        set {
            for (_, row) in table.enumerated() {
                for (_, cell) in row.enumerated() {
                    cell.boxSelected = false
                }
            }
        }
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
    }

    func startProcessing() {
        let operaionQueue = OperationQueue()
        operaionQueue.maxConcurrentOperationCount = 1
        for (i, row) in table.enumerated() {
            for (j, cell) in row.enumerated() {
                if cell.type == .player || cell.type == .playerOnAGoal {
                    // Запускаем рассчет возможных передвижений игрока
                    let moveProcessingOperation = SPMoveProcessingOperation(table: table, playerRow: i, playerColumn: j)
//                    moveProcessingOperation.queuePriority = .veryLow
                    operaionQueue.addOperation(moveProcessingOperation)
                } else if cell.type == .box || cell.type == .boxOnAGoal {
                    // Запускаем рассчет возможных перемещений ящика
                    let pushProcessingOperation = SPPushProcessingOperation(table: table, boxRow: i, boxColumn: j)
                    cell.dynamicElement?.alpha = 0.3
//                    pushProcessingOperation.queuePriority = .veryLow
                    operaionQueue.addOperation(pushProcessingOperation)
                }
            }
        }
    }
}
