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
    }
    
    enum Service: String {
        
        case fssp
        case fms
        case fns
        
        var operators: [Operator] {
            
            switch self {
            case .fms: return [.fms]
            case .fns: return [.fns, .fnsUin]
            case .fssp: return [.fssp]
            }
        }
    }
    
    enum Operator : String {
        
        case fssp       = "iFora||5429"
        case fms        = "iFora||6887"
        case fns        = "iFora||6273"
        case fnsUin     = "iFora||7069"
    }
    
    struct Parameter {
 
        let id: String
        let value: String
        let type: Kind
        let extra: Bool
        
        enum Kind {
            
            case hidden
            case select([Option], icon: ImageData, title: String)
            case selectSimple([OptionSimple], icon: ImageData, title: String, selectionTitle: String, description: String?)
            case selectSwitch([OptionSimple])
            case input(icon: ImageData, title: String, validator: InputValidator)
            case info(icon: ImageData, title: String)
            case name(icon: ImageData, title: String)
            case amount(title: String, validator: AmountValidator)
            case card
        }
    }
    
    struct Operation {
        
        let service: Service
        let type: Kind
        let currency: Currency
        let parameters: [Parameter]
        let history: [[Parameter.Value]]
        
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
