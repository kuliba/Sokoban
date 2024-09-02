//
//  PaymentProviderPickerFlowTests.swift
//
//
//  Created by Igor Malyarov on 31.08.2024.
//

import ForaTools
import PayHub
import XCTest

class PaymentProviderPickerFlowTests: XCTestCase {
    
    struct Destination: Equatable {
        
        let value: String
    }
    
    func makeDestination(
        _ value: String = anyMessage()
    ) -> Destination {
        
        return .init(value: value)
    }
    
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
    
    struct ServicePicker: Equatable {
        
        let value: String
    }
    
    func makeServicePicker(
        _ value: String = anyMessage()
    ) -> ServicePicker {
        
        return .init(value: value)
    }
    
    struct ServicesFailure: Equatable {
        
        let value: String
    }
    
    func makeServicesFailure(
        _ value: String = anyMessage()
    ) -> ServicesFailure {
        
        return .init(value: value)
    }
    
    func makeServices(
        _ first: Service? = nil,
        _ second: Service? = nil,
        tail: Service...
    ) -> MultiElementArray<Service> {
        
        return .init(first ?? makeService(), second ?? makeService(), tail)
    }
}
