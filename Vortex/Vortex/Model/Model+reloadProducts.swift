//
//  Model+reloadProducts.swift
//  ForaBank
//
//  Created by Andryusina Nataly on 19.06.2024.
//

import Foundation

extension Model {
    
    func reloadProducts(
        productTo: ProductData,
        productFrom: ProductData,
        _ timeIntervalInSeconds: Int = 1,
        _ queue: DispatchQueue = DispatchQueue.global()
    ) {
        if productTo.productType == productFrom.productType {
            reloadProduct(productType: productTo.productType, timeIntervalInSeconds, queue)
        } else {
            reloadProduct(productType: productTo.productType, timeIntervalInSeconds, queue)
            reloadProduct(productType: productFrom.productType, 2 * timeIntervalInSeconds, queue)
        }
    }
    
    func reloadProduct(
        productType: ProductType,
        _ timeIntervalInSeconds: Int,
        _ queue: DispatchQueue = DispatchQueue.global()
    ) {
        queue.delay(
            for: .seconds(timeIntervalInSeconds),
            execute: { self.handleProductsUpdateTotalProduct(.init(productType: productType))})
    }
}
