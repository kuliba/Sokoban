//
//  AnywayServicePickerFlowModelFactory.swift
//  ForaBank
//
//  Created by Igor Malyarov on 04.08.2024.
//

struct AnywayServicePickerFlowModelFactory {
    
    let makeAnywayFlowModel: MakeAnywayFlowModel
    let makePayByInstructionsViewModel: MakePayByInstructionsViewModel
}

extension AnywayServicePickerFlowModelFactory {
    
    typealias MakeAnywayFlowModel = (AnywayTransactionState.Transaction) -> AnywayFlowModel
    typealias MakePayByInstructionsViewModel = (@escaping () -> Void) -> PaymentsViewModel
}
