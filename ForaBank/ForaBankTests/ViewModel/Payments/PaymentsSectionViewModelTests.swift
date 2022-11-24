//
//  PaymentsSectionViewModelTests.swift
//  ForaBankTests
//
//  Created by Max Gribov on 28.10.2022.
//

import XCTest
@testable import ForaBank

class PaymentsSectionViewModelTests: XCTestCase {}


extension PaymentsSectionViewModelTests {
    
    func testReduceOperation_Feed_All_Visible() throws {
        
        // given
        let paramOne = Payments.ParameterMock(id: "one", value: nil, placement: .feed)
        let paramTwo = Payments.ParameterMock(id: "two", value: nil, placement: .feed)
        let paramThree = Payments.ParameterMock(id: "three", value: nil, placement: .feed)

        let parameters = [paramOne, paramTwo, paramThree]
        let visible = parameters.map{ $0.id }
        let step = Payments.Operation.Step(parameters: parameters, front: .init(visible: visible, isCompleted: false), back: .init(stage: .local, required: [], processed: nil))
        let operation = Payments.Operation(service: .fms, source: nil, steps: [], visible: [])
        let operationUpdated = try operation.appending(step: step)
        
        // when
        let result = PaymentsSectionViewModel.reduce(operation: operationUpdated, model: .emptyMock)
        
        // then
        let feedSections = result.filter({ $0.placement == .feed })
        let feedSectionsItems = feedSections.flatMap{ $0.items }
        XCTAssertEqual(feedSections.count, 1)
        XCTAssertEqual(feedSectionsItems.count, 3)
        
        let spoilerSections = result.filter({ $0.placement == .spoiler })
        XCTAssertEqual(spoilerSections.count, 0)
        
        /// feed section
        XCTAssertEqual(result[0].placement, .feed)
        XCTAssertEqual(result[0].items[0].source.parameter, paramOne.parameter)
        XCTAssertEqual(result[0].items[1].source.parameter, paramTwo.parameter)
        XCTAssertEqual(result[0].items[2].source.parameter, paramThree.parameter)
    }
    
    func testReduceOperation_Feed_Visible_Partly() throws {
        
        // given
        let paramOne = Payments.ParameterMock(id: "one", value: nil, placement: .feed)
        let paramTwo = Payments.ParameterMock(id: "two", value: nil, placement: .feed)
        let paramThree = Payments.ParameterMock(id: "three", value: nil, placement: .feed)

        let parameters = [paramOne, paramTwo, paramThree]
        let visible = [paramOne.id, paramThree.id]
        let step = Payments.Operation.Step(parameters: parameters, front: .init(visible: visible, isCompleted: false), back: .init(stage: .local, required: [], processed: nil))
        let operation = Payments.Operation(service: .fms, source: nil, steps: [], visible: [])
        let operationUpdated = try operation.appending(step: step)
        
        // when
        let result = PaymentsSectionViewModel.reduce(operation: operationUpdated, model: .emptyMock)
        
        // then
        let feedSections = result.filter({ $0.placement == .feed })
        let feedSectionsItems = feedSections.flatMap{ $0.items }
        XCTAssertEqual(feedSections.count, 1)
        XCTAssertEqual(feedSectionsItems.count, 2)
        
        let spoilerSections = result.filter({ $0.placement == .spoiler })
        XCTAssertEqual(spoilerSections.count, 0)
        
        /// feed section
        XCTAssertEqual(result[0].placement, .feed)
        XCTAssertEqual(result[0].items[0].source.parameter, paramOne.parameter)
        XCTAssertEqual(result[0].items[1].source.parameter, paramThree.parameter)
    }
    
