//
//  XCTestCase+factories.swift
//  VortexTests
//
//  Created by Igor Malyarov on 07.12.2024.
//

@testable import Vortex
import XCTest

extension MainSectionFastOperationView.ViewModel {
    
    convenience init(
        _ createItems: CreateItems? = nil,
        isCollapsed: Bool = false
    ) {
        let createItems = createItems ?? { action in
            
            let qr = ButtonIconTextView.ViewModel(icon: .init(image: .ic40Qr, background: .circle), title: .init(text: FastOperationsTitles.qr), orientation: .horizontal) { action(.byQr) }
            
            let templates = ButtonIconTextView.ViewModel(icon: .init(image: .ic40Qr, background: .circle), title: .init(text: FastOperationsTitles.templates), orientation: .horizontal) { action(.templates) }
            
            return [qr, templates]
        }
        self.init(createItems: createItems, isCollapsed: isCollapsed)
    }
}

extension XCTestCase {
    
    func makeServiceLatest(
        origin: LatestOrigin? = nil,
        avatar: Latest.Avatar? = nil
    ) -> Latest {
        
        return .init(origin: origin ?? .service(makeLatestService()), avatar: avatar ?? .init(fullName: "", image: nil, topIcon: nil, icon: nil))
    }

    func makeLatestService(
        additionalItems: [LatestOrigin.Service.AdditionalItem]? = nil,
        amount: Decimal? = nil,
        currency: String? = nil,
        date: Int = .random(in: 1...1_000),
        detail: LatestOrigin.PaymentOperationDetailType = .account2Card,
        inn: String? = nil,
        lpName: String? = nil,
        md5Hash: String? = nil,
        name: String? = nil,
        paymentDate: Date = .now,
        paymentFlow: LatestOrigin.PaymentFlow? = nil,
        puref: String = anyMessage(),
        type: LatestOrigin.LatestType = "internet"
    ) -> LatestOrigin.Service {
        
        return .init(
            additionalItems: additionalItems,
            amount: amount,
            currency: currency,
            date: date,
            detail: detail,
            inn: inn,
            lpName: lpName,
            md5Hash: md5Hash,
            name: name,
            paymentDate: paymentDate,
            paymentFlow: paymentFlow,
            puref: puref,
            type: type
        )
    }
    
    func makePaymentServiceOperator(
        id: String = anyMessage(),
        inn: String = anyMessage(),
        icon: String? = anyMessage(),
        title: String = anyMessage(),
        type: String = anyMessage()
    ) -> UtilityPaymentProvider {
        
        return .init(id: id, icon: icon, inn: inn, title: title, type: type)
    }
}
