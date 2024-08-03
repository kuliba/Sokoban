//
//  PaymentProviderSegmentTests.swift
//  ForaBankTests
//
//  Created by Igor Malyarov on 22.07.2024.
//

@testable import ForaBank
import XCTest

final class PaymentProviderSegmentTests: XCTestCase {
    
    func test_initWithProviders_shouldCreateEmptyOnEmpty() {
        
        XCTAssertNoDiff(Segments(with: []), [])
    }
    
    func test_initWithProviders_shouldCreateWithOne() {
        
        let (id, icon, title, inn, segment) = (anyMessage(), anyMessage(), anyMessage(), anyMessage(), anyMessage())
        
        XCTAssertNoDiff(Segments(with: [
            .init(id, icon: icon, inn: inn, title: title, segment: segment)
        ]), [
            .init(title: segment, providers: [
                .init(id, icon: icon, inn: inn, title: title, segment: segment)
            ])
        ])
    }
    
    func test_initWithProviders_shouldCreateWithTwoInSameSegment() {
        
        let segment = anyMessage()
        let (id1, icon1, inn1) = (anyMessage(), anyMessage(), anyMessage())
        let (id2, icon2, inn2) = (anyMessage(), anyMessage(), anyMessage())
        
        XCTAssertNoDiff(Segments(with: [
            .init(id1, icon: icon1, inn: inn1, title: "b", segment: segment),
            .init(id2, icon: icon2, inn: inn2, title: "a", segment: segment)
        ]), [
            .init(title: segment, providers: [
                .init(id2, icon: icon2, inn: inn2, title: "a", segment: segment),
                .init(id1, icon: icon1, inn: inn1, title: "b", segment: segment),
            ])
        ])
    }
    
    func test_initWithProviders_shouldCreateWithTwoInDifferentSegments() {
        
        let (id1, icon1, title1, inn1) = (anyMessage(), anyMessage(), anyMessage(), anyMessage())
        let (id2, icon2, title2, inn2) = (anyMessage(), anyMessage(), anyMessage(), anyMessage())
        
        XCTAssertNoDiff(Segments(with: [
            .init(id2, icon: icon2, inn: inn2, title: title2, segment: "b"),
            .init(id1, icon: icon1, inn: inn1, title: title1, segment: "a"),
        ]), [
            .init(title: "a", providers: [
                .init(id1, icon: icon1, inn: inn1, title: title1, segment: "a")
            ]),
            .init(title: "b", providers: [
                .init(id2, icon: icon2, inn: inn2, title: title2, segment: "b")
            ])
        ])
    }
    
    func test_initWithProviders_shouldCreateWithDifferentSegmentsSortedBySegmentAndINN() {
        
        let (id1, icon1, title1, inn1) = (anyMessage(), anyMessage(), anyMessage(), anyMessage())
        let (id2, icon2) = (anyMessage(), anyMessage())
        let (id3, icon3) = (anyMessage(), anyMessage())
        
        XCTAssertNoDiff(Segments(with: [
            .init(id1, icon: icon1, inn: inn1, title: title1, segment: "2"),
            .init(id2, icon: icon2, inn: "2", title: "a", segment: "1"),
            .init(id3, icon: icon3, inn: "1", title: "b", segment: "1")
        ], providerKeyPath: \.inn), [
            .init(title: "1", providers: [
                .init(id3, icon: icon3, inn: "1", title: "b", segment: "1"),
                .init(id2, icon: icon2, inn: "2", title: "a", segment: "1"),
            ]),
            .init(title: "2", providers: [
                .init(id1, icon: icon1, inn: inn1, title: title1, segment: "2")
            ]),
        ])
    }
    
    func test_initWithProviders_shouldHandleNilINN() {
        
        let (id1, icon1, title1) = (anyMessage(), anyMessage(), anyMessage())
        let (id2, icon2, title2) = (anyMessage(), anyMessage(), anyMessage())
        let segment = anyMessage()
        
        XCTAssertNoDiff(Segments(with: [
            .init(id1, icon: icon1, inn: nil, title: title1, segment: segment),
            .init(id2, icon: icon2, inn: nil, title: title2, segment: segment)
        ], providerKeyPath: \.inn), [
            .init(title: segment, providers: [
                .init(id1, icon: icon1, inn: nil, title: title1, segment: segment),
                .init(id2, icon: icon2, inn: nil, title: title2, segment: segment),
            ])
        ])
    }
    
    // MARK: - Helpers
    
    private typealias Providers = [SegmentedPaymentProvider]
    private typealias Segments = [PaymentProviderSegment<SegmentedPaymentProvider>]
}

private extension SegmentedPaymentProvider {
    
    init(
        _ id: String,
        icon: String?,
        inn: String?,
        title: String,
        segment: String
    ) {
        self.init(
            id: id,
            icon: icon,
            inn: inn,
            title: title,
            segment: segment
        )
    }
}