    func testReduceOperation_Feed_And_Spoiler() throws {
        
        // given
        let paramOne = Payments.ParameterMock(id: "one", value: nil, placement: .feed)
        let paramTwo = Payments.ParameterMock(id: "two", value: nil, placement: .feed)
        
        let paramThree = Payments.ParameterMock(id: "three", value: nil, placement: .spoiler)
        let paramFour = Payments.ParameterMock(id: "four", value: nil, placement: .spoiler)
        
        let paramFive = Payments.ParameterMock(id: "five", value: nil, placement: .feed)
        
        let parameters = [paramOne, paramTwo, paramThree, paramFour, paramFive]
        let visible = parameters.map{ $0.id }
        let step = Payments.Operation.Step(parameters: parameters, front: .init(visible: visible, isCompleted: false), back: .init(stage: .local, required: [], processed: nil))
        let operation = Payments.Operation(service: .fms, source: nil, steps: [], visible: [])
        let operationUpdated = try operation.appending(step: step)
        
        // when
        let result = PaymentsSectionViewModel.reduce(operation: operationUpdated, model: .emptyMock)
        
        // then
        let feedSections = result.filter({ $0.placement == .feed })
        let feedSectionsItems = feedSections.flatMap{ $0.items }
        XCTAssertEqual(feedSections.count, 2)
        XCTAssertEqual(feedSectionsItems.count, 3)
        
        let spoilerSections = result.filter({ $0.placement == .spoiler })
        let spoilerSectionsItems = spoilerSections.flatMap{ $0.items }
        XCTAssertEqual(spoilerSections.count, 1)
        // 2 items + button
        XCTAssertEqual(spoilerSectionsItems.count, 3)
        
        /// first feed section
        XCTAssertEqual(result[0].placement, .feed)
        XCTAssertEqual(result[0].items[0].source.parameter, paramOne.parameter)
        XCTAssertEqual(result[0].items[1].source.parameter, paramTwo.parameter)
        
        /// spoiler section
        XCTAssertEqual(result[1].placement, .spoiler)
        XCTAssertEqual(result[1].items[0].source.parameter, paramThree.parameter)
        XCTAssertEqual(result[1].items[1].source.parameter, paramFour.parameter)
        
        /// second feed section
        XCTAssertEqual(result[2].placement, .feed)
        XCTAssertEqual(result[2].items[0].source.parameter, paramFive.parameter)
    }
    
    func testReduceOperation_Feed_And_Spoiler_Mixed() throws {
        
        // given
        let paramOne = Payments.ParameterMock(id: "one", value: nil, placement: .feed)
        let paramTwo = Payments.ParameterMock(id: "two", value: nil, placement: .spoiler)
        let paramThree = Payments.ParameterMock(id: "three", value: nil, placement: .feed)
        let paramFour = Payments.ParameterMock(id: "four", value: nil, placement: .spoiler)
        let paramFive = Payments.ParameterMock(id: "five", value: nil, placement: .feed)
        
        let parameters = [paramOne, paramTwo, paramThree, paramFour, paramFive]
        let visible = parameters.map{ $0.id }
        let step = Payments.Operation.Step(parameters: parameters, front: .init(visible: visible, isCompleted: false), back: .init(stage: .local, required: [], processed: nil))
        let operation = Payments.Operation(service: .fms, source: nil, steps: [], visible: [])
        let operationUpdated = try operation.appending(step: step)
        
        // when
        let result = PaymentsSectionViewModel.reduce(operation: operationUpdated, model: .emptyMock)
        
        // then
        let feedSections = result.filter({ $0.placement == .feed })
        let feedSectionsItems = feedSections.flatMap{ $0.items }
        XCTAssertEqual(feedSections.count, 2)
        XCTAssertEqual(feedSectionsItems.count, 3)
        
        let spoilerSections = result.filter({ $0.placement == .spoiler })
        let spoilerSectionsItems = spoilerSections.flatMap{ $0.items }
        XCTAssertEqual(spoilerSections.count, 1)
        // 2 items + button
        XCTAssertEqual(spoilerSectionsItems.count, 3)
        
        /// first feed section
        XCTAssertEqual(result[0].placement, .feed)
        XCTAssertEqual(result[0].items[0].source.parameter, paramOne.parameter)
        XCTAssertEqual(result[0].items[1].source.parameter, paramThree.parameter)
        
        /// spoiler section
        XCTAssertEqual(result[1].placement, .spoiler)
        XCTAssertEqual(result[1].items[0].source.parameter, paramTwo.parameter)
        XCTAssertEqual(result[1].items[1].source.parameter, paramFour.parameter)
        
        /// second feed section
        XCTAssertEqual(result[2].placement, .feed)
        XCTAssertEqual(result[2].items[0].source.parameter, paramFive.parameter)
    }
}
