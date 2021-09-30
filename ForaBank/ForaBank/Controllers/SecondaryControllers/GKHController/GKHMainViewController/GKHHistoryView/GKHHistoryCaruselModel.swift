//
//  GKHHistoryCaruselModel.swift
//  ForaBank
//
//  Created by Константин Савялов on 31.08.2021.
//

import Foundation

import UIKit
import RealmSwift

struct GKHHistoryCaruselModel {
    var mainImage: UIImage
    var banksName: String
    var inn: String
    
    static func fetchModel() -> [GKHHistoryCaruselModel] {
        
        var tempArray = [GKHHistoryCaruselModel]()
        
        var inn = ""
        var name = ""
        var image: UIImage!
        
        let realm = try? Realm()
        var payModelArray: Results<GKHHistoryModel>?
        var operatorsArray: Results<GKHOperatorsModel>?
        payModelArray = realm?.objects(GKHHistoryModel.self)
        operatorsArray = realm?.objects(GKHOperatorsModel.self)
        payModelArray?.forEach({ operation in
            
            let puref = operation.puref
            operatorsArray?.forEach({ op in
                if puref == op.puref {
                    name = op.name?.capitalizingFirstLetter() ?? ""
                    let tempImage = op.logotypeList.first?.content ?? ""
                    inn = String(operation.amount) + " ₽"
                    if tempImage != "" {
                        let dataDecoded : Data = Data(base64Encoded: tempImage, options: .ignoreUnknownCharacters)!
                        let decodedimage = UIImage(data: dataDecoded)
                        image = decodedimage
                    } else {
//                        image = UIImage(named: "GKH")
                    }
                    
                }
            })
            if image != nil {
            let temp = GKHHistoryCaruselModel(mainImage: image, banksName: name, inn: inn)
            tempArray.append(temp)
            }
        })
        
        return tempArray
    }
}

struct GKHConstants {
    static let leftDistanceToView: CGFloat = 20
    static let rightDistanceToView: CGFloat = 20
    static let galleryMinimumLineSpacing: CGFloat = 10
    static let galleryItemWidth = (UIScreen.main.bounds.width - GKHConstants.leftDistanceToView - GKHConstants.rightDistanceToView - (GKHConstants.galleryMinimumLineSpacing / 2)) / 2
}
