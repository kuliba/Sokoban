//
//  SelectorView.swift
//
//
//  Created by Disman Dmitry on 02.02.2024.
//

import SwiftUI

public struct SelectorView: View {
    
    let state: SelectorState
    let event: (SelectorEvent) -> Void
    
    public var body: some View {
        
        switch state {
        case .initial(let configuration):
            
            ScrollView(.horizontal, showsIndicators: false) {
                
                HStack(spacing: configuration.style.itemSpacing) {
                    
                    // TODO: - Добавить элементы для выбора
                }
            }
        }
    }
}
