//
//  FooterStateProjectionTests.swift
//
//
//  Created by Igor Malyarov on 21.06.2024.
//

import AmountComponent
import AnywayPaymentUI
import Combine
import ForaTools
import XCTest

final class ProjectionTests: XCTestCase {
    
    func test_projection() {
        
        let subject = PassthroughSubject<FooterState, Never>()
        let publisher: AnyPublisher<Projection, Never> = subject
            .diff(using: { $1.diff(from: $0) })
            .eraseToAnyPublisher()
        let spy = ValueSpy(publisher)
        
        subject.send(makeState(amount: 100))
        subject.send(makeState(amount: 10))
        subject.send(makeState(amount: 100, state: .tapped))
        
        XCTAssertNoDiff(spy.values, [
            .amount(10),
            .buttonTapped,
        ])
    }
    
    // MARK: - Helpers
    
    private func makeState(
        amount: Decimal = anyAmount(),
        title: String = anyMessage(),
        state: FooterState.FooterButton.ButtonState = .active,
        style: FooterState.Style = .amount
    ) -> FooterState {
        
        return .init(
            amount: amount,
            button: .init(title: title, state: state),
            style: style
        )
    }
}
