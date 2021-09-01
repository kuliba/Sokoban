//
//  GKHHistoryCaruselModel.swift
//  ForaBank
//
//  Created by Константин Савялов on 31.08.2021.
//

import Foundation

import UIKit

struct GKHHistoryCaruselModel {
    var mainImage: UIImage
    var sushiName: String
    var smallDescription: String
    var cost: Int
    
    static func fetchModel() -> [GKHHistoryCaruselModel] {
        let firstItem = GKHHistoryCaruselModel(mainImage: UIImage(named: "sushi1")!,
                               sushiName: "Jengibre",
                               smallDescription: "Original Japanese",
                               cost: 8)
        let secondItem = GKHHistoryCaruselModel(mainImage: UIImage(named: "sushi2")!,
                                    sushiName: "Caviar",
                                    smallDescription: "Original Japanese",
                                    cost: 10)
        let thirdItem = GKHHistoryCaruselModel(mainImage: UIImage(named: "sushi3")!,
                                   sushiName: "Camaron",
                                   smallDescription: "Original Japanese",
                                   cost: 7)
        
        let fouthItem = GKHHistoryCaruselModel(mainImage: UIImage(named: "sushi4")!,
                                   sushiName: "Salmon",
                                   smallDescription: "Original Japanese",
                                   cost: 12)
        
        let five = GKHHistoryCaruselModel(mainImage: UIImage(named: "sushi1")!,
                                   sushiName: "Jengibre",
                                   smallDescription: "Original Japanese",
                                   cost: 8)
        let six = GKHHistoryCaruselModel(mainImage: UIImage(named: "sushi2")!,
                                    sushiName: "Caviar",
                                    smallDescription: "Original Japanese",
                                    cost: 10)
        let seven = GKHHistoryCaruselModel(mainImage: UIImage(named: "sushi3")!,
                                   sushiName: "Camaron",
                                   smallDescription: "Original Japanese",
                                   cost: 7)
        
        let eight = GKHHistoryCaruselModel(mainImage: UIImage(named: "sushi4")!,
                                   sushiName: "Salmon",
                                   smallDescription: "Original Japanese",
                                   cost: 12)
        
        
        return [firstItem, secondItem, thirdItem, fouthItem, five, six, seven, eight]
    }
}

struct GKHConstants {
    static let leftDistanceToView: CGFloat = 40
    static let rightDistanceToView: CGFloat = 40
    static let galleryMinimumLineSpacing: CGFloat = 10
    static let galleryItemWidth = (UIScreen.main.bounds.width - GKHConstants.leftDistanceToView - GKHConstants.rightDistanceToView - (GKHConstants.galleryMinimumLineSpacing / 2)) / 2
}
