//
//  RootViewModelFactory+makeCategoryPickerSection.swift
//  ForaBank
//
//  Created by Igor Malyarov on 01.10.2024.
//

import CombineSchedulers
import Foundation
import PayHub

extension RootViewModelFactory {
    
    static func makeCategoryPickerSection(
        model: Model,
        nanoServices: PaymentsTransfersPersonalNanoServices,
        pageSize: Int,
        placeholderCount: Int,
        scheduler: AnySchedulerOf<DispatchQueue>
    ) -> CategoryPickerSection.Binder{
        
        let microServicesComposer = UtilityPrepaymentMicroServicesComposer(
            pageSize: pageSize,
            nanoServices: .init(loadOperators: { payload, completion in
                
#warning("inject this?")
                DispatchQueue.global(qos: .userInitiated).async {
                    
                    model.loadOperators(payload, completion)
                }
            })
        )
        let standardNanoServicesComposer = StandardSelectedCategoryDestinationNanoServicesComposer(
            loadLatest: nanoServices.loadLatestForCategory,
            loadOperators: { category, completion in
                
                model.loadOperators(.init(
                    afterOperatorID: nil,
                    for: category.type,
                    searchText: "",
                    pageSize: pageSize
                )) {
                    completion(.success($0))
                }
            },
            makeMicroServices: microServicesComposer.compose,
            model: model,
            scheduler: scheduler
        )
        
        let selectCategory = selectCategory(
            model: model,
            composer: standardNanoServicesComposer,
            scheduler: scheduler
        )
        let categoryPickerComposer = CategoryPickerSection.BinderComposer(
            load: nanoServices.loadCategories,
            microServices: .init(
                getNavigation: { payload, completion in
                    
                    switch payload {
                    case let .category(category):
                        selectCategory(category, completion)
                        
                    case let .list(list):
                        completion(.list(.init(categories: list)))
                    }
                }
            ),
            placeholderCount: placeholderCount,
            scheduler: scheduler
        )
        
        return categoryPickerComposer.compose(
            prefix: [],
            suffix: (0..<placeholderCount).map { _ in .placeholder(.init()) }
        )
    }
    
    private static func selectCategory(
        model: Model,
        composer: StandardSelectedCategoryDestinationNanoServicesComposer,
        scheduler: AnySchedulerOf<DispatchQueue>
    ) -> (
        ServiceCategory, @escaping (CategoryPickerSectionNavigation) -> Void
    ) -> Void {
        
        return { category, completion in
            
            let standardNanoServices = composer.compose(category: category)
            let composer = PaymentFlowMicroServiceComposerNanoServicesComposer(
                model: model,
                makeQR: RootViewModelFactory.makeMakeQRScannerModel(
                    model: model,
                    qrResolverFeatureFlag: .init(.active),
                    utilitiesPaymentsFlag: .init(.active(.live)),
                    scheduler: scheduler
                ),
                standardNanoServices: standardNanoServices,
                scheduler: scheduler
            )
            let nanoServices = composer.compose(category: category)
            let paymentFlowComposer = PaymentFlowMicroServiceComposer(
                nanoServices: nanoServices
            )
            let microService = paymentFlowComposer.compose()
            
            microService.makePaymentFlow(category.paymentFlowID) {
                
                switch $0 {
                case let .failure(failure):
                    completion(.failure(failure))
                    
                case let .success(flow):
                    completion(.paymentFlow(flow))
                }
            }
        }
    }
}

private extension ServiceCategory {
    
    var paymentFlowID: PaymentFlowID {
        
        switch paymentFlow {
        case .mobile:              return .mobile
        case .qr:                  return .qr
        case .standard:            return .standard
        case .taxAndStateServices: return .taxAndStateServices
        case .transport:           return .transport
        }
    }
}

// MARK: - Helpers

#warning("duplication - see UtilityPaymentOperatorLoaderComposer")

private extension Model {
    
    func loadOperators(
        _ payload: UtilityPrepaymentNanoServices<PaymentServiceOperator>.LoadOperatorsPayload,
        _ completion: @escaping LoadOperatorsCompletion
    ) {
        let log = LoggerAgent().log
        let cacheLog = { log(.debug, .cache, $0, $1, $2) }
        
        if let operators = localAgent.load(type: [CodableServicePaymentOperator].self) {
            cacheLog("Total Operators count \(operators.count)", #file, #line)
            
            let page = operators.operators(for: payload)
            cacheLog("Operators page count \(page.count) for \(payload.categoryType.name)", #file, #line)
            
            completion(page)
        } else {
            cacheLog("No more Operators", #file, #line)
            completion([])
        }
    }
    
    typealias LoadOperatorsCompletion = ([PaymentServiceOperator]) -> Void
}

// TODO: - add tests
extension Array where Element == CodableServicePaymentOperator {
    
    /// - Warning: expensive with sorting and search. Sorting is expected to happen at cache phase.
    func operators(
        for payload: UtilityPrepaymentNanoServices<PaymentServiceOperator>.LoadOperatorsPayload
    ) -> [PaymentServiceOperator] {
        
        // sorting is performed at cache phase
        return self
            .filter { $0.matches(payload) }
            .page(startingAfter: payload.operatorID, pageSize: payload.pageSize)
            .map(PaymentServiceOperator.init(codable:))
    }
}

// MARK: - Search

// TODO: - add tests
extension CodableServicePaymentOperator {
    
    func matches(
        _ payload: UtilityPrepaymentNanoServices<PaymentServiceOperator>.LoadOperatorsPayload
    ) -> Bool {
        
        type == payload.categoryType.name && contains(payload.searchText)
    }
    
    func contains(_ searchText: String) -> Bool {
        
        guard !searchText.isEmpty else { return true }
        
        return name.localizedCaseInsensitiveContains(searchText)
        || inn.localizedCaseInsensitiveContains(searchText)
    }
}

private extension PaymentServiceOperator {
    
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
