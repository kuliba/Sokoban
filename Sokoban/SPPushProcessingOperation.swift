//
//  SPPushProcessingOperation.swift
//  Sokoban
//
//  Created by Valentin Ozerov on 07.08.17.
//  Copyright © 2017 Valentin Ozerov. All rights reserved.
//

import UIKit

class SPPushProcessingOperation: Operation {

    var table: Array<Array<SPCell>> = []
    var initBoxRow = -1
    var initBoxColumn = -1
    lazy var processingCells: Array<(Int, Int)> = []
    
    init(table: Array<Array<SPCell>>, boxRow: Int, boxColumn: Int) {
        self.table = table
        self.initBoxRow = boxRow
        self.initBoxColumn = boxColumn
    }

    override func main() {
        
        var MD5Array = Array<String>()
        
        func canToPush(levelTable: Array<Array<SPCell>>, keyCellsInfo: keyCellsInfo) -> Bool {
            
            if keyCellsInfo.playerRow == -1 || keyCellsInfo.playerColumn == -1 || keyCellsInfo.boxRow == -1 || keyCellsInfo.boxColumn == -1 { return false }
            
            if keyCellsInfo.playerRow != keyCellsInfo.boxRow && keyCellsInfo.playerColumn != keyCellsInfo.boxColumn { return false }
            
            var direction: playerMoveDirection
            
            if keyCellsInfo.playerRow == keyCellsInfo.boxRow + 1 { direction =  .bottomToTop} else
                if keyCellsInfo.playerRow == keyCellsInfo.boxRow - 1 { direction = .topToBottom } else
                    if keyCellsInfo.playerColumn == keyCellsInfo.boxColumn - 1 { direction = .leftToRight } else
                        if keyCellsInfo.playerColumn == keyCellsInfo.boxColumn + 1 { direction = .rightToLeft } else { return false }
            
            var nextCell = SPCell()
            
            switch direction {
            case .bottomToTop:
                // Проверяем возможность перемещения ящика на клетку выше
                if keyCellsInfo.boxRow == 0 { return false } // Ящик стоит на верхней клетке, выше некуда
                nextCell = levelTable[keyCellsInfo.boxRow - 1][keyCellsInfo.boxColumn]
            case .topToBottom:
                // Проверяем возможность перемещения ящика на клетку ниже
                if keyCellsInfo.boxRow == levelTable.count - 1 { return false } // Ящик стоит на самом дне, ниже некуда
                nextCell = levelTable[keyCellsInfo.boxRow + 1][keyCellsInfo.boxColumn]
            case .leftToRight:
                // Проверяем возможность перемещения ящика на клетку правее
                if keyCellsInfo.boxColumn == (levelTable.first?.count)! - 1 { return false } // Ящик стоит на самой правой позиции
                nextCell = levelTable[keyCellsInfo.boxRow][keyCellsInfo.boxColumn + 1]
            case .rightToLeft:
                // Проверяем возможность перемещения ящика на клетку левее
                if keyCellsInfo.boxColumn == 0 { return false } // Ящик стоит на самой левой позиции
                nextCell = levelTable[keyCellsInfo.boxRow][keyCellsInfo.boxColumn - 1]
            default:
                break
            }
            
            return nextCell.type == .empty || nextCell.type == .goal
        }
        
        func push(levelTable: Array<Array<SPCell>>) -> Array<Array<SPCell>> {
            var newTable = copyTable(table: levelTable)
            
            let keyCellsInfo = getKeyCellsInfo(table: newTable)
            
            var nextRow = -1
            var nextColumn = -1
            
            var direction: playerMoveDirection = .rightToLeft
            
            if keyCellsInfo.playerRow == keyCellsInfo.boxRow + 1 { direction =  .bottomToTop} else
                if keyCellsInfo.playerRow == keyCellsInfo.boxRow - 1 { direction = .topToBottom } else
                    if keyCellsInfo.playerColumn == keyCellsInfo.boxColumn - 1 { direction = .leftToRight }
            
            var nextCell = SPCell()
            
            switch direction {
            case .bottomToTop:
                nextCell = newTable[keyCellsInfo.boxRow - 1][keyCellsInfo.boxColumn]
                nextRow = keyCellsInfo.boxRow - 1
                nextColumn = keyCellsInfo.boxColumn
            case .topToBottom:
                nextCell = newTable[keyCellsInfo.boxRow + 1][keyCellsInfo.boxColumn]
                nextRow = keyCellsInfo.boxRow + 1
                nextColumn = keyCellsInfo.boxColumn
            case .leftToRight:
                nextCell = newTable[keyCellsInfo.boxRow][keyCellsInfo.boxColumn + 1]
                nextRow = keyCellsInfo.boxRow
                nextColumn = keyCellsInfo.boxColumn + 1
            case .rightToLeft:
                nextCell = newTable[keyCellsInfo.boxRow][keyCellsInfo.boxColumn - 1]
                nextRow = keyCellsInfo.boxRow
                nextColumn = keyCellsInfo.boxColumn - 1
            default:
                break
            }
            
            // Отмечаем ячейку как возможную для перемещения ящика
            if (nextCell.type == .empty || nextCell.type == .goal) {
                processingCells.append((nextRow, nextColumn))
            }
            
            if nextCell.type == .empty {
                nextCell.type = .box
            } else if nextCell.type == .goal {
                nextCell.type = .boxOnAGoal
            }
            
            if keyCellsInfo.boxCell?.type == .box {
                keyCellsInfo.boxCell?.type = .empty
            } else if keyCellsInfo.boxCell?.type == .boxOnAGoal {
                keyCellsInfo.boxCell?.type = .goal
            }
            
            // Перемещаем игрока
            if keyCellsInfo.boxCell?.type == .empty {
                keyCellsInfo.boxCell?.type = .player
            } else if keyCellsInfo.boxCell?.type == .goal {
                keyCellsInfo.boxCell?.type = .playerOnAGoal
            }
            
            if keyCellsInfo.playerCell?.type == .player {
                keyCellsInfo.playerCell?.type = .empty
            } else if keyCellsInfo.playerCell?.type == .playerOnAGoal {
                keyCellsInfo.playerCell?.type = .goal
            }
            
            for (i, row) in newTable.enumerated() {
                for (j, cell) in row.enumerated() {
                    cell.boxSelected = i == nextRow && j == nextColumn
                }
            }
            
            return newTable
        }
        
        func move(levelTable: Array<Array<SPCell>>, direction: playerMoveDirection) -> Array<Array<SPCell>> {
            var newTable = copyTable(table: levelTable)
            let keyCellsInfo = getKeyCellsInfo(table: newTable)

            var nextCell = SPCell()
            
            switch direction {
            case .bottomToTop:
                nextCell = newTable[keyCellsInfo.playerRow - 1][keyCellsInfo.playerColumn]
            case .topToBottom:
                nextCell = newTable[keyCellsInfo.playerRow + 1][keyCellsInfo.playerColumn]
            case .leftToRight:
                nextCell = newTable[keyCellsInfo.playerRow][keyCellsInfo.playerColumn + 1]
            case .rightToLeft:
                nextCell = newTable[keyCellsInfo.playerRow][keyCellsInfo.playerColumn - 1]
            default:
                break
            }
            
            if keyCellsInfo.playerCell?.type == .player {
                keyCellsInfo.playerCell?.type = .empty
            } else if keyCellsInfo.playerCell?.type == .playerOnAGoal {
                keyCellsInfo.playerCell?.type = .goal
            }
            
            if nextCell.type == .empty {
                nextCell.type = .player
            } else if nextCell.type == .goal {
                nextCell.type = .playerOnAGoal
            }

            return newTable
        }
        
        func checkPossibleToPush(levelTable: Array<Array<SPCell>>, path: String) {

            let levelString = levelToString(table: levelTable)
            let MD5String = MD5(levelString)
 
            if MD5Array.contains(MD5String) { return }
            MD5Array.append(MD5String)
            
            for k in 0...3 {
                let keyCellsInfo = getKeyCellsInfo(table: levelTable)
                
                if self.isCancelled { return }

                switch k {
                case 0:
                    // Проверяем возможность пойти или толкнуть наверх
                    if keyCellsInfo.playerRow > 0 {
                        let nextCell = levelTable[keyCellsInfo.playerRow - 1][keyCellsInfo.playerColumn]
                        if nextCell.type == .empty || nextCell.type == .goal {
                            let newLevelTable = move(levelTable: levelTable, direction: .bottomToTop)
                            var newPath = path
                            newPath.append("u")
                            checkPossibleToPush(levelTable: newLevelTable, path: newPath)
                        } else if keyCellsInfo.boxRow == keyCellsInfo.playerRow - 1 && keyCellsInfo.boxColumn == keyCellsInfo.playerColumn && canToPush(levelTable: levelTable, keyCellsInfo: keyCellsInfo) {
                            let newLevelTable = push(levelTable: levelTable)
                            var newPath = path
                            newPath.append("U")
                            checkPossibleToPush(levelTable: newLevelTable, path: newPath)
                        }
                    }
                case 1:
                    // Проверяем возможность пойти или толкнуть направо
                    if keyCellsInfo.playerColumn < levelTable[keyCellsInfo.playerRow].count - 1 {
                        let nextCell = levelTable[keyCellsInfo.playerRow][keyCellsInfo.playerColumn + 1]
                        if nextCell.type == .empty || nextCell.type == .goal {
                            let newLevelTable = move(levelTable: levelTable, direction: .leftToRight)
                            var newPath = path
                            newPath.append("r")
                            checkPossibleToPush(levelTable: newLevelTable, path: newPath)
                        } else if keyCellsInfo.boxRow == keyCellsInfo.playerRow && keyCellsInfo.boxColumn == keyCellsInfo.playerColumn + 1 && canToPush(levelTable: levelTable, keyCellsInfo: keyCellsInfo) {
                            let newLevelTable = push(levelTable: levelTable)
                            var newPath = path
                            newPath.append("R")
                            checkPossibleToPush(levelTable: newLevelTable, path: newPath)
                        }
                    }
                case 2:
                    // Проверяем возможность пойти или толкнуть вниз
                    if keyCellsInfo.playerRow < levelTable.count - 1 {
                        let nextCell = levelTable[keyCellsInfo.playerRow + 1][keyCellsInfo.playerColumn]
                        if nextCell.type == .empty || nextCell.type == .goal {
                            let newLevelTable = move(levelTable: levelTable, direction: .topToBottom)
                            var newPath = path
                            newPath.append("d")
                            checkPossibleToPush(levelTable: newLevelTable, path: newPath)
                        } else if keyCellsInfo.boxRow == keyCellsInfo.playerRow + 1 && keyCellsInfo.boxColumn == keyCellsInfo.playerColumn && canToPush(levelTable: levelTable, keyCellsInfo: keyCellsInfo) {
                            let newLevelTable = push(levelTable: levelTable)
                            var newPath = path
                            newPath.append("D")
                            checkPossibleToPush(levelTable: newLevelTable, path: newPath)
                        }
                    }
                default:
                    if keyCellsInfo.playerColumn > 0 {
                        let nextCell = levelTable[keyCellsInfo.playerRow][keyCellsInfo.playerColumn - 1]
                        if nextCell.type == .empty || nextCell.type == .goal {
                            let newLevelTable = move(levelTable: levelTable, direction: .rightToLeft)
                            var newPath = path
                            newPath.append("l")
                            checkPossibleToPush(levelTable: newLevelTable, path: newPath)
                        } else if keyCellsInfo.boxRow == keyCellsInfo.playerRow && keyCellsInfo.boxColumn == keyCellsInfo.playerColumn - 1 && canToPush(levelTable: levelTable, keyCellsInfo: keyCellsInfo) {
                            let newLevelTable = push(levelTable: levelTable)
                            var newPath = path
                            newPath.append("L")
                            checkPossibleToPush(levelTable: newLevelTable, path: newPath)
                        }
                    }
                }
            }
        }
        
        let initTable = copyTable(table: table)
        for (i, row) in initTable.enumerated() {
            for (j, cell) in row.enumerated() {
                cell.boxSelected = i == initBoxRow && j == initBoxColumn
            }
        }
        
        checkPossibleToPush(levelTable: initTable, path: "")

        let cell = self.table[self.initBoxRow][self.initBoxColumn]
        var processingCellsArray: Array<(Int, Int)> = []
        for processingCell in self.processingCells {
            processingCellsArray.append(processingCell)
        }
        cell.processingCells = processingCellsArray

        let dataDict:[String: (Int, Int)] = ["coordinate": (self.initBoxRow, self.initBoxColumn)]
        NotificationCenter.default.post(name: Notification.Name("processingDone"), object: nil, userInfo: dataDict)
        
/*        DispatchQueue.main.async {
            print("Processing box possible pushes done: \(cell.processingCells!)")
        } */
    }
    
