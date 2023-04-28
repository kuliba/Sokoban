//
//  QRScenarioParameter.swift
//  ForaBank
//
//  Created by Max Gribov on 30.01.2023.
//

import Foundation

protocol QRScenarioParameter: Identifiable, Equatable, Decodable {
    
    associatedtype Value: Decodable
    
    var type: QRScenarioParameterType { get }
    var id: String { get }
    var value: Value? { get }
}

enum QRScenarioParameterType: String, Decodable, Unknownable {
    
    case subscriber = "SUBSCRIBER"
    case productSelect = "PRODUCT_SELECT"
    case check = "CHECK"
    case unknown
}

//MARK: - Parameters

struct QRScenarioParameterSubscriber: QRScenarioParameter {

    let type: QRScenarioParameterType
    let id: String
    let value: String?
    let icon: String
    let subscriptionPurpose: String
}

struct QRScenarioParameterProductSelect: QRScenarioParameter {

    let type: QRScenarioParameterType
    let id: String
    let value: String?
    let title: String
    let filter: Filter
    
    struct Filter: Equatable, Decodable  {
        
        let productTypes: [ProductType]
        let currencies: [Currency]
        let additional: Bool
    }
}

struct QRScenarioParameterCheck: QRScenarioParameter {

    let type: QRScenarioParameterType
    let id: String
    let value: Bool?
    let link: Link
    
    struct Link: Equatable, Decodable {
        
        //FIXME: - extract title to root
        let title: String
        let subtitle: String
        let url: URL
    }
}

//MARK: - Boxing

struct AnyQRScenarioParameter: Equatable {

    let id: String
    let parameter: Any
    
    init<P>(_ parameter: P) where P : QRScenarioParameter {
        
        self.id = parameter.id
        self.parameter = parameter
    }
    
    static func == (lhs: AnyQRScenarioParameter, rhs: AnyQRScenarioParameter) -> Bool {
        
        switch (lhs.parameter, rhs.parameter) {
        case (let lhsParam as QRScenarioParameterSubscriber, let rhsParam as QRScenarioParameterSubscriber):
            return lhsParam == rhsParam
            
        case (let lhsParam as QRScenarioParameterProductSelect, let rhsParam as QRScenarioParameterProductSelect):
            return lhsParam == rhsParam
            
        case (let lhsParam as QRScenarioParameterCheck, let rhsParam as QRScenarioParameterCheck):
            return lhsParam == rhsParam

        default:
            return false
        }
    }
}
