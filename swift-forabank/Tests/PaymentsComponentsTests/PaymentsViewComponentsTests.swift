////
////  PaymentsViewComponentsTests.swift
////
////
////  Created by Дмитрий Савушкин on 29.09.2023.
////
//
//@testable import PaymentsComponents
//
//import XCTest
//import SwiftUI
//
//final class PaymentsComponentsTests: XCTestCase {
//    
//    //MARK: - tests configuration
//    
//    func test_paymentSticker_config_shouldReturnAllValue() {
//        
//        let config = PaymentStickerViewConfig(
//            rectangleColor: .accentColor,
//            configHeader: .init(
//                titleFont: .body,
//                titleColor: .accentColor,
//                descriptionFont: .body,
//                descriptionColor: .accentColor
//            ),
//            configOption: .init(
//                titleFont: .body,
//                titleColor: .accentColor,
//                iconColor: .accentColor,
//                descriptionFont: .body,
//                descriptionColor: .accentColor
//            )
//        )
//        
//        XCTAssertEqual(config.rectangleColor, .accentColor)
//        XCTAssertEqual(config.configHeader.titleFont, .body)
//        XCTAssertEqual(config.configHeader.titleColor, .accentColor)
//        XCTAssertEqual(config.configHeader.descriptionFont, .body)
//        XCTAssertEqual(config.configHeader.descriptionColor, .accentColor)
//        XCTAssertEqual(config.configOption.titleFont, .body)
//        XCTAssertEqual(config.configOption.titleColor, .accentColor)
//        XCTAssertEqual(config.configOption.iconColor, .accentColor)
//        XCTAssertEqual(config.configOption.descriptionFont, .body)
//        XCTAssertEqual(config.configOption.descriptionColor, .accentColor)
//    }
//    
//    func test_paymentSelect_config_shouldReturnOptionConfig() {
//        
//        let config = PaymentSelectViewConfig.OptionConfig(
//            nameFont: .body,
//            nameForeground: .accentColor
//        )
//        
//        XCTAssertEqual(config.nameFont, .body)
//        XCTAssertEqual(config.nameForeground, .accentColor)
//    }
//    
//    func test_paymentSelect_config_shouldReturnSelectedOptionConfig() {
//        
//        let config = PaymentSelectViewConfig.SelectedOptionConfig(
//            titleFont: .body,
//            titleForeground: .accentColor
//        )
//        
//        XCTAssertEqual(config.titleFont, .body)
//        XCTAssertEqual(config.titleForeground, .accentColor)
//    }
//    
//    func test_paymentSelect_config_shouldReturnOptionsListConfig() {
//        
//        let config = PaymentSelectViewConfig.OptionsListConfig(
//            titleFont: .body,
//            titleForeground: .accentColor
//        )
//        
//        XCTAssertEqual(config.titleFont, .body)
//        XCTAssertEqual(config.titleForeground, .accentColor)
//    }
//}
