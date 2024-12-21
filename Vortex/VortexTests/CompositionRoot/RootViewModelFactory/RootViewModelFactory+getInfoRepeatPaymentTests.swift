//
//  RootViewModelFactory+getInfoRepeatPaymentTests.swift
//  VortexTests
//
//  Created by Igor Malyarov on 21.12.2024.
//

import GetInfoRepeatPaymentService

extension GetInfoRepeatPaymentDomain {
    
    enum Navigation {
        
        case meToMe(PaymentsMeToMeViewModel)
    }
}

extension RootViewModelFactory {
    
    func getInfoRepeatPayment(
        from info: GetInfoRepeatPaymentDomain.GetInfoRepeatPayment
    ) -> GetInfoRepeatPaymentDomain.Navigation? {
        
        return makeMeToMe(from: info).map { .meToMe($0) }
    }
    
    func makeMeToMe(
        from info: GetInfoRepeatPaymentDomain.GetInfoRepeatPayment
    ) -> PaymentsMeToMeViewModel? {
        
        return nil
    }
}

@testable import Vortex
import XCTest

final class RootViewModelFactory_getInfoRepeatPaymentTests: RootViewModelFactoryTests {
    
    // MARK: - meToMe
    
    func test_meToMe_shouldDeliverNilOnNonBetweenTheirType() {
        
        for type in allTransferTypes(except: .betweenTheir) {
            
            let info = makeRepeat(type: type)
            let sut = makeSUT().sut
            
            XCTAssertNil(sut.makeMeToMe(from: info))
        }
    }
    
    // MARK: - Helpers
    
    private typealias TransferType = GetInfoRepeatPaymentDomain.GetInfoRepeatPayment.TransferType
    private typealias Repeat = GetInfoRepeatPaymentDomain.GetInfoRepeatPayment
    
    private func allTransferTypes(
        except excludingType: TransferType
    ) -> [TransferType] {
        
        return TransferType.allCases.filter { $0 != excludingType }
    }
    
    private func makeRepeat(
        type: TransferType,
        parameterList: [Repeat.Transfer] = [],
        productTemplate: Repeat.ProductTemplate? = nil
    ) -> Repeat {
        
        return .init(type: type, parameterList: parameterList, productTemplate: productTemplate)
    }
}
