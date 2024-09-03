//
//  PaymentsTransfersContentComposer.swift
//  PayHubPreview
//
//  Created by Igor Malyarov on 16.08.2024.
//

import CombineSchedulers
import Foundation
import PayHub
import PayHubUI

final class PaymentsTransfersContentComposer {
    
    private let scheduler: AnySchedulerOf<DispatchQueue>
    
    init(
        scheduler: AnySchedulerOf<DispatchQueue>
    ) {
        self.scheduler = scheduler
    }
}

extension PaymentsTransfersContentComposer {
    
    func compose(
        loadedCategories: [ServiceCategory],
        loadedItems: [OperationPickerItem<Latest>]
    ) -> PaymentsTransfersContent {
        
        let categoryPicker = makeCategoryPickerBinder(loadedCategories: loadedCategories)
        let operationPicker = makeOperationBinder(loadedItems: loadedItems)
        
        return .init(
            categoryPicker: categoryPicker,
            operationPicker: operationPicker,
            toolbar: makePaymentsTransfersToolbarBinder(),
            reload: {
                
                categoryPicker.content.event(.load)
                operationPicker.content.event(.load)
            }
        )
    }
}

// MARK: - CategoryPicker

private extension PaymentsTransfersContentComposer {
    
    func makeCategoryPickerBinder(
        loadedCategories: [ServiceCategory]
    ) -> CategoryPickerSectionBinder {
        
        let plainPickerComposer = PlainPickerBinderComposer<ServiceCategory, UUIDIdentified<Void>>(
            microServices: .init(
                makeNavigation: { _, completion in
                    
                    completion(.init(()))
                }
            ),
            scheduler: scheduler
        )
        
        let composer = CategoryPickerSectionBinderComposer(
            load: { completion in
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                    
                    completion(loadedCategories.map { .category($0) })
                }
            },
            microServices: .init(
                showAll: { $1(plainPickerComposer.compose(elements: $0)) },
                showCategory: { category, completion in
                    
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                        
                        self.selectCategory(category: category, completion: completion)
                    }
                }
            ),
            placeholderCount: 6,
            scheduler: scheduler
        )
        
        return composer.compose(prefix: [], suffix: [])
    }
}

// MARK: - SelectedCategory

private extension PaymentsTransfersContentComposer {
    
    func selectCategory(
        category: ServiceCategory,
        completion: @escaping (SelectedCategoryDestination) -> Void
    ) {
        let composer = PaymentFlowMicroServiceComposerNanoServicesComposer()
        let nanoServices = composer.compose(category: category)
        let paymentFlowComposer = PaymentFlowMicroServiceComposer(
            nanoServices: nanoServices
        )
        let microService = paymentFlowComposer.compose()
        
        microService.makePaymentFlow(category.paymentFlowID, completion)
    }
}

extension ServiceCategory {
    
    var paymentFlowID: PaymentFlowID {
        
        switch name {
        case "Mobile":    return .mobile
        case "QR":        return .qr
        case "Tax":       return .taxAndStateServices
        case "Transport": return .transport
        default:          return .standard
        }
    }
}

// MARK: - OperationPicker

private extension PaymentsTransfersContentComposer {
    
    func makeOperationBinder(
        loadedItems: [OperationPickerItem<Latest>]
    ) -> OperationPickerBinder {
        
        let content = OperationPickerContent.stub(loadResult: loadedItems)
        let flow = OperationPickerFlow.stub()
        
        return .init(
            content: content,
            flow: flow,
            bind: { content, flow in
                
                content.$state
                    .map(\.selected)
                    .sink { flow.event(.select($0)) }
            }
        )
    }
}

// MARK: - Toolbar

private extension PaymentsTransfersContentComposer {
    
    func makePaymentsTransfersToolbarBinder(
    ) -> PaymentsTransfersToolbarBinder {
        
        let composer = PaymentsTransfersToolbarBinderComposer(
            microServices: .init(
                makeProfile: { $0(ProfileModel()) },
                makeQR: { $0(QRModel()) }
            ),
            scheduler: scheduler
        )
        return composer.compose()
    }
}
