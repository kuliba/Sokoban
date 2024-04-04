//
//  ButtonFactory.swift
//  ForaBank
//
//  Created by Andryusina Nataly on 04.04.2024.
//

import Foundation


struct ButtonFactory {
    
    let makeTestButtonViewModel: MakeTestButtonViewModel
}

extension ButtonFactory {
    
    typealias MakeTestButtonViewModel = (ProductData.ID) -> TestButtonViewModel
}

struct TestButtonViewModel {
    
    let productID: ProductData.ID
    let title: String
}
