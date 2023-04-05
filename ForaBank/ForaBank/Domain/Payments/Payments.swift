//
//  Payments.swift
//  ForaBank
//
//  Created by Max Gribov on 07.02.2022.
//

import Foundation

//MARK: - General

enum Payments {

    enum Category: String, CaseIterable {
        
        case general = "ru.forabank.sense.payments.category.general"
        case fast  = "ru.forabank.sense.payments.category.fast"
        case taxes = "iFora||1331001"
        
        var services: [Service] {
            
            switch self {
            case .general: return [.requisites, .c2b, .toAnotherCard, .mobileConnection, .return, .change]
            case .fast: return [.sfp, .abroad]
            case .taxes: return [.fns, .fms, .fssp]
            }
        }
        
        var name: String {
            
            switch self {
            case .fast: return "Быстрые платежи"
            case .taxes: return "Налоги и услуги"
            case .general: return ""
            }
        }
        
        static func category(for service: Service) -> Category? {
            
            for category in Category.allCases {
                
                if category.services.contains(service) {
                    
                    return category
                }
            }
            
            return nil
        }
    }
    
    enum Service: String {
        
        case sfp
        case abroad
        case fms
        case fns
        case fssp
        case requisites
        case c2b
        case toAnotherCard
        case mobileConnection
        case `return`
        case change
    }
    
    enum Operator : String {
        
        case sfp               = "iFora||TransferC2CSTEP"
        case direct            = "iFora||MIG"
        case directCard        = "iFora||MIG||card"
        case contact           = "iFora||Addressless"
        case contactCash       = "iFora||Addressing||cash"
        case fssp              = "iFora||5429"
        case fms               = "iFora||6887"
        case fns               = "iFora||6273"
        case fnsUin            = "iFora||7069"
        case requisites        = "requisites"
        case c2b               = "c2b"
        case toAnotherCard     = "toAnotherCard"
        case mobileConnection  = "mobileConnection"
        case `return`          = "return"
        case change            = "change"
    }
}

//MARK: - Parameter

extension Payments {
    
    struct Parameter: Equatable, Hashable, CustomDebugStringConvertible {
        
        typealias ID = String
        typealias Value = String?
        
        let id: ID
        let value: Value
        
        var debugDescription: String { "\(id)[\(value != nil ? value! : "empty")]" }
    }
}

extension Payments.Parameter {
    
    enum Placement: CaseIterable {
        
        case top
        case feed
        case bottom
    }
    
    enum Style {
        
        case light
        case dark
    }
    
    struct Group: Hashable {
        
        let id: String
        let type: Kind
        
        enum Kind: Hashable {
            
            case regular
            case spoiler
            case contact
            case info
        }
    }
    
    enum View {
        
        case select
        case selectSwitch
        case input
        case info
    }
}

//MARK: - Operation

extension Payments {
    
    struct Operation {

        let service: Service
        let source: Source?
        let steps: [Step]
        let visible: [Parameter.ID]
        
        init(service: Service, source: Source?, steps: [Step], visible: [Parameter.ID]) {
            
            self.service = service
            self.source = source
            self.steps = steps
            self.visible = visible
        }
        
        init(service: Service) {
            
            self.init(service: service, source: nil, steps: [], visible: [])
        }
        
        init(service: Service, source: Source) {
            
            self.init(service: service, source: source, steps: [], visible: [])
        }
    }
}

extension Payments.Operation {
    
    /// Source of operation
    enum Source: CustomDebugStringConvertible {
        
        /// operation started from template
        case template(PaymentTemplateData.ID)
        
        /// operation started from latest operation
        case latestPayment(LatestPaymentData.ID)
        
        case qr
        
        case sfp(phone: String, bankId: BankData.ID)
        
        case direct(phone: String?, countryId: CountryData.ID)
        
        case `return`(operationId: String, transferNumber: String, amount: String, productId: String)
        
        case change(operationId: String, transferNumber: String, name: String)
        
        case requisites(qrCode: QRCode)
        
        case c2bSubscribe(URL)
        
        case mock(Payments.Mock)
        
        var debugDescription: String {
            
            switch self {
            case let .template(templateId): return "template: \(templateId)"
            case let .latestPayment(latestPaymentId): return "latest payment: \(latestPaymentId)"
            case .qr: return "qr"
            case let .sfp(phone: phone, bankId: bankId): return "sfp: \(phone), bankId: \(bankId)"
            case let .direct(phone: phone, countryId: countryId): return "direct: \(phone ?? "nil"), countryId: \(countryId)"
            case let .return(operationId: operationId, transferNumber: number, amount: amount, productId: productId): return "operationId: \(operationId), transferNumber: \(number), amount: \(amount), productId: \(productId)"
            case let .change(operationId: operationId, transferNumber: number, name: name): return "operationId: \(operationId), transferNumber: \(number), name: \(name)"
            case let .mock(mock): return "mock service: \(mock.service.rawValue)"
            case let .requisites(qrCode): return "qrCode: \(qrCode)"
            case let .c2bSubscribe(url): return "c2b subscribe url: \(url.absoluteURL)"
            }
        }
    }
    
    /// Operation step
    struct Step {
        
        let parameters: [PaymentsParameterRepresentable]
        let front: Front
        let back: Back
        
        struct Front: Equatable {
            
            /// Parameters visible in UI
            let visible: [Parameter.ID]
            
            /// Is user complete updatding all parameters for this step
            let isCompleted: Bool
        }
        
        struct Back: Equatable {
            
            let stage: Stage
            
            /// Parameters requred to process
            let required: [Payments.Parameter.ID]
            
