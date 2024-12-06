//
//  LatestPaymentsViewComponentTests.swift
//  VortexTests
//
//  Created by Andryusina Nataly on 10.07.2023.
//

@testable import ForaBank
import TextFieldComponent
import XCTest
import SwiftUI

private typealias ViewModel = LatestPaymentsView.ViewModel.LatestPaymentButtonVM

final class LatestPaymentsViewComponentTests: XCTestCase {
    
    // MARK: avatarOutside
    
    func test_avatarOutside_mig_shouldReturnSmartphoneIcon() {
        
        let sut = avatar(
            puref: .direct,
            additionalList: .test
        )
        
        XCTAssertNoDiff(sut?.currentIcon, .ic24Smartphone)
        XCTAssertNil(sut?.currentAvatarText)
    }
    
    func test_avatarOutside_migCard_shouldReturnCardIcon() {
        
        let sut = avatar(
            puref: .directCard,
            additionalList: .test
        )
        
        XCTAssertNoDiff(sut?.currentIcon, .ic24CreditCard)
        XCTAssertNil(sut?.currentAvatarText)
    }

    func test_avatarOutside_dkm_shouldReturnCardIcon() {
        
        let sut = avatar(
            puref: .dkm,
            additionalList: .test
        )
        
        XCTAssertNoDiff(sut?.currentIcon, .ic24CreditCard)
        XCTAssertNil(sut?.currentAvatarText)
    }

    func test_avatarOutside_dkq_shouldReturnCardIcon() {
        
        let sut = avatar(
            puref: .dkq,
            additionalList: .test
        )
        
        XCTAssertNoDiff(sut?.currentIcon, .ic24CreditCard)
        XCTAssertNil(sut?.currentAvatarText)
    }

    func test_avatarOutside_dkr_shouldReturnCardIcon() {
        
        let sut = avatar(
            puref: .dkr,
            additionalList: .test
        )
        
        XCTAssertNoDiff(sut?.currentIcon, .ic24CreditCard)
        XCTAssertNil(sut?.currentAvatarText)
    }

    func test_avatarOutside_pw0_shouldReturnCardIcon() {
        
        let sut = avatar(
            puref: .pw0,
            additionalList: .test
        )
        
        XCTAssertNoDiff(sut?.currentIcon, .ic24CreditCard)
        XCTAssertNil(sut?.currentAvatarText)
    }

    func test_avatarOutside_unknow_shouldReturnGlobeIcon() {
        
        let sut = avatar(
            puref: "",
            additionalList: .test
        )
        
        XCTAssertNoDiff(sut?.currentIcon, .ic24Globe)
        XCTAssertNil(sut?.currentAvatarText)
    }

    func test_avatarOutside_contact_shouldReturnInitials() {
        
        let sut = avatar(
            puref: .contact,
            additionalList: .testContact
        )
        
        XCTAssertNoDiff(sut?.currentAvatarText, "NL")
        XCTAssertNil(sut?.currentIcon)
    }
    
    func test_avatarOutside_contact_withOutNameLasName_shouldReturnGlobeIcon() {
        
        let sut = avatar(
            puref: .contact,
            additionalList: .test
        )
        
        XCTAssertNoDiff(sut?.currentIcon, .ic24Globe)
        XCTAssertNil(sut?.currentAvatarText)
    }
    
    func test_avatarOutside_contactCash_shouldReturnInitials() {
        
        let sut = avatar(
            puref: .contactCash,
            additionalList: .testContact
        )
        
        XCTAssertNoDiff(sut?.currentAvatarText, "NL")
        XCTAssertNil(sut?.currentIcon)
    }

    func test_avatarOutside_contactAccount_shouldReturnInitials() {
        
        let sut = avatar(
            puref: .contactAccount,
            additionalList: .testContact
        )
        
        XCTAssertNoDiff(sut?.currentAvatarText, "NL")
        XCTAssertNil(sut?.currentIcon)
    }
    
    // MARK: - Helpers
    
    private func avatar(
        puref: String,
        additionalList: [PaymentServiceData.AdditionalListData]
    ) -> ViewModel.Avatar? {
        
        return ViewModel.avatarOutside(
            puref: puref,
            additionalList: additionalList
        )
    }
}

extension String {
    
    static let direct = "iFora||MIG"
    static let directCard = "iFora||MIG||card"
    static let contact = "iFora||Addressless"
    static let contactCash = "iFora||Addressing||cash"
    static let contactAccount = "iFora||Addressing||account"
    static let dkm = "iFora||DKM"
    static let dkq = "iFora||DKQ"
    static let dkr = "iFora||DKR"
    static let pw0 = "iFora||PW0"
}

extension Array where Element == PaymentServiceData.AdditionalListData {
    
    static let test: Self =  [
        .init(
            fieldTitle: nil,
            fieldName: "trnPickupPoint",
            fieldValue: "AM",
            svgImage: nil),
        .init(
            fieldTitle: nil,
            fieldName: "DIRECT_BANKS",
            fieldValue: "iFora||TransferEvocaClient12",
            svgImage: nil),
        .init(
            fieldTitle: nil,
            fieldName: "RECP",
            fieldValue: "+37496127188",
            svgImage: nil),
        .init(
            fieldTitle: nil,
            fieldName: "##CURR",
            fieldValue: "RUB",
            svgImage: nil)
    ]
    
    static let testContact: Self =  [
        .init(
            fieldTitle: nil,
            fieldName: "CURR",
            fieldValue: "RUB",
            svgImage: nil
        ),
        .init(
            fieldTitle: nil,
            fieldName: "bName",
            fieldValue: "Name",
            svgImage: nil
        ),
        .init(
            fieldTitle: nil,
            fieldName: "bLastName",
            fieldValue: "LastName",
            svgImage: nil
        )
    ]
}

extension ViewModel.Avatar {
    
    var currentIcon: Image? {
        
        switch self {
            
        case let .icon(image, _):
            
            return image
            
        case let .image(image):
            
            return image

        default:
            return nil
        }
    }
    
    var currentAvatarText: String? {
        
        switch self {
            
        case let .text(text):
            
            return text
            
        default:
            return nil
        }
    }
}
