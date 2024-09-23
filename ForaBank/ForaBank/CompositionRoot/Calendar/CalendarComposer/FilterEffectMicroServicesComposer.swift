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
        
        .init(
            resetPeriod: resetPeriod,
            updateFilter: updateFilter
        )
    }
}

private extension FilterEffectHandlerMicroServicesComposer {
    
    func resetPeriod(
        productId: ProductData.ID,
        completion: @escaping MicroServices.ResetPeriodCompletion
    ) {
        DispatchQueue.global(qos: .background).async { [model] in
            
            guard let period = model.statements.value[productId]?.period
            else {
                return completion(model.calendarDayStart(productId)..<Date())
            }
            
            let range = period.start..<period.end
            completion(range)
        }
    }
            
    func updateFilter(
        payload: FilterEffect.UpdateFilterPayload,
        completion: @escaping MicroServices.UpdateFilterCompletion
    ) {
        model.handleStatementRequest(.init(
            productId: payload.productId,
            direction: .custom(
                start: payload.range.lowerBound,
                end: payload.range.upperBound
            ),
            operationType: nil,
            category: nil
        ))
        
        cancellable = model.statementsUpdating
            .dropFirst()
            .debounce(for: 0.3, scheduler: DispatchQueue.global(qos: .userInitiated))
            .compactMap { $0[payload.productId ] }
            .sink { state in
                
                self.handleStatementResult(payload, state, completion)
            }
    }
    
    private func handleStatementResult(
        _ payload: FilterEffect.UpdateFilterPayload,
        _ state: ProductStatementsUpdateState?,
        _ completion: @escaping (FilterState?) -> Void
    ) {
        
        switch state {
        case .none, .downloading:
            break
            
        case .failed:
            completion(nil)
            
        case .idle:
            if let product = model.product(productId: payload.productId),
               let statements = model.statements.value[payload.productId] {
                
                let filteredStatements = statements.statements.filter({
                    payload.range.contains($0.date)
                })
                
                completion(.init(
                    product: product,
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
        product: ProductData,
        range: Range<Date>,
        statements: [ProductStatementData]
    ) {
        let services = Array(Set(statements.compactMap { $0.groupName }))
        self.init(
            productId: product.id,
            calendar: .init(
                date: Date(),
                range: .init(range: range),
                monthsData: .generate(startDate: product.openDate),
                periods: [.week, .month, .dates]
            ),
            filter: .init(
                title: "Фильтры",
                selectDates: range,
                periods: [.week, .month, .dates],
                transactionType: [.credit, .debit],
                services: services
            ),
            status: services.isEmpty ? .empty : .normal
        )
    }
}
