//
//  GKHInputModel.swift
//  ForaBank
//
//  Created by Константин Савялов on 21.11.2021.
//

import Foundation

/// Модель для отображения данных в таблице операторов ЖКХ
struct GKHInputModel {
    
    var inputData: GKHOperatorsModel?
    var qrData = [[String: String]]()
    
    mutating func data() -> [[String: String]] {
        var tempDic = [String: String]()
        var tempArray = [[String: String]]()
        inputData?.parameterList.forEach({ param in
            tempDic.updateValue(param.title ?? "", forKey: "title")
            tempDic.updateValue(param.subTitle ?? "", forKey: "subTitle")
            tempDic.updateValue(param.id ?? "", forKey: "id")
            tempDic.updateValue(param.viewType ?? "", forKey: "viewType")
            tempArray.append(tempDic)
        })
        
        return tempArray
    }
    
    mutating func qData() -> [[String: String]] {
        var tempArray = [[String: String]]()
        var tempDic = [String: String]()
        qrData.forEach{ param in
            tempDic.updateValue(param["Лицевой счет"] ?? "", forKey: "title")
            tempDic.updateValue(param["id"] ?? "", forKey: "id")
            tempArray.append(tempDic)
        }
        return tempArray
    }
    
    mutating func stepData() -> [[String: String]] {
        var tempArray = [[String: String]]()
        var tempDic = [String: String]()
        qrData.forEach{ param in
            tempDic.updateValue(param["Лицевой счет"] ?? "", forKey: "title")
            tempDic.updateValue(param["id"] ?? "", forKey: "id")
            tempArray.append(tempDic)
        }
        return tempArray
    }
    
    init?(_ data: [String: String]) {
        self.qrData.append(data)
    }
    // GKHOperatorsModel
    init?(_ data: GKHOperatorsModel) {
        self.inputData = data
    }
}
