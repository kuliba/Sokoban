//
//  PaymentsTransfersModelComposer.swift
//  PayHubPreview
//
//  Created by Igor Malyarov on 16.08.2024.
//

import CombineSchedulers
import Foundation
import PayHub
import PayHubUI

final class PaymentsTransfersModelComposer {
    
    private let scheduler: AnySchedulerOf<DispatchQueue>
    
    init(
        scheduler: AnySchedulerOf<DispatchQueue>
    ) {
        self.scheduler = scheduler
    }
}

extension PaymentsTransfersModelComposer {
    
    func compose(
        loadedCategories: [ServiceCategory],
        loadedItems: [OperationPickerItem<Latest>]
    ) -> Model {
        
        return .init(
            categoryPicker: makeCategoryPickerBinder(loadedCategories: loadedCategories),
            operationPicker: makeOperationBinder(loadedItems: loadedItems)
        )
    }
    
    typealias Model = PaymentsTransfersContentModel
}

// MARK: - CategoryPicker

private extension PaymentsTransfersModelComposer {
    
    func makeCategoryPickerBinder(
        loadedCategories: [ServiceCategory]
    ) -> CategoryPickerSectionBinder {
        
        let composer = CategoryPickerSectionContentComposer(
            scheduler: scheduler
        )
        let content = composer.compose(loadedCategories: loadedCategories)
        
        return .init(content: content, flow: ())
    }
}

// MARK: - PayHub

private extension PaymentsTransfersModelComposer {
    
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
