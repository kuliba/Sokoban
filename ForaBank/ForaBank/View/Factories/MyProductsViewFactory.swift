//
//  MyProductsViewFactory.swift
//  ForaBank
//
//  Created by Andryusina Nataly on 30.05.2024.
//

import Foundation

struct MyProductsViewFactory {
    
    let makeInformerDataUpdateFailure: MakeInformerDataUpdateFailure
}

typealias MakeInformerDataUpdateFailure = () -> InformerData?
