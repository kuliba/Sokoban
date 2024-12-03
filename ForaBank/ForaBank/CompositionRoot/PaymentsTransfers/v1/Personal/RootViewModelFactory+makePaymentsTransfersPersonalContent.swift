//
//  RootViewModelFactory+makePaymentsTransfersPersonalContent.swift
//  ForaBank
//
//  Created by Igor Malyarov on 02.12.2024.
//

extension RootViewModelFactory {
    
    @inlinable
    func makePaymentsTransfersPersonalContent(
        _ nanoServices: PaymentsTransfersPersonalNanoServices
    ) -> PaymentsTransfersPersonalDomain.Content {
        
        // MARK: - CategoryPicker
        
        let categoryPicker = makeCategoryPickerSection(nanoServices)
        
        // MARK: - OperationPicker
        
        let operationPicker = makeOperationPicker(nanoServices)
        
        // MARK: - Transfers
        
        let transfers = makeTransfers(makeQRModel: makeQRScannerModel)
        
        // MARK: - PaymentsTransfers
        
        return .init(
            categoryPicker: categoryPicker,
            operationPicker: operationPicker,
            transfers: transfers,
            reload: {
                
                categoryPicker.content.event(.reload)
                operationPicker.content.event(.reload)
            }
        )
    }
}
