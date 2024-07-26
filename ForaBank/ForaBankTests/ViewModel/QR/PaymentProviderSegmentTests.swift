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
            .init(id: id, icon: icon, title: title, inn: inn, segment: segment)
        ], sortingProvidersByKeyPath: \.title), [
            .init(title: segment, providers: [
                .init(id: id, icon: icon, title: title, inn: inn)
            ])
        ])
    }
    
    func test_initWithProviders_shouldCreateWithTwoInSameSegment() {
        
        let segment = anyMessage()
        let (id1, icon1, inn1) = (anyMessage(), anyMessage(), anyMessage())
        let (id2, icon2, inn2) = (anyMessage(), anyMessage(), anyMessage())
        
        XCTAssertNoDiff(Segments(with: [
            .init(id: id1, icon: icon1, title: "b", inn: inn1, segment: segment),
            .init(id: id2, icon: icon2, title: "a", inn: inn2, segment: segment)
        ], sortingProvidersByKeyPath: \.title), [
            .init(title: segment, providers: [
                .init(id: id2, icon: icon2, title: "a", inn: inn2),
                .init(id: id1, icon: icon1, title: "b", inn: inn1),
            ])
        ])
    }
    
    func test_initWithProviders_shouldCreateWithTwoInDifferentSegments() {
        
        let (id1, icon1, title1, inn1) = (anyMessage(), anyMessage(), anyMessage(), anyMessage())
        let (id2, icon2, title2, inn2) = (anyMessage(), anyMessage(), anyMessage(), anyMessage())
        
        XCTAssertNoDiff(Segments(with: [
            .init(id: id1, icon: icon1, title: title1, inn: inn1, segment: "a"),
            .init(id: id2, icon: icon2, title: title2, inn: inn2, segment: "b")
        ], sortingProvidersByKeyPath: \.title), [
            .init(title: "a", providers: [
                .init(id: id1, icon: icon1, title: title1, inn: inn1)
            ]),
            .init(title: "b", providers: [
                .init(id: id2, icon: icon2, title: title2, inn: inn2)
            ])
        ])
    }
    
    func test_initWithProviders_shouldCreateWithDifferentSegmentsSortedBySegmentAndINN() {
        
        let (id1, icon1, title1, inn1) = (anyMessage(), anyMessage(), anyMessage(), anyMessage())
        let (id2, icon2) = (anyMessage(), anyMessage())
        let (id3, icon3) = (anyMessage(), anyMessage())
        
        XCTAssertNoDiff(Segments(with: [
            .init(id: id1, icon: icon1, title: title1, inn: inn1, segment: "2"),
            .init(id: id2, icon: icon2, title: "a", inn: "2", segment: "1"),
            .init(id: id3, icon: icon3, title: "b", inn: "1", segment: "1")
        ], sortingProvidersByKeyPath: \.inn), [
            .init(title: "1", providers: [
                .init(id: id3, icon: icon3, title: "b", inn: "1"),
                .init(id: id2, icon: icon2, title: "a", inn: "2"),
            ]),
            .init(title: "2", providers: [
                .init(id: id1, icon: icon1, title: title1, inn: inn1)
            ]),
        ])
    }
    
    func test_initWithProviders_shouldHandleNilINN() {
        
        let (id1, icon1, title1) = (anyMessage(), anyMessage(), anyMessage())
        let (id2, icon2, title2) = (anyMessage(), anyMessage(), anyMessage())
        let segment = anyMessage()
        
        XCTAssertNoDiff(Segments(with: [
            .init(id: id1, icon: icon1, title: title1, inn: nil, segment: segment),
            .init(id: id2, icon: icon2, title: title2, inn: nil, segment: segment)
        ], sortingProvidersByKeyPath: \.inn), [
            .init(title: segment, providers: [
                .init(id: id1, icon: icon1, title: title1, inn: nil),
                .init(id: id2, icon: icon2, title: title2, inn: nil),
            ])
        ])
    }
    
    // MARK: - Helpers
    
    private typealias Providers = [SegmentedPaymentProvider]
    private typealias Segments = [PaymentProviderSegment]
}
