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
