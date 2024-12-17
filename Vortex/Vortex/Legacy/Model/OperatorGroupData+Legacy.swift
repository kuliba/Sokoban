//
//  OperatorGroupData+Legacy.swift
//  ForaBank
//
//  Created by Константин Савялов on 20.06.2022.
//

import Foundation

extension OperatorGroupData {
    
    func returnOperators() -> Operator {
        return Operator(city: city, code: code, isGroup: isGroup, logotypeList: logotypeList.map{ $0.logotypeList()}, name: name, operators: operators.map { $0.returnOperatorData() }, region: region, synonymList: synonymList, parameterList: nil, parentCode: nil)
    }
}

extension OperatorGroupData.OperatorData {
    
    func returnOperatorData() -> Operator {
        return Operator(city: city, code: code, isGroup: isGroup, logotypeList: logotypeList.map{ $0.logotypeList()}, name: name, operators: nil, region: region, synonymList: synonymList, parameterList: parameterList.map { $0.returnParamertList() }, parentCode: parentCode)
    }
    
}

extension OperatorGroupData.LogotypeData {
    
    func logotypeList() -> LogotypeList {
        return LogotypeList(content: content, contentType: contentType, name: name, svgImage: svgImage?.description)
    }
}

extension ParameterData {
    
    func returnParamertList() -> ParameterList {
        return ParameterList(content: content, dataType: dataType, id: id, svgImage: svgImage?.description, isRequired: isRequired, mask: mask, maxLength: maxLength, minLength: minLength, order: order, rawLength: rawLength, readOnly: readOnly, regExp: regExp, subTitle: subTitle, title: title, type: type, viewType: viewType.rawValue)
    }
    
}
