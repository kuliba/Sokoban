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

class SPCell: NSObject {
    var type: SPCellType = .undefined
    var wallFigure: SPWallFigure = .undefined
    var imageName: String {
        get {
            switch self.wallFigure {
                case .topRight:
                    return "topRight.png"
                case .topRigthLeft:
                    return "topRightLeft.png"
                case .topLeft:
                    return "topLeft.png"
                case .topRightBottom:
                    return "topRightBottom.png"
                case .topRightBottomLeft:
                    return "topRightBottomLeft"
                case .topBottomLeft:
                    return "topBottomLeft"
                case .rightBottom:
                    return "rightBottom"
                case .rightBottomLeft:
                    return "rightBottomLeft"
                case .bottomLeft:
                    return "bottomLeft.png"
                case .center:
                    return "center.png"
                case .right:
                    return "right.png"
                case .rightLeft:
                    return "rightLeft.png"
                case .left:
                    return "left.png"
                case .top:
                    return "top.png"
                case .topBottom:
                    return "topBottom.png"
                case .bottom:
                    return "bottom.png"
                default:
                    return "space.png"
            }
        }
    }
}
