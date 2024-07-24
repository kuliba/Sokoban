//
//  FilterConfig.swift
//
//
//  Created by Дмитрий Савушкин on 18.07.2024.
//

import Foundation
import SwiftUI

public struct FilterConfig {
    
    let periodTitle: FilterView.TitleView.Config
    let transferTitle: FilterView.TitleView.Config
    let categoriesTitle: FilterView.TitleView.Config
    let button: ButtonConfig
    let buttonsContainerConfig: ButtonsContainer.Config
    let errorConfig: ErrorConfig
    
    public init(
        periodTitle: FilterView.TitleView.Config,
        transferTitle: FilterView.TitleView.Config,
        categoriesTitle: FilterView.TitleView.Config,
        button: ButtonConfig,
        buttonsContainerConfig: ButtonsContainer.Config,
        errorConfig: ErrorConfig
    ) {
        self.periodTitle = periodTitle
        self.transferTitle = transferTitle
        self.categoriesTitle = categoriesTitle
        self.button = button
        self.buttonsContainerConfig = buttonsContainerConfig
        self.errorConfig = errorConfig
    }
    
    public struct ButtonConfig {
        
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
