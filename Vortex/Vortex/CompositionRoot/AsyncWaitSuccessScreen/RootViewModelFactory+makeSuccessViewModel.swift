//
//  RootViewModelFactory+makeSuccessViewModel.swift
//  Vortex
//
//  Created by Andryusina Nataly on 18.03.2025.
//

extension RootViewModelFactory {
    
    @inlinable
    func makeSuccessViewModel(
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
            makeSuccessViewModel: { [weak self] in
                
                let payload: CloseAccountPayload = .init(
                    flag: processingFlag,
                    initialMode: $0
                )
                return self?.makeSuccessViewModel(payload: payload)
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

private extension TransferResponseData {
    
    convenience init(
        _ processingFlag: ProcessingFlag,
        _ oldValue: TransferResponseData
    ) {
        self.init(
            amount: oldValue.amount,
            creditAmount: oldValue.creditAmount,
            currencyAmount: oldValue.currencyAmount,
            currencyPayee: oldValue.currencyPayee,
            currencyPayer: oldValue.currencyPayer,
            currencyRate: oldValue.currencyRate,
            debitAmount: oldValue.debitAmount,
            fee: oldValue.fee,
            needMake: oldValue.needMake,
            needOTP: oldValue.needOTP,
            payeeName: oldValue.payeeName,
            documentStatus: oldValue.documentStatus?.newStatus(processingFlag),
            paymentOperationDetailId: oldValue.paymentOperationDetailId,
            scenario: oldValue.scenario
        )
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
         
        case let .meToMe(templateId: templateId, from: productIdFrom, to: productIdTo, transferData):
            return .meToMe(
                templateId: templateId,
                from: productIdFrom,
                to: productIdTo,
                .init(flag, transferData)
            )
            
        default:
            return self.initialMode
        }
    }
}
