//
//  GKHOperatorsModel.swift
//  ForaBank
//
//  Created by Константин Савялов on 15.08.2021.
//

import Foundation
import RealmSwift

// MARK: - GKHOperatorsModel
class GKHOperatorsModel: Object {
    
    @objc dynamic var puref: String?
    @objc dynamic var isGroup = false
    @objc dynamic var name: String?
    @objc dynamic var region: String?
    @objc dynamic var parentCode: String?
    @objc dynamic var serial: String?
    
    var logotypeList  = List<LogotypeData>()
    let synonymList   = List<String>()
    var parameterList = List<Parameters>()
    
}

extension GKHOperatorsModel {
        
    static func childOperators(with data: [Operator], operatorCodes: [String], parameterTypes: [String]) -> [GKHOperatorsModel] {
        
        var operators = [GKHOperatorsModel]()
        
        for group in data {
            
            guard let code = group.code, code.contained(in: operatorCodes), let grouopOperatorsData = group.operators else {
                continue
            }
            
            let groupOperators = grouopOperatorsData.compactMap{ GKHOperatorsModel(with: $0, and: parameterTypes) }
            operators.append(contentsOf: groupOperators)
        }
        
        return operators
    }
    
    convenience init(with data: Operator, and parameterTypes: [String]?) {
        
        self.init()
        puref   = data.code
        isGroup = data.isGroup ?? false
        name    = data.name
        region  = data.region
        parentCode = data.parentCode
        
        if let logotypeListData = data.logotypeList {
            
            logotypeList.append(objectsIn: logotypeListData.map{ LogotypeData(with: $0, and: data.code)} )
        }
        
        if let synonymListData = data.synonymList {
            
            synonymList.append(objectsIn: synonymListData)
        }
        
        if let parameterListData = data.parameterList {
            
            let parametersObjects = parameterListData.compactMap{ Parameters(with: $0, for: parameterTypes) }
            let sortedParametersObjects = parametersObjects.sorted(by: { $0.order < $1.order })
            
            parameterList.append(objectsIn: sortedParametersObjects )
        }
        
        //FIXME: child operators from Operator model not implemented
    }
    
    convenience init(with data: OperatorGroupData.OperatorData, and parameterTypes: [String]?) {
        
        self.init()
        puref   = data.code
        isGroup = data.isGroup
        name    = data.name
        region  = data.region
        parentCode = data.parentCode
        
        logotypeList.append(objectsIn: data.logotypeList.map{ LogotypeData(with: $0.logotypeList(), and: data.code)} )
        
        synonymList.append(objectsIn: data.synonymList)
            
        let parametersObjects = data.parameterList.compactMap{ Parameters(with: $0.returnParamertList(), for: parameterTypes) }
        let sortedParametersObjects = parametersObjects.sorted(by: { $0.order < $1.order })
            
        parameterList.append(objectsIn: sortedParametersObjects )
    }
}

