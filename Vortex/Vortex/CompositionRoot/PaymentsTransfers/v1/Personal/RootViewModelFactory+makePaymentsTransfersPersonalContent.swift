//
//  RootViewModelFactory+makePaymentsTransfersPersonalContent.swift
//  Vortex
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
        
        let operationPicker = makeOperationPicker(
            loadLatest: nanoServices.loadAllLatest,
            prefix: [
                .element(.init(.templates)),
                .element(.init(.exchange))
            ]
        )
        
        // MARK: - Transfers
        
        let transfers = makeTransfers(makeQRModel: makeQRScannerModel)
        
        // MARK: - PaymentsTransfers
        
        return .init(
            categoryPicker: categoryPicker,
            operationPicker: operationPicker,
            transfers: transfers,
            reload: {
                
                categoryPicker.reload()
                operationPicker.reload()
            }
        )
    }
}
