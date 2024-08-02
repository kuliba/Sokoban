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
            .init(id, icon: icon, inn: inn, title: title, segment: segment, sortedOrder: 1)
        ]), [
            .init(title: segment, providers: [
                .init(id, icon: icon, inn: inn, title: title, segment: segment, sortedOrder: 1)
            ])
        ])
    }
    
    func test_initWithProviders_shouldCreateWithTwoInSameSegment() {
        
        let segment = anyMessage()
        let (id1, icon1, inn1) = (anyMessage(), anyMessage(), anyMessage())
        let (id2, icon2, inn2) = (anyMessage(), anyMessage(), anyMessage())
        
        XCTAssertNoDiff(Segments(with: [
            .init(id1, icon: icon1, inn: inn1, title: "b", segment: segment, sortedOrder: 1),
            .init(id2, icon: icon2, inn: inn2, title: "a", segment: segment, sortedOrder: 2)
        ]), [
            .init(title: segment, providers: [
                .init(id2, icon: icon2, inn: inn2, title: "a", segment: segment, sortedOrder: 2),
                .init(id1, icon: icon1, inn: inn1, title: "b", segment: segment, sortedOrder: 1),
            ])
        ])
    }
    
    func test_initWithProviders_shouldCreateWithTwoInDifferentSegments() {
        
        let (id1, icon1, title1, inn1) = (anyMessage(), anyMessage(), anyMessage(), anyMessage())
        let (id2, icon2, title2, inn2) = (anyMessage(), anyMessage(), anyMessage(), anyMessage())
        
        XCTAssertNoDiff(Segments(with: [
            .init(id2, icon: icon2, inn: inn2, title: title2, segment: "b", sortedOrder: 1),
            .init(id1, icon: icon1, inn: inn1, title: title1, segment: "a", sortedOrder: 2),
        ]), [
            .init(title: "a", providers: [
                .init(id1, icon: icon1, inn: inn1, title: title1, segment: "a", sortedOrder: 2)
            ]),
            .init(title: "b", providers: [
                .init(id2, icon: icon2, inn: inn2, title: title2, segment: "b", sortedOrder: 1)
            ])
        ])
    }
    
    func test_initWithProviders_shouldCreateWithDifferentSegmentsSortedBySegmentAndINN() {
        
        let (id1, icon1, title1, inn1) = (anyMessage(), anyMessage(), anyMessage(), anyMessage())
        let (id2, icon2) = (anyMessage(), anyMessage())
        let (id3, icon3) = (anyMessage(), anyMessage())
        
        XCTAssertNoDiff(Segments(with: [
            .init(id1, icon: icon1, inn: inn1, title: title1, segment: "2", sortedOrder: 1),
            .init(id2, icon: icon2, inn: "2", title: "a", segment: "1", sortedOrder: 2),
            .init(id3, icon: icon3, inn: "1", title: "b", segment: "1", sortedOrder: 3)
        ], providerKeyPath: \.inn), [
            .init(title: "1", providers: [
                .init(id3, icon: icon3, inn: "1", title: "b", segment: "1", sortedOrder: 3),
                .init(id2, icon: icon2, inn: "2", title: "a", segment: "1", sortedOrder: 2),
            ]),
            .init(title: "2", providers: [
                .init(id1, icon: icon1, inn: inn1, title: title1, segment: "2", sortedOrder: 1)
            ]),
        ])
    }
    
    func test_initWithProviders_shouldHandleNilINN() {
        
        let (id1, icon1, title1) = (anyMessage(), anyMessage(), anyMessage())
        let (id2, icon2, title2) = (anyMessage(), anyMessage(), anyMessage())
        let segment = anyMessage()
        
        XCTAssertNoDiff(Segments(with: [
            .init(id1, icon: icon1, inn: nil, title: title1, segment: segment, sortedOrder: 1),
            .init(id2, icon: icon2, inn: nil, title: title2, segment: segment, sortedOrder: 2)
        ], providerKeyPath: \.inn), [
            .init(title: segment, providers: [
                .init(id1, icon: icon1, inn: nil, title: title1, segment: segment, sortedOrder: 1),
                .init(id2, icon: icon2, inn: nil, title: title2, segment: segment, sortedOrder: 2),
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
        segment: String,
        sortedOrder: Int
    ) {
        self.init(
            id: id,
            icon: icon,
            inn: inn,
            title: title,
            segment: segment,
            origin: .provider(.init(
                id: id,
                inn: inn ?? "",
                md5Hash: icon,
                title: title,
                sortedOrder: sortedOrder
            ))
        )
    }
}
