//
//  SPMoveProcessingOperation.swift
//  Sokoban
//
//  Created by Valentin Ozerov on 03.08.17.
//  Copyright © 2017 Valentin Ozerov. All rights reserved.
//

import UIKit

class SPMoveProcessingOperation: Operation {

    var table: Array<Array<SPCell>> = []
    var playerRow = -1
    var playerColumn = -1
    lazy var processingCells: Array<(Int, Int)> = []

    init(table: Array<Array<SPCell>>, playerRow: Int, playerColumn: Int) {
        self.table = table
        self.playerRow = playerRow
        self.playerColumn = playerColumn
    }
    
    override func main() {
        let playerCell = table[playerRow][playerColumn]
        
        func checkCellForMove(row: Int, column: Int, first: Bool) {
            if self.isCancelled { return }
            
            if !first {
                processingCells.append((row, column))
            }
            
            var nextCell = SPCell()
         
            // Проверяем верхнюю ячейку на возможность перехода
            if row > 0 {
                nextCell = table[row - 1][column]
                if nextCell.type != .wall && nextCell.type != .box && nextCell.type != .player && !possibleMoveExists(row: row - 1, column: column) {
                    checkCellForMove(row: row - 1, column: column, first: false)
                }
            }
         
            // Проверяем правую ячейку
            if column < table[row].count - 1 {
                nextCell = table[row][column + 1]
                if nextCell.type != .wall && nextCell.type != .box && nextCell.type != .player && !possibleMoveExists(row: row, column: column + 1) {
                    checkCellForMove(row: row, column: column + 1, first: false)
                }
            }
         
            // Проверяем нижнюю ячейку
            if row < table.count - 1 {
                nextCell = table[row + 1][column]
                if nextCell.type != .wall && nextCell.type != .box && nextCell.type != .player && !possibleMoveExists(row: row + 1, column: column) {
                    checkCellForMove(row: row + 1, column: column, first: false)
                }
            }
         
            // Проверяем левую ячейку
            if column > 0 {
                nextCell = table[row][column - 1]
                if nextCell.type != .wall && nextCell.type != .box && nextCell.type != .player && !possibleMoveExists(row: row, column: column - 1) {
                    checkCellForMove(row: row, column: column - 1, first: false)
                }
            }
        }

        func possibleMoveExists(row: Int, column: Int) -> Bool {
            for item in processingCells {
                if item.0 == row && item.1 == column {
                    return true
                }
            }
            return false
        }
        
        checkCellForMove(row: playerRow, column: playerColumn, first: true)
        
        var processingCellsArray: Array<(Int, Int)> = []
        for processingCell in self.processingCells {
            processingCellsArray.append(processingCell)
        }
        playerCell.processingCells = processingCellsArray

        let dataDict:[String: (Int, Int)] = ["coordinate": (self.playerRow, self.playerColumn)]
        NotificationCenter.default.post(name: Notification.Name("processingDone"), object: nil, userInfo: dataDict)
        
/*        DispatchQueue.main.async {
            print("Processing player possible moves done!")
            print(playerCell.processingCells!)
        } */
    }
}
