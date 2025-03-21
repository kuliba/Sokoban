//
//  RootViewModelFactory+makeCloseAccountPaymentsSuccessViewModel.swift
//  Vortex
//
//  Created by Andryusina Nataly on 18.03.2025.
//

extension RootViewModelFactory {
    
    @inlinable
    func makeCloseAccountPaymentsSuccessViewModel(
        payload: CloseAccountPayload
    ) -> PaymentsSuccessViewModel? {
                
        if let success = Payments.Success(
            model: model,
            mode: payload.mode,
            amountFormatter: model.amountFormatted(amount:currencyCode:style:)
        ) {
            
            return .init(paymentSuccess: success, model)
        }
        return nil
    }
    
    @inlinable
    func makeSuccessViewModelFactory(
        _ processingFlag: ProcessingFlag
    ) -> SuccessViewModelFactory {
        .init(
            makeCloseAccountPaymentsSuccessViewModel: { [weak self] in
                
                let payload: CloseAccountPayload = .init(
                    flag: processingFlag,
                    initialMode: $0
                )
                return self?.makeCloseAccountPaymentsSuccessViewModel(payload: payload)
            })
    }
}

private extension CloseProductTransferData {
    
    init(
        _ processingFlag: ProcessingFlag,
        _ oldValue: CloseProductTransferData
    ) {
        self.init(
            paymentOperationDetailId: oldValue.paymentOperationDetailId,
            documentStatus: oldValue.documentStatus.newStatus(processingFlag),
            accountNumber: oldValue.accountNumber,
            closeDate: oldValue.closeDate,
            comment: oldValue.comment,
            category: oldValue.category
        )
    }
}

private extension TransferResponseData.DocumentStatus {
    
    func newStatus(
        _ processingFlag: ProcessingFlag
    ) -> Self {
        processingFlag.isActive && self == .inProgress ? .processing : self
    }
}

private extension CloseAccountPayload {
    
    var mode: PaymentsSuccessViewModel.Mode {
        
        switch self.initialMode {
        case let .closeAccount(productDataID, currency, balance: balance, transferData):
            return .closeAccount(
                    productDataID,
                    currency,
                    balance: balance,
                    .init(flag, transferData)
                )
            
        case let .closeAccountEmpty(productDataID, currency, balance: balance, transferData):
            return .closeAccountEmpty(
                    productDataID,
                    currency,
                    balance: balance,
                    .init(flag, transferData)
                )
            
        default:
            return self.initialMode
        }
    }
}
