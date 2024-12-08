//
//  Payments+ParameterMosParkingTests.swift
//  VortexTests
//
//  Created by Igor Malyarov on 19.06.2023.
//

@testable import Vortex
import XCTest

extension Payments {
    
    struct ParameterMosParking: PaymentsParameterRepresentable {
        
        let parameter: Parameter
        
        init(value: Parameter.Value) {
            
            self.parameter = .init(
                id: Payments.Parameter.Identifier.mosParking.rawValue,
                value: value
            )
        }
    }
}

final class Payments_ParameterMosParkingTests: XCTestCase {
    
    func test_init_shouldSetParameterID_valueNil() {
        
        let parameterMosParking = Payments.ParameterMosParking(value: nil)
        
        XCTAssertNoDiff(
            parameterMosParking.parameter.id,
            "MosParking"
        )
    }
    
    func test_init_shouldSetParameterID_valueNonNil() {
        
        let parameterMosParking = Payments.ParameterMosParking(value: "a")
        
        XCTAssertNoDiff(
            parameterMosParking.parameter.id,
            "MosParking"
        )
    }
    
    func test_init_shouldSetParameterValue_nil() {
        
        let parameterMosParking = Payments.ParameterMosParking(value: nil)
        
        XCTAssertNoDiff(
            parameterMosParking.parameter.value,
            nil
        )
    }
    
    func test_init_shouldSetParameterValue_nonNil() {
        
        let parameterMosParking = Payments.ParameterMosParking(value: "a")
        
        XCTAssertNoDiff(
            parameterMosParking.parameter.value,
            "a"
        )
    }
}