            /// Parameters processed
            let processed: [Payments.Parameter]?
        }

        
        enum Status: Equatable {
            
            /// updating parameters on front side
            case editing
            
            /// pending parameters to back side
            case pending(parameters: [Parameter], stage: Stage)
            
            /// paramaters updated on front side and processed on back side if required
            case complete
            
            /// parameters changed after procrssing
            case invalidated
        }
        
        struct ProcessedData {
            
            let current: Payments.Parameter
            let processed: Payments.Parameter
        }
    }
    
    enum Stage: Equatable, CustomDebugStringConvertible {
        
        case local
        case remote(Remote)

        enum Remote: String {
            
            case start
            case next
            case confirm
            case complete
        }
        
        var debugDescription: String {
            
            switch self {
            case .local: return "local"
            case let .remote(remote): return "remote: \(remote)"
            }
        }
    }
    
    enum TransferType {
        
        case anyway
        case sfp
        case abroad
        case requisites
        case c2b
        case toAnotherCard
        case mobileConnection
        case `return`
        case change
    }
    
    enum Action: Equatable {
        
        /// step required
        case step(index: Int)
        
        /// required update parameters values in ui by user
        case frontUpdate
        
        /// operation confirm required in ui by user
        case frontConfirm
        
        /// process parameters on server
        case backProcess(parameters: [Parameter], stepIndex: Int, stage: Stage)
        
        /// rollback operation to step
        case rollback(stepIndex: Int)
    }
}

//MARK: - Success

extension Payments {
    
    //TODO: refactor into dynamic list of parameters
    struct Success {
 
        let operationDetailId: Int
        let status: TransferResponseBaseData.DocumentStatus
        let productId: ProductData.ID
        let amount: Double
        let service: Payments.Service
        let serviceData: ServiceData?
        
        init(operationDetailId: Int, status: TransferResponseBaseData.DocumentStatus, productId: ProductData.ID, amount: Double, service: Payments.Service, serviceData: ServiceData? = nil) {
            
            self.operationDetailId = operationDetailId
            self.status = status
            self.productId = productId
            self.amount = amount
            self.service = service
            self.serviceData = serviceData
        }
        
        init(
            with response: TransferResponseBaseData,
            operation: Payments.Operation,
            serviceData: ServiceData? = nil
        ) throws {
            
            guard let status = response.documentStatus,
                  let amount = operation.amount,
                  let productId = operation.productId else {
                
                //TODO: more informative error
                throw Payments.Error.unsupported
            }
            
            self.init(operationDetailId: response.paymentOperationDetailId, status: status, productId: productId, amount: amount, service: operation.service, serviceData: serviceData)
        }
        
        enum ServiceData {
            
            case c2bSubscriptionData(C2BSubscriptionData)
            case mobileConnectionData(MobileConnectionData)
            case abroadPayments(TransferResponseBaseData)
        }
    }
}

//MARK: - Process

extension Payments {
    
    enum ProcessResult: CustomDebugStringConvertible {
        
        case step(Operation)
        case confirm(Operation)
        case complete(Payments.Success)
        
        var debugDescription: String {
            
            switch self {
            case .step: return "step"
            case .confirm: return "confirm"
            case .complete: return "complete"
            }
        }
    }
}

//MARK: - Antifraud

extension Payments {
    
    struct AntifraudData {
        
        let payeeName: String
        let phone: String
        let amount: String
    }
}

//MARK: - Mock

extension Payments {
    
    struct Mock {
        
        let service: Payments.Service
        let parameters: [Payments.Parameter]
    }
}

//MARK: - Error

extension Payments {
    
    enum Error: LocalizedError {
        
        case unableCreateOperationForService(Service)
        case unableCreateRepresentable(Payments.Parameter.ID)
        case unexpectedProductType(ProductType)
        case unexpectedProcessResult(Payments.ProcessResult)
        
        case missingParameter(Payments.Parameter.ID)
        case missingOptions(ParameterData)
        case missingValueForParameter(Payments.Parameter.ID)
        case missingValue(ParameterData)
        case missingSource(Service)
        
        case action(Action)

        case notAuthorized
        case unsupported
        
        enum Action {
            
            case warning(parameterId: Payments.Parameter.ID, message: String)
            case alert(title: String, message: String)
        }
        
        var errorDescription: String? {
            
            switch self {
            case let .unableCreateOperationForService(service):
                return "Unable create operation for service: \(service)"
                
            case let .unableCreateRepresentable(parameterId):
                return "Unable create representable parameter for parameter id: \(parameterId)"
                
            case let .unexpectedProductType(productType):
                return "Unexpected product type: \(productType)"
                
            case let .unexpectedProcessResult(result):
                return "Unexpected operation processing result: \(result)"
                
            case let .missingParameter(parameterId):
                return "Missing parameter with id: \(parameterId)"
                
            case let .missingOptions(parameterData):
                return "Missing options in parameter data: \(parameterData)"
                
            case let .missingValue(parameterData):
                return "Missing value in parameter data: \(parameterData)"
            
            case let .missingValueForParameter(parameterId):
                return "Missing value for parameter: \(parameterId)"
                
            case let .action(action):
                switch action {
                case let .warning(parameterId: parameterId, message: message):
                    return "Warning action for parameter id: \(parameterId), message: \(message)"
                    
                case let .alert(title: title, message: message):
                    return "Alert action with title: \(title), message: \(message)"
                }

            case .notAuthorized:
                return "Not authorized request attempt"
                
            case let .missingSource(service):
                return "Missing source for service: \(service)"
                
            case .unsupported:
                return "Unsupported"
            }
        }
    }
}
