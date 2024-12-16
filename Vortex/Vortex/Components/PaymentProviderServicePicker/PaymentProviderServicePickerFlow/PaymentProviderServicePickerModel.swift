//
//  _PaymentProviderServicePickerModel.swift
//  ForaBank
//
//  Created by Igor Malyarov on 24.07.2024.
//

import Foundation

final class _PaymentProviderServicePickerModel: ObservableObject {
    
    @Published private(set) var state: State
    
    init(initialState: State) {
        
        self.state = initialState
    }
}

extension _PaymentProviderServicePickerModel {
    
    typealias State = ??
}
