//
//  AnywayPaymentElementUIComponentTests.swift
//
//
//  Created by Igor Malyarov on 12.04.2024.
//

extension AnywayPayment.Element {
    
    var uiComponent: UIComponent {
        
        switch self {
        case let .field(field):
            return .field(.init(field))
            
        case let .parameter(parameter):
            fatalError()
            
        case let .widget(widget):
            switch widget {
            case .core:
                return .productPicker
                
            case .otp:
                return .otp
            }
        }
    }
}

enum UIComponent: Equatable {
    
    case field(Field)
    case otp, productPicker
}

extension UIComponent {
    
    struct Field: Equatable {
        
        let name: String
        let title: String
        let value: String
    }
}

private extension UIComponent.Field {
    
    init(_ field: AnywayPayment.Element.Field) {
        
        self.init(
            name: field.id.rawValue, 
            title: field.title,
            value: field.value.rawValue
        )
    }
}

import AnywayPaymentCore
import XCTest

final class AnywayPaymentElementUIComponentTests: XCTestCase {
    
    // MARK: - field
    
    func test_uiComponent_shouldDeliverFieldForField() {
        
        let element = makeAnywayPaymentFieldElement(.init(
            id: "123",
            title: "CDE",
            value: "abc"
        ))
        
        XCTAssertNoDiff(element.uiComponent, .field(.init(
            name: "123",
            title: "CDE",
            value: "abc"
        )))
    }
    
    // MARK: - widget
    
    func test_uiComponent_shouldDeliverOTPForOTPWidget() {
        
        let element = makeAnywayPaymentWidgetElement(.otp)
        
        XCTAssertNoDiff(element.uiComponent, .otp)
    }
    
    func test_uiComponent_shouldDeliverProductPickerForCoreWidget() {
        
        let element = makeAnywayPaymentWidgetElement(.core(makeWidgetPaymentCore(productType: .account)))
        
        XCTAssertNoDiff(element.uiComponent, .productPicker)
    }
}
