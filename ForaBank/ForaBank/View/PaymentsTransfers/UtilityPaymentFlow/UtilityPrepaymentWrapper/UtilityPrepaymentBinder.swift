//
//  UtilityPrepaymentBinder.swift
//  ForaBank
//
//  Created by Igor Malyarov on 08.08.2024.
//

import Combine
import CombineSchedulers
import Foundation

final class UtilityPrepaymentBinder {
    
    let model: UtilityPrepaymentViewModel
    let searchModel: RegularFieldViewModel
    
    private let cancellable: AnyCancellable
    
    init(
        model: UtilityPrepaymentViewModel,
        searchModel: RegularFieldViewModel,
        scheduler: AnySchedulerOf<DispatchQueue>
    ) {
        self.model = model
        self.searchModel = searchModel
        self.cancellable = searchModel.$state
            .map(\.text)
            .receive(on: scheduler)
            .sink { [weak model] in model?.event(.search($0 ?? "")) }
    }
}
