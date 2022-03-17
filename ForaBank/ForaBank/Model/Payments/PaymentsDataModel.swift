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
            case .taxes: return [.fns, .fms, .fssp]
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
        
        case unableLoadFMSCategoryOptions
        case unableCreateOperationForService(Service)
        case unexpectedOperatorValue
        case missingOperatorParameter
        case missingParameter
        case failedAnywayTransferWithEmptyTransferDataResponse
        case failedAnywayTransfer(status: ServerStatusCode, message: String?)
        case unsupported
    }
}

protocol ParameterRepresentable {

    var parameter: Payments.Parameter { get }
    
    /// the paramreter can be edited
    var editable: Bool { get }
    
    /// the parameter can be collapsed
    var collapsable: Bool { get }
    
    /// the parameter affects the history and the operation is reset to the step at which the value was originally set
    var affectsHistory: Bool { get }
    
    /// the paramreter after value update requests auto continue operation
    var autoContinue: Bool { get }
    
    func updated(value: String?) -> ParameterRepresentable
    func updated(editable: Bool) -> ParameterRepresentable
    func updated(collapsable: Bool) -> ParameterRepresentable
}

extension ParameterRepresentable {
    
    
    var editable: Bool { false }
    var collapsable: Bool { false }
    var affectsHistory: Bool { false }
    var autoContinue: Bool { false }
    
    func updated(value: String?) -> ParameterRepresentable { self }
    func updated(editable: Bool) -> ParameterRepresentable { self }
    func updated(collapsable: Bool) -> ParameterRepresentable { self }
}
