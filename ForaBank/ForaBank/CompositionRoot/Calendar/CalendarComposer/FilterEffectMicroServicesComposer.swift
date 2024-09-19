//
//  FilterEffectMicroServicesComposer.swift
//  ForaBank
//
//  Created by Дмитрий Савушкин on 19.09.2024.
//

import Foundation
import CalendarUI
import Combine

final class FilterEffectHandlerMicroServicesComposer {
    
    private let model: Model
    private var cancellable: AnyCancellable?
    typealias MicroServices = FilterModelEffectHandlerMicroServices
    
    init(
        model: Model
    ) {
        self.model = model
    }
    
    func compose() -> MicroServices {
        
        .init(updateFilter: updateFilter)
    }
}

private extension FilterEffectHandlerMicroServicesComposer {
    
    func updateFilter(
        payload: FilterEffect.UpdateFilterPayload,
        completion: @escaping (FilterState?) -> Void
    ) {
        
        guard let productId = payload.productId else {
            return completion(nil)
        }
        
        model.handleStatementRequest(.init(
            productId: productId,
            direction: .custom(
                start: payload.range.lowerBound,
                end: payload.range.upperBound
            ),
            operationType: nil,
            category: nil
        ))
        
        cancellable = model.statements
            .dropFirst()
            .sink { statements in
            
            if let statements = statements[productId] {
                
                let filteredStatements = statements.statements.filter({
                    payload.range.contains($0.tranDate ?? $0.date)
                })
                
                completion(.init(
                    productId: productId,
                    range: payload.range,
                    statements: filteredStatements
                ))
                
            } else {
                
                completion(nil)
            }
        }
    }
}

private extension FilterState {
    
    init(
        productId: ProductData.ID,
        range: Range<Date>,
        statements: [ProductStatementData]
    ) {
        
        self.init(
            productId: productId,
            calendar: .init(
                date: Date(),
                range: .init(),
                monthsData: [],
                periods: [.week, .month, .dates]
            ),
            filter: .init(
                title: "",
                selectDates: ((lowerDate: range.lowerBound, upperDate: range.upperBound)),
                periods: [.week, .month, .dates],
                transactionType: [.credit, .debit],
                services: statements.map(\.groupName)
            )
        )
    }
}
