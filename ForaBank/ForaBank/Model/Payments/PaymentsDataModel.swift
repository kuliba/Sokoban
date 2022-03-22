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
    
    struct Parameter: Equatable, CustomDebugStringConvertible {
        
        typealias ID = String
        typealias Value = String?
        
        let id: ID
        let value: Value
        
        var debugDescription: String { "id: \(id), value: \(value != nil ? value! : "empty")" }
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
    
    struct Success {

        let status: Status
        let amount: Double
        let currency: Currency
        let icon: ImageData?
        let operationDetailId: Int
        
        internal init(status: Payments.Success.Status, amount: Double, currency: Currency, icon: ImageData?, operationDetailId: Int) {
            
            self.status = status
            self.amount = amount
            self.currency = currency
            self.icon = icon
            self.operationDetailId = operationDetailId
        }

        init?(with transferResponse: TransferResponseBaseData) {
            
            guard let anywayTransferResponse = transferResponse as? TransferAnywayResponseData,
            let documentStatus = anywayTransferResponse.documentStatus,
            let amount = anywayTransferResponse.amount,
            let currency = anywayTransferResponse.currencyAmount else {
                return nil
            }
            
            self.status = Status(with: documentStatus)
            self.amount = amount
            self.currency = Currency(description: currency)
            self.icon = nil
            self.operationDetailId = anywayTransferResponse.paymentOperationDetailId
        }
        
        enum Status {
            
            case complete
            case inProgress
            case rejected
            
            var description: String {
                
                switch self {
                case .complete: return "Оплата прошла успешно"
                case .inProgress: return "Операция выполняется"
                case .rejected: return "Отказ"
                }
            }
            
            init(with documentStatus: TransferResponseBaseData.DocumentStatus){
                
                switch documentStatus {
                case .complete: self = .complete
                case .inProgress: self = .inProgress
                case .rejected: self = .rejected
                }
            }
        }
    }
    
    enum Error: Swift.Error {
        
        case unableLoadFMSCategoryOptions
        case unableLoadFTSCategoryOptions
        case unableLoadFSSPDocumentOptions
        case unableCreateOperationForService(Service)
        case unexpectedOperatorValue
        case missingOperatorParameter
        case missingParameter
        case missingPayer
        case missingCurrency
        case missingCodeParameter
        case missingAmountParameter
        case missingAnywayTransferAdditional
        case failedTransferWithEmptyDataResponse
        case failedTransfer(status: ServerStatusCode, message: String?)
        case failedMakeTransferWithEmptyDataResponse
        case failedMakeTransfer(status: ServerStatusCode, message: String?)
        case anywayTransferFinalStepExpected
        case notAuthorized
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
