//
//  BackView.swift
//  
//
//  Created by Andryusina Nataly on 22.03.2024.
//

import SwiftUI

public struct BackView: View {
    
    let cardInfo: CardInfo
    let actions: BackActions
    let modifierConfig: ModifierConfig
    let config: Config
    
    public init(
        cardInfo: CardInfo,
        actions: BackActions,
        modifierConfig: ModifierConfig,
        config: Config
    ) {
        self.cardInfo = cardInfo
        self.actions = actions
        self.modifierConfig = modifierConfig
        self.config = config
    }

    public var body: some View {
        
        Back(
            modifierConfig: modifierConfig,
            config: config,
            header: {
                
                HeaderBackView.init(
                    cardInfo: cardInfo,
                    action: actions.header,
                    config: config
                )
            },
            cvv: {
                
                CVVView.init(
                    cardInfo: cardInfo,
                    config: config,
                    action: actions.cvv
                )
            }
        )
    }
}

public struct BackActions {
    
    let header: () -> Void
    let cvv: () -> Void
    
    public init(
        header: @escaping () -> Void,
        cvv: @escaping () -> Void
    ) {
        self.header = header
        self.cvv = cvv
    }
}
