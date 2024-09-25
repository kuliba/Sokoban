//
//  UtilityPrepaymentBinder.swift
//  ForaBank
//
//  Created by Igor Malyarov on 08.08.2024.
//

import Combine
import Foundation

final class UtilityPrepaymentBinder {
    
    let model: UtilityPrepaymentViewModel
    let searchModel: RegularFieldViewModel
    
    private let cancellable: AnyCancellable
    
    init(
        model: UtilityPrepaymentViewModel,
        searchModel: RegularFieldViewModel
    ) {
        self.model = model
        self.searchModel = searchModel
        self.cancellable = searchModel.$state
            .map(\.text)
            .sink { [weak model] in model?.event(.search($0 ?? "")) }
    }
}
