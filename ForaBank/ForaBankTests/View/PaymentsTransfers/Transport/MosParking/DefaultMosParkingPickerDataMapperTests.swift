//
//  DefaultMosParkingPickerDataMapperTests.swift
//  VortexTests
//
//  Created by Igor Malyarov on 26.06.2023.
//

@testable import ForaBank
import XCTest

final class DefaultMosParkingPickerDataMapperTests: XCTestCase {
    
    func test_map_shouldReturnMosParkingPickerViewModel() {
        
        let sut = makeSUT()
        let data: MosParkingPickerData = .testMonthly
        
        let viewModel = sut.map(data)
        
        XCTAssertNoDiff(viewModel.state, .testMonthly)
    }
    
    // MARK: - Helpers
    
    private func makeSUT(
        select: @escaping (MosParkingPicker.ViewModel.ID) -> Void = { _ in }
    ) -> MosParkingPickerDataMapper {
        
        DefaultMosParkingPickerDataMapper { _ in }
    }
}

private extension MosParkingPickerData {
    
    static let testMonthly: Self = .init(
        state: .testMonthly,
        options: .test,
        refillID: "56"
    )
}
