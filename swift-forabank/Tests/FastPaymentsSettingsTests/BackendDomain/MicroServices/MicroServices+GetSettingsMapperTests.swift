////
////  MicroServices+GetSettingsMapperTests.swift
////
////
////  Created by Igor Malyarov on 26.01.2024.
////
//
//extension MicroServices.GetSettings
//where Contract == UserPaymentSettings.PaymentContract,
//      Consent == ConsentListState,
//      Settings == UserPaymentSettings {
//    
//    convenience init(
//        getContract: @escaping GetContract,
//        getConsent: @escaping GetConsent,
//        getBankDefault: @escaping GetBankDefault,
//        mapper: MicroServices.GetSettingsMapper
//    ) {
//        self.init(
//            getContract: getContract,
//            getConsent: getConsent,
//            getBankDefault: getBankDefault,
//            mapToMissing: { .success(.missingContract($0)) },
//            mapToSettings: mapper.mapToSettings
//        )
//    }
//}
//
//public extension MicroServices {
//    
//    final class GetSettingsMapper {
//        
//        func mapToSettings(
//            paymentContract: UserPaymentSettings.PaymentContract,
//            consentList: ConsentListState,
//            bankDefault: GetBankDefaultResponse
//        ) -> UserPaymentSettings {
//            
//            switch bankDefault.requestLimitMessage {
//            case let .some(message):
//                
//            }
//            let details = UserPaymentSettings.ContractDetails(
//                paymentContract: <#T##UserPaymentSettings.PaymentContract#>,
//                consentList: <#T##ConsentListState#>,
//                bankDefault: <#T##UserPaymentSettings.BankDefault#>,
//                productSelector: <#T##UserPaymentSettings.ProductSelector#>
//            )
//            
//            return .success(.contracted(details))
//        }
//    }
//}
//
//import FastPaymentsSettings
//import XCTest
//
//final class MicroServices_GetSettingsMapperTests: XCTestCase {
//    
//    // MARK: - Helpers
//    
//    private typealias SUT = MicroServices.GetSettingsMapper
//    
//    private func makeSUT(
//        file: StaticString = #file,
//        line: UInt = #line
//    ) -> SUT {
//        
//        let sut = SUT()
//        
//        trackForMemoryLeaks(sut, file: file, line: line)
//        
//        return sut
//    }
//}
