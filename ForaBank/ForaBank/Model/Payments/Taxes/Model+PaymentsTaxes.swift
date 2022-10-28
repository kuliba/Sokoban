//
//  Model+PaymentsTaxes.swift
//  ForaBank
//
//  Created by Max Gribov on 21.03.2022.
//

import Foundation

extension Model {
    
    func paymentsParameterRepresentableTaxes(service: Payments.Service, parameterData: ParameterData) throws -> PaymentsParameterRepresentable? {
        
        switch parameterData.id {
        case "a3_categorySelect_3_1":
            guard let options = parameterData.options else {
                throw Payments.Error.missingOptions(parameterData)
            }
            return Payments.ParameterSelectSimple(
                .init(id: parameterData.id, value: parameterData.value),
                icon: parameterData.iconData ?? .parameterSample,
                title: parameterData.title,
                selectionTitle: "Выберете категорию",
                options: options)
            
        case "a3_fio_1_2", "a3_fio_4_1":
            return Payments.ParameterName(id: parameterData.id, value: parameterData.value, title: parameterData.title)

        case "a3_address_2_2", "a3_address_10_1", "a3_address_4_2", "a3_address_4_3":
            return Payments.ParameterInfo(
                .init(id: parameterData.id, value: parameterData.value),
                icon: parameterData.iconData ?? .parameterLocation,
                title: "Адрес проживания")
            
        case "a3_docType_3_2", "a3_docName_1_1":
            guard let options = parameterData.options else {
                throw Payments.Error.missingOptions(parameterData)
            }
            return Payments.ParameterSelectSimple(
                Payments.Parameter(id: parameterData.id, value: parameterData.value),
                icon: parameterData.iconData ?? .parameterSample,
                title: parameterData.title,
                selectionTitle: "Выберете тип документа",
                options: options)
            
        default:
            return nil
        }
    }
}
