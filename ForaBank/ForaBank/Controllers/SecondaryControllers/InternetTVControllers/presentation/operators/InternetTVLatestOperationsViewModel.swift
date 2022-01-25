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
        let realm = try? Realm()
        let operatorsArray = realm?.objects(GKHOperatorsModel.self)
        if InternetTVMainViewModel.filter == GlobalModule.UTILITIES_CODE {
            let payModelArray = realm?.objects(GKHHistoryModel.self)
            payModelArray?.forEach({ lastOperation in
                let found = operatorsArray?.filter {op in
                    op.puref == lastOperation.puref
                }
                if let arr = found, arr.count > 0, let op = arr.first {
                    var additional = [AdditionalListModel]()
                    additional.append(contentsOf: lastOperation.additionalList)
                    let ob = fillLatestDO(name: op.name?.capitalizingFirstLetter().uppercased() ?? "", amountDouble: lastOperation.amount, svgImageUnw: op.logotypeList.first?.svgImage, additionalList: additional, op: op)
                    resultArr.append(ob)
                }
            })
        } else if InternetTVMainViewModel.filter == GlobalModule.INTERNET_TV_CODE {
            let payModelArray = realm?.objects(InternetTVLatestOperationsModel.self)
            payModelArray?.forEach({ lastOperation in
                let found = operatorsArray?.filter {op in
                    op.puref == lastOperation.puref
                }
                if let arr = found, arr.count > 0, let op = arr.first {
                    var additional = [AdditionalListModel]()
                    additional.append(contentsOf: lastOperation.additionalList)
                    let ob = fillLatestDO(name: op.name?.capitalizingFirstLetter().uppercased() ?? "", amountDouble: lastOperation.amount, svgImageUnw: op.logotypeList.first?.svgImage, additionalList: additional, op: op)
                    resultArr.append(ob)
                }
            })
        } else if InternetTVMainViewModel.filter == GlobalModule.PAYMENT_TRANSPORT {
            let payModelArray = realm?.objects(InternetTVLatestOperationsTransport.self)
            payModelArray?.forEach({ lastOperation in
                let found = operatorsArray?.filter {op in
                    op.puref == lastOperation.puref
                }
                if let arr = found, arr.count > 0, let op = arr.first {
                    var additional = [AdditionalListModel]()
                    additional.append(contentsOf: lastOperation.additionalList)
                    let ob = fillLatestDO(name: op.name?.capitalizingFirstLetter().uppercased() ?? "", amountDouble: lastOperation.amount, svgImageUnw: op.logotypeList.first?.svgImage, additionalList: additional, op: op)
                    resultArr.append(ob)
                }
            })
        }
        return resultArr
    }

    func fillLatestDO(name: String, amountDouble: Double, svgImageUnw: String?, additionalList: [AdditionalListModel], op:GKHOperatorsModel) -> InternetLatestOpsDO {
        var amount = ""
        var image: UIImage!
        
        if amountDouble.truncatingRemainder(dividingBy: 1.0) == 0 {
            amount = String(format: "%0.0f₽", amountDouble)
        } else {
            amount = String(format: "%.02f₽", amountDouble)
        }
        if let svgImage = svgImageUnw, svgImage != "" {
            image = svgImage.convertSVGStringToImage()
        } else {
            image = UIImage(named: "GKH")
        }
        let ob = InternetLatestOpsDO(mainImage: image, name: name, amount: amount, op: op, additionalList: additionalList)
        return ob
    }
}
