//
//  PaymentsDataModel.swift
//  ForaBank
//
//  Created by Max Gribov on 07.02.2022.
//

import Foundation

enum Payments {

    enum Category: String {
        
        case taxes = "iFora||1331001"
        
        var services: [Service] {
            
            switch self {
            case .taxes: return [.fms, .fns, .fssp]
            }
        }
        
        var name: String {
            
            switch self {
            case .taxes: return "Налоги и услуги"
            }
        }
    }
    
    enum Service: String {
        
        case fms
        case fns
        case fssp
    }
    
    enum Operator : String {
        
        case fssp       = "iFora||5429"
        case fms        = "iFora||6887"
        case fns        = "iFora||6273"
        case fnsUin     = "iFora||7069"
    }
    
    struct Parameter: Equatable {
        
        typealias ID = String
        typealias Value = String?
        
        let id: ID
        let value: Value
    }
    
    struct Operation {
        
        let service: Service
        let parameters: [ParameterRepresentable]
        let history: [[Parameter]]
        
        enum Kind {
            
            case service(title: String, icon: ImageData)
            case template(template: PaymentTemplateData.ID, name: String)
        }
    }
    
    enum Error: Swift.Error {
        
        case unsupported
        case unableCreateOperationForService(Service)
        case unexpectedOperatorValue
        case missingOperatorParameter
    }
}

protocol ParameterRepresentable {

    var parameter: Payments.Parameter { get }
    var editable: Bool { get }
    var collapsable: Bool { get }
    
    func updated(value: String?) -> ParameterRepresentable
    func updated(editable: Bool) -> ParameterRepresentable
    func updated(collapsable: Bool) -> ParameterRepresentable
}
