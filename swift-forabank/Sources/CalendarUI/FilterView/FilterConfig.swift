//
//  FilterConfig.swift
//
//
//  Created by Дмитрий Савушкин on 18.07.2024.
//

import Foundation
import SwiftUI

public struct FilterConfig {
    
    let title: TitleConfig
    let periodTitle: TitleConfig
    let transactionTitle: TitleConfig
    let categoryTitle: TitleConfig

    let optionConfig: OptionConfig
    let buttonsContainerConfig: ButtonsContainer.Config
    let errorConfig: ErrorConfig
    
    public init(
        title: TitleConfig,
        periodTitle: TitleConfig,
        transactionTitle: TitleConfig,
        categoryTitle: TitleConfig,
        optionConfig: FilterConfig.OptionConfig,
        buttonsContainerConfig: ButtonsContainer.Config,
        errorConfig: ErrorConfig
    ) {
        self.title = title
        self.periodTitle = periodTitle
        self.transactionTitle = transactionTitle
        self.categoryTitle = categoryTitle
        self.optionConfig = optionConfig
        self.buttonsContainerConfig = buttonsContainerConfig
        self.errorConfig = errorConfig
    }
    
    public struct OptionConfig {
        
        let selectBackgroundColor: Color
        let notSelectedBackgroundColor: Color
        
        let selectForegroundColor: Color
        let notSelectForegroundColor: Color
        
        public init(
            selectBackgroundColor: Color,
            notSelectedBackgroundColor: Color,
            selectForegroundColor: Color,
            notSelectForegroundColor: Color
        ) {
            self.selectBackgroundColor = selectBackgroundColor
            self.notSelectedBackgroundColor = notSelectedBackgroundColor
            self.selectForegroundColor = selectForegroundColor
            self.notSelectForegroundColor = notSelectForegroundColor
        }
    }
}
