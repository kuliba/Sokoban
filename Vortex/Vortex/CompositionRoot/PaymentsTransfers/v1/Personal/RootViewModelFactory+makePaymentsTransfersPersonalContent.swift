//
//  RootViewModelFactory+makePaymentsTransfersPersonalContent.swift
//  Vortex
//
//  Created by Igor Malyarov on 02.12.2024.
//

extension RootViewModelFactory {
    
    @inlinable
    func makePaymentsTransfersPersonalContent(
        rootFlags: RootFlags,
        _ nanoServices: PaymentsTransfersPersonalNanoServices
    ) -> PaymentsTransfersPersonalDomain.Content {
        
        // MARK: - CategoryPicker
        
        let categoryPicker = makeCategoryPickerSection(
            c2gFlag: rootFlags.c2gFlag,
            nanoServices: nanoServices
        )
        
        // MARK: - OperationPicker
        
        let operationPicker = makeOperationPicker(
            processingFlag: rootFlags.processingFlag,
            loadLatest: nanoServices.loadAllLatest,
            prefix: [
                .element(.init(.templates)),
                .element(.init(.exchange))
            ]
        )
        
        // MARK: - Transfers
        
        let transfers = makeTransfers(
            makeQRModel: { [makeQRScannerModel] in makeQRScannerModel(rootFlags.c2gFlag) },
            makeSuccessViewModelFactory: { [makeSuccessViewModelFactory] in makeSuccessViewModelFactory(rootFlags.processingFlag) }
        )
        
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
