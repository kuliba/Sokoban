//
//  Level.swift
//  Sokoban
//
//  Created by Valentin Ozerov on 06.05.2025.
//

@MainActor
struct Level: Sendable {
    let id: String
    let table: Array<Array<Cell>>
}

//struct Level: Sendable {
//    typealias Table = Array<Array<Cell>>
//    
//    let id: String
//    
//    private let isolatedMembers: IsolatedMembers
//    
//    var table: Table {
//        get async {
//            await isolatedMembers.getTable()
//        }
//    }
//
//    private actor IsolatedMembers {
//        private var table: Table = []
//        
//        func getTable() -> Table { table }
//        func setTable(_ table: Table) {
//            self.table = table
//        }
//    }
//    
//    init(id: String) {
//        self.id = id
//        self.isolatedMembers = IsolatedMembers()
//    }
//}

/*
struct Level: Sendable {
    var table = Array<Array<Cell>>()
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
    var selectedBox: Cell? {
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
*/
