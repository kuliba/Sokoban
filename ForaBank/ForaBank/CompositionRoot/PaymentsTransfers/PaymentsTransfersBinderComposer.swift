//
//  PaymentsTransfersBinderComposer.swift
//  ForaBank
//
//  Created by Igor Malyarov on 20.08.2024.
//

final class PaymentsTransfersBinderComposer {
    
    let makeOperationPickerBinder: MakeOperationPickerBinder
    
    init(
        makeOperationPickerBinder: @escaping MakeOperationPickerBinder
    ) {
        self.makeOperationPickerBinder = makeOperationPickerBinder
    }
    
    typealias MakeOperationPickerBinder = () -> OperationPickerBinder
}

extension PaymentsTransfersBinderComposer {
     
    func compose() -> PaymentsTransfersBinder {
        
        return .init(
            content: makeContent(),
            flow: makeFlow()
        )
    }
}

// MARK: - Content

private extension PaymentsTransfersBinderComposer {
    
    func makeContent() -> PaymentsTransfersContentModel {
        
        return .init(categoryPicker: (), operationPicker: makeOperationPickerBinder())
    }
}

// MARK: - Flow

private extension PaymentsTransfersBinderComposer {
    
    func makeFlow() -> PaymentsTransfersFlowModel {
        
        return
    }
}
