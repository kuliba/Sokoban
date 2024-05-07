//
//  UtilitiesViewModel.swift
//  ForaBank
//
//  Created by Igor Malyarov on 03.05.2024.
//

import Foundation
import OperatorsListComponents
import PrePaymentPicker

#warning("replace with type from module")
final class UtilitiesViewModel: ObservableObject {
    
    @Published private(set) var state: State
    
    private let loadOperators: LoadOperators
    
    init(
        initialState: State,
        loadOperators: @escaping LoadOperators
    ) {
        self.state = initialState
        self.loadOperators = loadOperators
    }
    
    // MARK: - types
    
    typealias State = PrePaymentOptionsState<OperatorsListComponents.LatestPayment, OperatorsListComponents.Operator>
    
    struct Payload {}
    
    typealias LoadOperatorsCompletion = ([OperatorsListComponents.Operator]) -> Void
    typealias LoadOperators = (Payload, @escaping LoadOperatorsCompletion) -> Void
}

