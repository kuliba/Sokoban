//
//  PaymentProviderServicePickerFlowEffectHandler.swift
//  ForaBank
//
//  Created by Igor Malyarov on 24.07.2024.
//

final class PaymentProviderServicePickerFlowEffectHandler {
    
    private let makePayByInstructionModel: MakePayByInstructionModel
    
    init(
        makePayByInstructionModel: @escaping MakePayByInstructionModel
    ) {
        self.makePayByInstructionModel = makePayByInstructionModel
    }
    
    typealias MakePayByInstructionModel = (@escaping (PaymentsViewModel) -> Void) -> Void
}

extension PaymentProviderServicePickerFlowEffectHandler {
    
    func handleEffect(
        _ effect: Effect,
        _ dispatch: @escaping Dispatch
    ) {
        switch effect {
        case .payByInstruction:
            makePayByInstructionModel { dispatch(.payByInstruction($0)) }
        }
    }
}

extension PaymentProviderServicePickerFlowEffectHandler {
    
    typealias Dispatch = (Event) -> Void
    
    typealias Event = PaymentProviderServicePickerFlowEvent
    typealias Effect = PaymentProviderServicePickerFlowEffect
}
