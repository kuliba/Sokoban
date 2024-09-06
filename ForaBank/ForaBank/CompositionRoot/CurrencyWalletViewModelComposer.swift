//
//  CurrencyWalletViewModelComposer.swift
//  ForaBank
//
//  Created by Igor Malyarov on 05.09.2024.
//

final class CurrencyWalletViewModelComposer {
    
    private let model: Model
    
    init(model: Model) {
        
        self.model = model
    }
}

extension CurrencyWalletViewModelComposer {
    
    func compose(
        dismiss: @escaping () -> Void,
        currencyOperation: CurrencyOperation = .buy
    ) -> CurrencyWalletViewModel? {
        
        guard let currency = model.currencyWalletList.value.first
        else { return nil }
        
        return .init(
            currency: .init(description: currency.code),
            currencyOperation: currencyOperation,
            model: model,
            dismissAction: dismiss
        )
    }
}
