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
    
    class Parameter: Identifiable {

        let id: String
        var value: String?
        
        var result: Payments.Parameter.Result { Result(id: id, value: value) }
        
        internal init(id: String, value: String?) {
            
            self.id = id
            self.value = value
        }
        
        convenience init(value: Parameter.Result) {
            
            self.init(id: value.id, value: value.value)
        }
        
        struct Result {
            
            let id: String
            let value: String?
        }
    }
    
    struct Operation {
        
        let service: Service
        let parameters: [Parameter]
        let history: [[Parameter.Result]]
        
        enum Kind {
            
            case service(title: String, icon: ImageData)
            case template(template: PaymentTemplateData.ID, name: String)
        }
    }
    
    enum Error: Swift.Error {
        case unsupported
        case unableCreateOperationForService(Service)
    }
}
