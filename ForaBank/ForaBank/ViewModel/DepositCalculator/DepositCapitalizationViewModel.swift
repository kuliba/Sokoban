//
//  DepositCapitalizationViewModel.swift
//  ForaBank
//
//  Created by Pavel Samsonov on 04.05.2022.
//

import Combine

class DepositCapitalizationViewModel: ObservableObject {

    @Published var isOn: Bool

    let title: String
    let named: String

    init(title: String, named: String, isOn: Bool = true) {

        self.title = title
        self.named = named
        self.isOn = isOn
    }
}

extension DepositCapitalizationViewModel {

    static let sample = DepositCapitalizationViewModel(
        title: "С учетом капитализации",
        named: "Calculate Capitalization"
    )
}
