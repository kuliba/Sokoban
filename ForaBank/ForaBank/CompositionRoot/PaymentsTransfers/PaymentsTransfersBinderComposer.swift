//
//  PaymentsTransfersBinderComposer.swift
//  ForaBank
//
//  Created by Igor Malyarov on 20.08.2024.
//

final class PaymentsTransfersBinderComposer {
    
    let makePayHubPickerBinder: MakePayHubPickerBinder
    
    init(
        makePayHubPickerBinder: @escaping MakePayHubPickerBinder
    ) {
        self.makePayHubPickerBinder = makePayHubPickerBinder
    }
    
    typealias MakePayHubPickerBinder = () -> PayHubPickerBinder
}

extension PaymentsTransfersBinderComposer {
     
    func compose() -> PaymentsTransfersBinder {
        
        return .init(
            content: makeContent(),
            flow: makeFlow(), 
            bind: { _,_ in nil }
        )
    }
}

// MARK: - Content

private extension PaymentsTransfersBinderComposer {
    
    func makeContent() -> PaymentsTransfersContentModel {
        
        return .init(payHubPicker: makePayHubPickerBinder())
    }
}

// MARK: - Flow

private extension PaymentsTransfersBinderComposer {
    
    func makeFlow() -> PaymentsTransfersFlowModel {
        
        return
    }
}
