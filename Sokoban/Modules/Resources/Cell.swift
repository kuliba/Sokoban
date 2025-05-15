//
//  Cell.swift
//  Sokoban
//
//  Created by Valentin Ozerov on 14.05.2025.
//

import UIKit

enum CellType {
    case undefined
    case empty          // " " - space is an empty square
    case wall           // "#" - is a wall
    case player         // "@" - is the player
    case box            // "$" - is a box
    case goal           // "." - is a goal
    case playerOnAGoal  // "+" is the player on a goal
    case boxOnAGoal     // "*" is a box on a goal
}

enum WallFigure {
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

final class Cell {
    var type: CellType = .undefined
    var wallFigure: WallFigure = .undefined
    var dynamicElement: UIImageView?
    var boxSelected = false
    /// An array containing the indices of cells that are valid destinations for either moving the box or for player movement
    var processingCells: Array<(Int, Int)>?
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
}
