//
//  CreditCardMVPRootViewModelFactoryTests.swift
//  VortexTests
//
//  Created by Igor Malyarov on 29.03.2025.
//

@testable import Vortex
import CreditCardMVPCore
import CreditCardMVPUI
import XCTest

class CreditCardMVPRootViewModelFactoryTests: RootViewModelFactoryTests {
    
    let approvedInfo = "Про то что можно забрать в офисе"
    let approvedMessage = "Ваша кредитная карта готова к оформлению!"
    let approvedTitle = "Кредитная карта одобрена"
    
    let failureMessage = "Что-то пошло не так...\nПопробуйте позже."
    
    let inReview = "Ожидайте рассмотрения Вашей заявки\nРезультат придет в Push/смс\nПримерное время рассмотрения заявки 10 минут."
    
    let rejectedMessage = "К сожалению, ваша кредитная история не позволяет оформить карту"
    let rejectedTitle = "Кредитная карта не одобрена"
    
    typealias ContentDomain = CreditCardMVPContentDomain
    
    func alert(
        _ message: String = anyMessage()
    ) -> LoadFailure<ContentDomain.FailureType> {
        
        return .init(message: message, type: .alert)
    }
    
    func informer(
        _ message: String = anyMessage()
    ) -> LoadFailure<ContentDomain.FailureType> {
        
        return .init(message: message, type: .informer)
    }
    
    func approved(
        consent: AttributedString? = nil,
        product: ProductCard? = nil
    ) -> ContentDomain.FinalStatus {
        
        return .approved(
            consent: consent ?? makeConsent(),
            product ?? makeProductCard()
        )
    }
    
    func approved(
        consent: AttributedString? = nil,
        product: ProductCard? = nil
    ) -> ContentDomain.DraftableStatus {
        
        return .approved(
            consent: consent ?? makeConsent(),
            product ?? makeProductCard()
        )
    }
    
    func rejected(
        _ product: ProductCard? = nil
    ) -> ContentDomain.FinalStatus {
        
        return .rejected(product ?? makeProductCard())
    }
    
    func rejected(
        _ product: ProductCard? = nil
    ) -> ContentDomain.DraftableStatus {
        
        return .rejected(product ?? makeProductCard())
    }
    
    func draft(
        application: ContentDomain.Draft.ApplicationState = .pending
    ) -> ContentDomain.DraftableStatus {
        
        return .draft(.init(application: application))
    }
    
    func makeConsent(
        _ value: String = anyMessage()
    ) -> AttributedString {
        
        return .init(value)
    }
    
    func makeProductCard(
        limit: String = anyMessage(),
        md5Hash: String = anyMessage(),
        options: [ProductCard.Option] = [
            .init(title: anyMessage(), value: anyMessage())
        ],
        title: String = anyMessage(),
        subtitle: String = anyMessage()
    ) -> ProductCard {
        
        return .init(
            limit: limit,
            md5Hash: md5Hash,
            options: options,
            title: title,
            subtitle: subtitle
        )
    }
    
    func assertApproved(
        _ flow: CreditCardMVPDomain.Flow,
        consent: AttributedString,
        product: ProductCard,
        message: String,
        title: String,
        info: String,
        file: StaticString = #file,
        line: UInt = #line
    ) {
        switch flow.state.navigation {
        case let .decision(decision):
            XCTAssertNoDiff(decision, .init(message: message, status: .approved(.init(consent: consent, info: info, product: product)), title: title), file: file, line: line)
            
        default:
            XCTFail("Expected decision case, but got \(String(describing: flow.state.navigation)) instead.", file: file, line: line)
        }
    }
    
    func assertFailure(
        _ flow: CreditCardMVPDomain.Flow,
        message: String,
        file: StaticString = #file,
        line: UInt = #line
    ) {
        switch flow.state.navigation {
        case let .complete(complete):
            XCTAssertNoDiff(complete, .init(message: message, status: .failure), file: file, line: line)
            
        default:
            XCTFail("Expected complete case, but got \(String(describing: flow.state.navigation)) instead.", file: file, line: line)
        }
    }
    
    func assertInReview(
        _ flow: CreditCardMVPDomain.Flow,
        message: String,
        file: StaticString = #file,
        line: UInt = #line
    ) {
        switch flow.state.navigation {
        case let .complete(complete):
            XCTAssertNoDiff(complete, .init(message: message, status: .inReview), file: file, line: line)
            
        default:
            XCTFail("Expected complete case, but got \(String(describing: flow.state.navigation)) instead.", file: file, line: line)
        }
    }
    
    func assertRejected(
        _ flow: CreditCardMVPDomain.Flow,
        message: String,
        title: String,
        file: StaticString = #file,
        line: UInt = #line
    ) {
        switch flow.state.navigation {
        case let .decision(decision):
            XCTAssertNoDiff(decision, .init(message: message, status: .rejected, title: title), file: file, line: line)
            
        default:
            XCTFail("Expected decision case, but got \(String(describing: flow.state.navigation)) instead.", file: file, line: line)
        }
    }
}
