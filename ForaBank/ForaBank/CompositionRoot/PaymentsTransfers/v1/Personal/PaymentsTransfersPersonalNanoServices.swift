//
//  PaymentsTransfersPersonalNanoServices.swift
//  ForaBank
//
//  Created by Igor Malyarov on 20.09.2024.
//

import PayHubUI

struct PaymentsTransfersPersonalNanoServices {
    
    let loadCategories: LoadCategories
    let loadAllLatest: LoadAllLatest
    let loadLatestForCategory: LoadLatestForCategory
    let loadOperatorsForCategory: LoadOperatorsForCategory
}

extension PaymentsTransfersPersonalNanoServices {
    
    typealias LoadCategoriesCompletion = ([CategoryPickerSectionItem<ServiceCategory>]) -> Void
    typealias LoadCategories = (@escaping LoadCategoriesCompletion) -> Void
    
    typealias LoadLatestCompletion = (Result<[Latest], Error>) -> Void
    typealias LoadAllLatest = (@escaping LoadLatestCompletion) -> Void
    typealias LoadLatestForCategory = (ServiceCategory, @escaping LoadLatestCompletion) -> Void
    
    typealias Operator = PaymentServiceOperator
    typealias LoadOperatorsCompletion = (Result<[Operator], Error>) -> Void
    typealias LoadOperatorsForCategory = (ServiceCategory, @escaping LoadOperatorsCompletion) -> Void
}

struct PaymentServiceOperator: Equatable, Identifiable {
    
    let id: String
    let inn: String
    let md5Hash: String?
    let name: String
    let type: String
}

#warning("move to call site")
extension PaymentServiceOperator {
    
    init(codable: CodableServicePaymentOperator) {
        
        self.init(
            id: codable.id,
            inn: codable.inn,
            md5Hash: codable.md5Hash,
            name: codable.name,
            type: codable.type
        )
    }
}