    typealias keyCellsInfo = (playerRow: Int, playerColumn: Int, playerCell: SPCell?, boxRow: Int, boxColumn: Int, boxCell: SPCell?)
    
    func getKeyCellsInfo(table: Array<Array<SPCell>>) -> (keyCellsInfo) {
        var playerRow = -1
        var playerColumn = -1
        var playerCell: SPCell?
        var boxRow = -1
        var boxColumn = -1
        var boxCell: SPCell?
        
        for (i, row) in table.enumerated() {
            for (j, cell) in row.enumerated() {
                if cell.type == .player || cell.type == .playerOnAGoal {
                    playerRow = i
                    playerColumn = j
                    playerCell = cell
                } else if cell.boxSelected {
                    boxRow = i
                    boxColumn = j
                    boxCell = cell
                }
            }
        }
        return(playerRow, playerColumn, playerCell, boxRow, boxColumn, boxCell)
    }
    
    func copyTable(table: Array<Array<SPCell>>) -> Array<Array<SPCell>> {
        var newTable = Array<Array<SPCell>>()
        for (_, row) in table.enumerated() {
            var newRow = Array<SPCell>()
            for (_, cell) in row.enumerated() {
                newRow.append(cell.copy())
            }
            newTable.append(newRow)
        }
        return newTable
    }
}
