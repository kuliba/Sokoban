//
//  OperationViewConfiguration.swift
//  
//
//  Created by Дмитрий Савушкин on 13.12.2023.
//

import Foundation

public struct OperationViewConfiguration {

    let tipViewConfig: TipViewConfiguration
    let stickerViewConfig: StickerViewConfiguration
    let selectViewConfig: SelectViewConfiguration
    let productViewConfig: ProductView.Appearance
    let inputViewConfig: InputConfiguration
    let amountViewConfig: AmountViewConfiguration
    let resultViewConfiguration: ResultViewConfiguration
    let continueButtonConfiguration: ContinueButtonConfiguration
    
    public init(
        tipViewConfig: TipViewConfiguration,
        stickerViewConfig: StickerViewConfiguration,
        selectViewConfig: SelectViewConfiguration,
        productViewConfig: ProductView.Appearance,
        inputViewConfig: InputConfiguration,
        amountViewConfig: AmountViewConfiguration,
        resultViewConfiguration: ResultViewConfiguration,
        continueButtonConfiguration: ContinueButtonConfiguration
    ) {
        self.tipViewConfig = tipViewConfig
        self.stickerViewConfig = stickerViewConfig
        self.selectViewConfig = selectViewConfig
        self.productViewConfig = productViewConfig
        self.inputViewConfig = inputViewConfig
        self.amountViewConfig = amountViewConfig
        self.resultViewConfiguration = resultViewConfiguration
        self.continueButtonConfiguration = continueButtonConfiguration
    }
}
