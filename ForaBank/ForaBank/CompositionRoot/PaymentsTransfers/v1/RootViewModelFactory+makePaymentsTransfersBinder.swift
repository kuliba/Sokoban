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
        
        let categoryPickerContentComposer = LoadablePickerModelComposer(
            load: loadCategories,
            scheduler: mainScheduler
        )
        let categoryPickerFlowComposer = CategoryPickerSectionFlowComposer(
            scheduler: mainScheduler
        )
        let categoryPickerContent = categoryPickerContentComposer.compose(
            prefix: [],
            suffix: [],
            placeholderCount: categoryPickerPlaceholderCount
        )
        let categoryPicker = CategoryPickerSectionBinder(
            content: categoryPickerContent,
            flow: categoryPickerFlowComposer.compose()
        )
        
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
            flow: operationPickerFlow
        )
        
        // MARK: - PaymentsTransfers
        
        let content = PaymentsTransfersContent(
            categoryPicker: categoryPicker,
            operationPicker: operationPicker,
            toolbar: (),
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
