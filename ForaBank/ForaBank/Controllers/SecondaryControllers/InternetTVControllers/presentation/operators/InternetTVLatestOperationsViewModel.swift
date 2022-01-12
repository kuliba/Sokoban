//
//  InternetTVLatestOperationsViewModel.swift
//  ForaBank
//
//  Created by Роман Воробьев on 04.12.2021.
//

import Foundation
import UIKit
import RealmSwift

class InternetTVLatestOperationsViewModel {

    var controller :InternetTVLatestOperationsView? = nil

    init () {}

    func getData() -> [InternetLatestOpsDO] {
        var resultArr = [InternetLatestOpsDO]()
        var amount = ""
        var name = ""
        var image: UIImage!
        let realm = try? Realm()
        let operatorsArray = realm?.objects(GKHOperatorsModel.self)
        if InternetTVMainViewModel.filter == GlobalModule.UTILITIES_CODE {
            let payModelArray = realm?.objects(GKHHistoryModel.self)
            payModelArray?.forEach({ lastOperation in
                let found = operatorsArray?.filter {op in
                    op.puref == lastOperation.puref
                }
                if let arr = found, arr.count > 0, let op = arr.first {
                    name = op.name?.capitalizingFirstLetter() ?? ""
                    amount = String(lastOperation.amount) + " ₽"
                    if let svgImage = op.logotypeList.first?.svgImage, svgImage != "" {
                        image = svgImage.convertSVGStringToImage()
                    } else {
                        image = UIImage(named: "GKH")
                    }
                    var additionalList = [AdditionalListModel]()
                    additionalList.append(contentsOf: lastOperation.additionalList)
                    let ob = InternetLatestOpsDO(mainImage: image, name: name, amount: amount, op: op, additionalList: additionalList)
                    resultArr.append(ob)
                }
            })
        }
    
        if InternetTVMainViewModel.filter == GlobalModule.INTERNET_TV_CODE {
            let payModelArray = realm?.objects(InternetTVLatestOperationsModel.self)
            payModelArray?.forEach({ lastOperation in
                let found = operatorsArray?.filter {op in
                    op.puref == lastOperation.puref
                }
                if let arr = found, arr.count > 0, let op = arr.first {
                    name = op.name?.capitalizingFirstLetter() ?? ""
                    amount = String(lastOperation.amount) + " ₽"
                    if let svgImage = op.logotypeList.first?.svgImage, svgImage != "" {
                        image = svgImage.convertSVGStringToImage()
                    } else {
                        image = UIImage(named: "GKH")
                    }
                    var additionalList = [AdditionalListModel]()
                    additionalList.append(contentsOf: lastOperation.additionalList)
                    let ob = InternetLatestOpsDO(mainImage: image, name: name, amount: amount, op: op, additionalList: additionalList)
                    resultArr.append(ob)
                }
            })
        }
        return resultArr
    }
}
