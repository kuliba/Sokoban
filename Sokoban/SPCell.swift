//
//  SPCell.swift
//  Sokoban
//
//  Created by Valentin Ozerov on 15.06.17.
//  Copyright © 2017 Valentin Ozerov. All rights reserved.
//

import UIKit

enum SPCellType {
    case undefined
    case empty          // " " - space is an empty square
    case wall           // "#" - is a wall
    case player         // "@" - is the player
    case box            // "$" - is a box
    case goal           // "." - is a goal
    case playerOnAGoal  // "+" is the player on a goal
    case boxOnAGoal     // "*" is a box on a goal
}

enum SPWallFigure {
    case undefined
    case topRight
    case topRigthLeft
    case topLeft
    case topRightBottom
    case topRightBottomLeft
    case topBottomLeft
    case rightBottom
    case rightBottomLeft
    case bottomLeft
    case center
    case right
    case rightLeft
    case left
    case top
    case topBottom
    case bottom
}

class SPCell {
    var type: SPCellType = .undefined
    var wallFigure: SPWallFigure = .undefined
    var dynamicElement: UIImageView?
    var boxSelected = false
    var processingCells: Array<(Int, Int)>? // Массив с индексами ячеек, куда возможно передвинуть ящик или пойти игроком
    var imageName: String {
        get {
            if type == .goal {
                return "goal"
            } else if type == .box {
                return "box"
            } else if type == .player {
                return "player"
            } else if type == .boxOnAGoal {
                return "boxOnAGoal"
            } else if type == .playerOnAGoal {
                return "player"
            }
            
            switch self.wallFigure {
                case .topRight:
                    return "wallTopRight"
                case .topRigthLeft:
                    return "wallTopRightLeft"
                case .topLeft:
                    return "wallTopLeft"
                case .topRightBottom:
                    return "wallTopRightBottom"
                case .topRightBottomLeft:
                    return "wallTopRightBottomLeft"
                case .topBottomLeft:
                    return "wallTopBottomLeft"
                case .rightBottom:
                    return "wallRightBottom"
                case .rightBottomLeft:
                    return "wallRightBottomLeft"
                case .bottomLeft:
                    return "wallBottomLeft"
                case .center:
                    return "wallCenter"
                case .right:
                    return "wallRight"
                case .rightLeft:
                    return "wallRightLeft"
                case .left:
                    return "wallLeft"
                case .top:
                    return "wallTop"
                case .topBottom:
                    return "wallTopBottom"
                case .bottom:
                    return "wallBottom"
                default:
                    return "space"
            }
        }
    }
    
    func copy() -> SPCell {
        let result = SPCell()
        
        result.type = self.type
        result.wallFigure = self.wallFigure
        result.dynamicElement = self.dynamicElement
        result.boxSelected = self.boxSelected
        result.processingCells = self.processingCells
        
        return result
    }
}
