//
//  RootViewModelFactory+makePaymentsTransfersBinder.swift
//  ForaBank
//
//  Created by Igor Malyarov on 20.08.2024.
//

import CombineSchedulers
import Foundation
import PayHub
import PayHubUI

extension RootViewModelFactory {
    
    typealias LoadLatestOperationsCompletion = ([Latest]) -> Void
    typealias LoadLatestOperations = (@escaping LoadLatestOperationsCompletion) -> Void
    
    typealias LoadServiceCategoriesCompletion = ([CategoryPickerSectionItem]) -> Void
    typealias LoadServiceCategories = (@escaping LoadServiceCategoriesCompletion) -> Void
    
    static func makePaymentsTransfersBinder(
        categoryPickerPlaceholderCount: Int,
        operationPickerPlaceholderCount: Int,
        loadCategories: @escaping LoadServiceCategories,
        loadLatestOperations: @escaping LoadLatestOperations,
        mainScheduler: AnySchedulerOf<DispatchQueue>,
        backgroundScheduler: AnySchedulerOf<DispatchQueue>
    ) -> PaymentsTransfersBinder {
        
        // MARK: - CategoryPicker
        
        let categoryPickerComposer = CategoryPickerSectionBinderComposer(
            load: loadCategories,
            microServices: .init(
                showAll: { $0(CategoryListModelStub()) },
                showCategory: { $1(CategoryModelStub(category: $0)) }
            ),
            placeholderCount: categoryPickerPlaceholderCount,
            scheduler: mainScheduler
        )
        let categoryPicker = categoryPickerComposer.compose()
        
        // MARK: - OperationPicker
        
        let operationPickerContentComposer = LoadablePickerModelComposer<UUID, OperationPickerItem<Latest>>(
            load: { completion in
                
                loadLatestOperations {
                    
                    completion($0.map { .latest($0) })
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
            bind: { _,_ in [] }
        )
        
        // MARK: - Toolbar
        
        let toolbarComposer = PaymentsTransfersToolbarBinderComposer(
            microServices: .init(
                makeProfile: { $0(ProfileModelStub()) },
                makeQR: { $0(QRModelStub()) }
            ),
            scheduler: mainScheduler
        )
        let toolbar = toolbarComposer.compose()
        
        // MARK: - PaymentsTransfers
        
        let content = PaymentsTransfersContent(
            categoryPicker: categoryPicker,
            operationPicker: operationPicker,
            toolbar: toolbar,
            reload: {}
        )
        
        let reducer = PayHub.PaymentsTransfersFlowReducer()
        let effectHandler = PayHub.PaymentsTransfersFlowEffectHandler(
            microServices: .init()
        )
        let flow = PaymentsTransfersFlow(
            initialState: .init(),
            reduce: reducer.reduce(_:_:),
            handleEffect: effectHandler.handleEffect(_:_:),
            scheduler: mainScheduler
        )
        
        return .init(content: content, flow: flow, bind: { _,_ in [] })
    }
}
