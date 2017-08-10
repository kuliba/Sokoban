//
//  SPRoutines.swift
//  Sokoban
//
//  Created by Valentin Ozerov on 28.06.17.
//  Copyright © 2017 Valentin Ozerov. All rights reserved.
//

import Foundation

func levelToString(table: Array<Array<SPCell>>) -> String {
    var result = ""
    for (i, row) in table.enumerated() {
        for (_, cell) in row.enumerated() {
            switch cell.type {
            case .empty:
                result.append(" ")
            case .wall:
                result.append("#")
            case .player:
                result.append("@")
            case .box:
                result.append("$")
            case .goal:
                result.append(".")
            case .playerOnAGoal:
                result.append("+")
            case .boxOnAGoal:
                result.append("*")
            default:
                break
            }
        }
        if i < table.count - 1 {
            result.append("\n")
        }
    }
    return result
}

func checkIsFinishLevel(levelTable: Array<Array<SPCell>>) -> Bool {
    // Условия проверки завершенности уровня:
    // 1. Отсутствие ячеек типа goal
    // 2. Отсутствие ячеек типа box
    // 3. Отсутствие ячеек типа playerOnAGoal
    // 4. Наличие хотя бы одной ячейки типа boxOnAGoal
    
    var boxOnGoalExists = false
    for (_, row) in levelTable.enumerated() {
        for (_, cell) in row.enumerated() {
            if cell.type == .goal || cell.type == .box || cell.type == .playerOnAGoal { return false }
            if cell.type == .boxOnAGoal { boxOnGoalExists = true }
        }
    }
    return boxOnGoalExists
}

func deadlockExists(levelTable: Array<Array<SPCell>>) -> Bool {

    let deadlocks: Array<Array<Array<SPCellType>>> = [
        [[.undefined, .wall], [.wall, .box]],
        [[.wall, .box], [.wall, .box]],
        [[.box, .box], [.wall, .box]],
        [[.box, .box], [.box, .box]],
        [[.wall, .wall, .undefined], [.wall, .empty, .wall], [.undefined, .box, .wall]],
        [[.wall, .wall, .undefined], [.wall, .empty, .wall], [.undefined, .box, .box]],
        [[.wall, .wall, .undefined], [.wall, .empty, .box], [.undefined, .box, .wall]],
        [[.wall, .wall, .undefined], [.wall, .empty, .box], [.undefined, .box, .box]],
        [[.wall, .box, .undefined], [.wall, .empty, .box], [.undefined, .box, .box]],
        [[.box, .wall, .undefined], [.wall, .empty, .box], [.undefined, .box, .box]],
        [[.box, .box, .undefined], [.wall, .empty, .box], [.undefined, .box, .box]],
        [[.wall, .box, .undefined], [.box, .empty, .box], [.undefined, .box, .box]],
        [[.box, .box, .undefined], [.box, .empty, .box], [.undefined, .box, .box]],
        [[.undefined, .wall, .undefined], [.wall, .empty, .wall], [.wall, .box, .wall]],
        [[.undefined, .wall, .undefined], [.wall, .empty, .wall], [.box, .box, .wall]],
        [[.undefined, .wall, .undefined], [.wall, .empty, .box], [.wall, .box, .wall]],
        [[.undefined, .wall, .undefined], [.wall, .empty, .box], [.wall, .box, .box]],
        [[.undefined, .wall, .undefined], [.wall, .empty, .wall], [.box, .box, .box]],
        [[.undefined, .wall, .undefined], [.wall, .empty, .box], [.box, .box, .box]],
        [[.undefined, .box, .wall], [.wall, .box, .undefined]],
        [[.undefined, .wall, .undefined], [.box, .empty, .box], [.box, .box, .box]]]

    func rotateDeadlock(deadLock: Array<Array<SPCellType>>) -> Array<Array<SPCellType>> {
        var result = Array<Array<SPCellType>>()
        var newRow = Array<SPCellType>()
        
        for i in (0...deadLock.first!.count - 1).reversed() {
            newRow.removeAll()
            for j in (0...deadLock.count - 1) {
                newRow.append(deadLock[j][i])
            }
            result.append(newRow)
        }
        return result
    }
    
    func deadLockExists(levelTable: Array<Array<SPCell>>, deadlock: Array<Array<SPCellType>>) -> Bool {
        
        func indexOfDeadlockRow(levelRow: Array<SPCell>, deadlockRow: Array<SPCellType>) -> Int {
    
            func checkEqual(levelRow: Array<SPCell>, deadlockRow: Array<SPCellType>) -> Bool {
                guard levelRow.count == deadlockRow.count else { return false }
                for (i, deadLockType) in deadlockRow.enumerated() {
                    if deadLockType == .undefined { continue }
                    if deadLockType != levelRow[i].type { return false }
                }
                return true
                }
        
            let max = levelRow.count - deadlockRow.count
            for i in 0...max {
                if checkEqual(levelRow: Array(levelRow[i..<(i + deadlockRow.count)]), deadlockRow: deadlockRow) {
                    return i
                }
            }
            return -1
        }
        
        let maxC = levelTable.count - deadlock.count
        for i in 0...maxC {
            let maxR = levelTable[i].count - (deadlock.first?.count)!
            for j in 0...maxR {
                let cutLevelRow = Array(levelTable[i][j..<j + (deadlock.first?.count)!])
                let firstIndex = indexOfDeadlockRow(levelRow: cutLevelRow, deadlockRow: deadlock.first!)
                if firstIndex >= 0 {
                    var searchFound = true
                    for k in 1...deadlock.count - 1 {
                        let deadlockRow = deadlock[k]
                        let levelRow = Array(levelTable[i + k][j..<j + deadlockRow.count])
                        let nextIndex = indexOfDeadlockRow(levelRow: levelRow, deadlockRow: deadlockRow)
                        if nextIndex != 0 { searchFound = false }
                    }
                    if searchFound { return true }
                }
            }
        }
        return false
    }
 
    for deadlock in deadlocks {
        var rotatedDeadlock = deadlock
        for _ in 0...4 {
            rotatedDeadlock = rotateDeadlock(deadLock: rotatedDeadlock)
            if deadLockExists(levelTable: levelTable, deadlock: rotatedDeadlock) { return true }
        }
    }
    return false
}
