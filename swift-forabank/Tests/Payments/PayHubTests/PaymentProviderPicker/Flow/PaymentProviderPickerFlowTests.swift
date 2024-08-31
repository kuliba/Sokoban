//
//  PaymentProviderPickerFlowTests.swift
//
//
//  Created by Igor Malyarov on 31.08.2024.
//

import ForaTools
import XCTest

class PaymentProviderPickerFlowTests: XCTestCase {
    
    struct Latest: Equatable {
        
        let value: String
    }
    
    func makeLatest(
        _ value: String = anyMessage()
    ) -> Latest {
        
        return .init(value: value)
    }
    
    struct Payment: Equatable {
        
        let value: String
    }
    
    func makePayment(
        _ value: String = anyMessage()
    ) -> Payment {
        
        return .init(value: value)
    }
    
    struct PayByInstructions: Equatable {
        
        let value: String
    }
    
    func makePayByInstructions(
        _ value: String = anyMessage()
    ) -> PayByInstructions {
        
        return .init(value: value)
    }
    
    struct Provider: Equatable {
        
        let value: String
    }
    
    func makeProvider(
        _ value: String = anyMessage()
    ) -> Provider {
        
        return .init(value: value)
    }
    
    func makeServiceFailure(
        message: String = anyMessage(),
        source: ServiceFailure.Source = .connectivity
    ) -> ServiceFailure {
        
        return .init(message: message, source: source)
    }
    
    struct Service: Equatable {
        
        let value: String
    }
    
    func makeService(
        _ value: String = anyMessage()
    ) -> Service {
        
        return .init(value: value)
    }
    
    func makeServices(
        _ head: Service? = nil,
        tail: Service...
    ) -> MultiElementArray<Service> {
        
        return .init(head ?? makeService(), tail)
    }
}
