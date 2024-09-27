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
        DispatchQueue
            .global(qos: .userInitiated)
            .asyncAfter(deadline: .now() + .milliseconds(100)) {
                
                guard let period = self.model.statements.value[productId]?.period
                else {
                    return completion(self.model.calendarDayStart(productId)..<Date())
                }
                
                completion(period.range)
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
            .compactMap { $0[payload.productId] }
            .filter { !$0.isDownloadActive }
            .flatMap { result in
                
                switch result {
                case .downloading, .failed:
                    return Just(ProductStatementsStorage?.none).eraseToAnyPublisher()

                case .idle:
                    return self.model.statements
                        .throttle(for: .milliseconds(300), 
                                  scheduler: DispatchQueue.main,
                                  latest: true)
                        .compactMap { $0[payload.productId] }
                        .eraseToAnyPublisher()
                }
            }
            .sink { (state: ProductStatementsStorage?) in
                
                self.handleStatementResult(payload, state, completion)
            }
    }
    
    private func handleStatementResult(
        _ payload: FilterEffect.UpdateFilterPayload,
        _ storage: ProductStatementsStorage?,
        _ completion: @escaping (FilterState?) -> Void
    ) {
        guard let storage,
              !storage.statements.isEmpty,
              let product = model.product(productId: payload.productId)
        else { return completion(nil) }
        
        let filteredStatements = storage.statements.filter {
            payload.range.contains($0.date)
        }
        
        completion(.init(
            product: product,
            range: payload.range,
            selectedPeriod: payload.selectPeriod,
            statements: filteredStatements
        ))
    }
}

private extension FilterState {
    
    init(
        product: ProductData,
        range: Range<Date>,
        selectedPeriod: FilterHistoryState.Period,
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
                selectedPeriod: selectedPeriod,
                periods: [.week, .month, .dates],
                transactionType: [.credit, .debit],
                services: services
            ),
            status: services.isEmpty ? .empty : .normal
        )
    }
}
