//
//  RootViewModelFactory+makePaymentsTransfersPersonal.swift
//  ForaBank
//
//  Created by Igor Malyarov on 20.08.2024.
//

import CombineSchedulers
import Foundation
import PayHub
import PayHubUI

struct PaymentsTransfersPersonalNanoServices {
    
    let loadCategories: LoadCategories
    let loadAllLatest: LoadAllLatest
    let loadLatestForCategory: LoadLatestForCategory
    let loadOperators: LoadOperators
}

extension PaymentsTransfersPersonalNanoServices {
    
    typealias LoadCategoriesCompletion = ([CategoryPickerSectionItem<ServiceCategory>]) -> Void
    typealias LoadCategories = (@escaping LoadCategoriesCompletion) -> Void
    
    typealias LoadAllLatestCompletion = (Result<[Latest], Error>) -> Void
    typealias LoadAllLatest = (@escaping LoadAllLatestCompletion) -> Void
    
    typealias LoadLatestForCategoryCompletion = (Result<[Latest], Error>) -> Void
    typealias LoadLatestForCategory = (ServiceCategory, @escaping LoadLatestForCategoryCompletion) -> Void
    
    typealias LoadOperatorsCompletion = (Result<[Operator], Error>) -> Void
    typealias LoadOperators = (ServiceCategory, @escaping LoadOperatorsCompletion) -> Void
}

extension RootViewModelFactory {
    
    typealias LoadLatestOperationsCompletion = (Result<[Latest], Error>) -> Void
    typealias LoadLatestOperations = (@escaping LoadLatestOperationsCompletion) -> Void
    
    typealias LoadServiceCategoriesCompletion = ([CategoryPickerSectionItem<ServiceCategory>]) -> Void
    typealias LoadServiceCategories = (@escaping LoadServiceCategoriesCompletion) -> Void
    
    static func makePaymentsTransfersPersonal(
        categoryPickerPlaceholderCount: Int,
        operationPickerPlaceholderCount: Int,
        nanoServices: PaymentsTransfersPersonalNanoServices,
        mainScheduler: AnySchedulerOf<DispatchQueue>,
        backgroundScheduler: AnySchedulerOf<DispatchQueue>
    ) -> PaymentsTransfersPersonal {
        
        // MARK: - CategoryPicker
        
        let standardNanoServicesComposer = StandardSelectedCategoryDestinationNanoServicesComposer(
            loadLatest: nanoServices.loadLatestForCategory,
            loadOperators: nanoServices.loadOperators
        )
        let categoryPickerComposer = CategoryPickerSectionBinderComposer(
            load: nanoServices.loadCategories,
            microServices: .init(
                showAll: { $1(CategoryListModelStub(categories: $0)) },
                showCategory: selectCategory(composer: standardNanoServicesComposer)
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
        composer: StandardSelectedCategoryDestinationNanoServicesComposer
    ) -> (
        ServiceCategory, @escaping (SelectedCategoryDestination) -> Void
    ) -> Void {
        
        return { category, completion in
            
            let standardNanoServices = composer.compose(category: category)
            let composer = PaymentFlowMicroServiceComposerNanoServicesComposer(
                standardNanoServices: standardNanoServices
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

final class PaymentFlowMicroServiceComposerNanoServicesComposer {
    
    let standardNanoServices: StandardNanoServices
    
    init(
        standardNanoServices: StandardNanoServices
    ) {
        self.standardNanoServices = standardNanoServices
    }
    
    typealias StandardNanoServices = StandardSelectedCategoryDestinationNanoServices<ServiceCategory, Latest, Operator, SelectedCategoryStub, Error>
}

extension PaymentFlowMicroServiceComposerNanoServicesComposer {
    
    func compose(category: ServiceCategory) -> NanoServices {
        
        let standardFlowComposer = StandardSelectedCategoryDestinationMicroServiceComposer(
            nanoServices: standardNanoServices
        )
        let standardMicroService = standardFlowComposer.compose()
        
        return .init(
            makeMobile: { $0(MobileBinderStub()) },
            makeQR: { $0(QRBinderStub()) },
            makeStandard: { standardMicroService.makeDestination(category, $0) },
            makeTax: { $0(TaxBinderStub()) },
            makeTransport: { $0(TransportBinderStub()) }
        )
    }
    
    typealias NanoServices = PaymentFlowMicroServiceComposerNanoServices<MobileBinderStub, QRBinderStub, Result<SelectedCategoryStub, Error>, TaxBinderStub, TransportBinderStub>
}

final class StandardSelectedCategoryDestinationNanoServicesComposer {
    
    private let loadLatest: LoadLatest
    private let loadOperators: LoadOperators
    
    init(
        loadLatest: @escaping LoadLatest,
        loadOperators: @escaping LoadOperators
    ) {
        self.loadLatest = loadLatest
        self.loadOperators = loadOperators
    }
    
    typealias LoadLatest = (ServiceCategory, @escaping (Result<[Latest], Error>) -> Void) -> Void
    typealias LoadOperators = (ServiceCategory, @escaping (Result<[Operator], Error>) -> Void) -> Void
}

extension StandardSelectedCategoryDestinationNanoServicesComposer {
    
    func compose(
        category: ServiceCategory
    ) -> StandardNanoServices {
        
        let loadLatest = { completion in self.loadLatest(category, completion) }
        let loadOperators = { completion in self.loadOperators(category, completion) }
        
        return .init(
            loadLatest: loadLatest,
            loadOperators: loadOperators,
            makeFailure: { $0(NSError(domain: "Failure", code: -1)) },
            makeSuccess: { payload, completion in
                
                completion(.init(
                    category: category,
                    latest: payload.latest,
                    operators: payload.operators
                ))
            }
        )
    }
    
    typealias StandardNanoServices = StandardSelectedCategoryDestinationNanoServices<ServiceCategory, Latest, Operator, SelectedCategoryStub, Error>
}
