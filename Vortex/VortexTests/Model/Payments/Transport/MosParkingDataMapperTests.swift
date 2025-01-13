//
//  MosParkingDataMapperTests.swift
//  VortexTests
//
//  Created by Igor Malyarov on 21.06.2023.
//

@testable import Vortex
import PickerWithPreviewComponent
import XCTest

final class MosParkingDataMapperTests: XCTestCase {
    
    // MARK: - map
    
    func test_map_shouldThrowOnMissingRefill() {
        
        XCTAssertThrowsAsNSError(
            _ = try map(data: .nonMatching),
            error: MosParkingDataMapper.Error.missingRefillID
        )
    }
    
    func test_map_shouldSetRefillIDOnPresent() throws {
        
        let state = try map(data: .test)
        
        XCTAssertEqual(state.refillID, "56")
    }
    
    func test_map_shouldThrowOnEmptyData() {
        
        XCTAssertThrowsAsNSError(
            _ = try map(data: []),
            error: MosParkingDataMapper.Error.emptyData
        )
    }
    
    func test_map_shouldThrowOnNonMatchingSubscriptionTypes() {
        
        XCTAssertThrowsAsNSError(
            _ = try map(data: .nonMatching + [.refill]),
            error: MosParkingDataMapper.Error.nonSelectableSubscriptionType
        )
    }
    
    func test_map_shouldThrowOnMissingDefault() {
        
        XCTAssertThrowsAsNSError(
            _ = try map(data: .missingDefault),
            error: MosParkingDataMapper.Error.missingDefault
        )
    }
    
    func test_map_shouldReturnValues() throws {
        
        let (state, options, refillID) = try map(data: .test)
        
        XCTAssertNoDiff(state, .testYearly)
        XCTAssertNoDiff(options, .test)
        XCTAssertNoDiff(refillID, "56")
    }
    
    // MARK: - Helpers
    
    private func map(
        data: [MosParkingData]
    ) throws -> (
        state: PickerWithPreviewComponent.ComponentState,
        options: [SubscriptionType: [OptionWithMapImage]],
        refillID: String
    ) {
        
        try MosParkingDataMapper.map(data: data)
    }
}

extension Array where Element == MosParkingData {
    
    static let nonMatching: Self = [
        .nonMatching1,
        .nonMatching2
    ]
    static let missingDefault: Self = [
        .monthly,
        .yearly,
        .refill
    ]
}

extension MosParkingData {
    
    static let nonMatching1: Self = .test(groupName: "A", value: 20)
    static let nonMatching2: Self = .test(default: true, groupName: "A", value: 20)
    
    static let monthly: Self = .test(groupName: "Месячная", value: 21)
    static let yearly: Self = .test(groupName: "Годовая", value: 25)
    static let refill: Self = .test(groupName: "Пополнение", value: 56)
}

extension ComponentState {
    
    static let testMonthly: Self = .monthly(.testMonthly)
    static let testYearly: Self = .yearly(.testYearly)
}

extension ComponentState.SelectionWithOptions {
    
    static let testMonthly: Self = .init(
        selection: .monthly20,
        options: [.monthly20, .monthly21, .monthly22]
    )
    static let testYearly: Self = .init(
        selection: .yearly23,
        options: [.yearly23, .yearly24, .yearly25]
    )
}

extension Dictionary
where Key == SubscriptionType,
      Value == [OptionWithMapImage] {
    
    static let test: Self = [
        .monthly: [.monthly20, .monthly21, .monthly22],
        .yearly: [.yearly23, .yearly24, .yearly25]
    ]
}

extension OptionWithMapImage {
    
    static let monthly20: Self = .test(20, "Месячная")
    static let monthly21: Self = .test(21, "Месячная")
    static let monthly22: Self = .test(22, "Месячная")
    
    static let yearly23: Self = .test(23, "Годовая")
    static let yearly24: Self = .test(24, "Годовая")
    static let yearly25: Self = .test(25, "Годовая")
    
    private static func test(
        _ id: Int,
        value: String? = nil,
        mapImage: MapImage = .placeholder,
        _ title: String
    ) -> Self {
        
        .init(
            id: id,
            value: value ?? "\(id)",
            mapImage: mapImage,
            title: "\(title)-\(id)"
        )
    }
}
