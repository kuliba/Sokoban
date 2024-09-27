//
//  RootViewModelFactory+makePaymentsTransfersPersonal.swift
//  ForaBank
//
//  Created by Igor Malyarov on 20.09.2024.
//

import CombineSchedulers
import Foundation
import PayHub
import PayHubUI

extension RootViewModelFactory {
    
    static func makePaymentsTransfersPersonal(
        model: Model,
        categoryPickerPlaceholderCount: Int,
        operationPickerPlaceholderCount: Int,
        nanoServices: PaymentsTransfersPersonalNanoServices,
        pageSize: Int = 50,
        mainScheduler: AnySchedulerOf<DispatchQueue>,
        backgroundScheduler: AnySchedulerOf<DispatchQueue>
    ) -> PaymentsTransfersPersonal {
        
        // MARK: - CategoryPicker
        
        let microServicesComposer = UtilityPrepaymentMicroServicesComposer(
            pageSize: pageSize,
            nanoServices: .init(loadOperators: { payload, completion in
                
#warning("inject this")
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
            scheduler: mainScheduler
        )
        let categoryPickerComposer = CategoryPickerSection.BinderComposer(
            load: nanoServices.loadCategories,
            microServices: .init(
                showAll: { $1(CategoryListModelStub(categories: $0)) },
                showCategory: selectCategory(
                    model: model,
                    composer: standardNanoServicesComposer,
                    scheduler: mainScheduler
                )
            ),
            placeholderCount: categoryPickerPlaceholderCount,
            scheduler: mainScheduler
        )
        let categoryPicker = categoryPickerComposer.compose(
            prefix: [],
            suffix: (0..<6).map { _ in .placeholder(.init()) }
        )
        
        // MARK: - OperationPicker
        
        let operationPickerContentComposer = LoadablePickerModelComposer<UUID, OperationPickerElement>(
            load: { completion in
                
                nanoServices.loadAllLatest {
                    
                    completion(((try? $0.get()) ?? []).map { .latest($0) })
                }
            },
            scheduler: mainScheduler
        )
        let operationPickerContent = operationPickerContentComposer.compose(
            prefix: [
                .element(.init(.templates)),
                .element(.init(.exchange))
            ],
            suffix: [],
            placeholderCount: operationPickerPlaceholderCount
        )
        let operationPickerFlowComposer = OperationPickerFlowComposer(
            model: model,
            scheduler: mainScheduler
        )
        let operationPickerFlow = operationPickerFlowComposer.compose()
        let operationPicker = OperationPickerBinder(
            content: operationPickerContent,
            flow: operationPickerFlow,
            bind: { content, flow in
                
                content.$state
                    .compactMap(\.selected)
                    .sink { flow.event(.select($0)) }
            }
        )
        
        // MARK: - Toolbar
        
        let toolbarComposer = PaymentsTransfersPersonalToolbarBinderComposer(
            microServices: .init(
                makeProfile: { $0(ProfileModelStub()) },
                makeQR: { $0(QRModelStub()) }
            ),
            scheduler: mainScheduler
        )
        let toolbar = toolbarComposer.compose()
        
        // MARK: - PaymentsTransfers
        
        let content = PaymentsTransfersPersonalContent(
            categoryPicker: categoryPicker,
            operationPicker: operationPicker,
            toolbar: toolbar,
            reload: {
                
                categoryPicker.content.event(.load)
                operationPicker.content.event(.load)
            }
        )
        
        let reducer = PayHub.PaymentsTransfersPersonalFlowReducer()
        let effectHandler = PayHub.PaymentsTransfersPersonalFlowEffectHandler(
            microServices: .init()
        )
        let flow = PaymentsTransfersPersonalFlow(
            initialState: .init(),
            reduce: reducer.reduce(_:_:),
            handleEffect: effectHandler.handleEffect(_:_:),
            scheduler: mainScheduler
        )
        
        return .init(content: content, flow: flow, bind: { _,_ in [] })
    }
    
    private static func selectCategory(
        model: Model,
        composer: StandardSelectedCategoryDestinationNanoServicesComposer,
        scheduler: AnySchedulerOf<DispatchQueue>
    ) -> (
        ServiceCategory, @escaping (Result<SelectedCategoryDestination, SelectedCategoryFailure>) -> Void
    ) -> Void {
        
        return { category, completion in
            
            let standardNanoServices = composer.compose(category: category)
            let composer = PaymentFlowMicroServiceComposerNanoServicesComposer(
                model: model,
                standardNanoServices: standardNanoServices,
                scheduler: scheduler
            )
            let nanoServices = composer.compose(category: category)
            let paymentFlowComposer = PaymentFlowMicroServiceComposer(
                nanoServices: nanoServices
            )
            let microService = paymentFlowComposer.compose()
            
            microService.makePaymentFlow(category.paymentFlowID, completion)
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

#warning("move to call site")
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
