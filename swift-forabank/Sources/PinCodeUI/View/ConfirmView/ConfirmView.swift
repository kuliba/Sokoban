//
//  ConfirmView.swift
//  
//
//  Created by Andryusina Nataly on 18.07.2023.
//

import SwiftUI

public struct ConfirmView: View {
    
    let config: ConfirmView.Config
    
    public init(
        config: ConfirmView.Config = .defaultConfig
    ) {
        self.config = config
    }
    
    public var body: some View {
        
        HStack(alignment: .top) {
            
            VStack {
                
                Text("Введите код из сообщения")
                    .font(config.font)
                    .multilineTextAlignment(.center)
                    .foregroundColor(config.foregroundColor)
                
                HStack(spacing: 16){
                    
                    ForEach(Array.code.indices, id: \.self) { index in
                        
                        DigitView(
                            value: Array.code[index],
                            config: .defaultValue
                        )
                    }
                }
                .padding(.top, 40)
                
                TimerView(
                    viewModel: .sample,
                    config: .defaultConfig
                )
                .padding(.top, 32)
            }
            .padding(.trailing, 20)
            .padding(.leading, 19)
            .padding(.top, 16)
            .frame(maxHeight: .infinity)
        }
    }
}

struct ConfirmView_Previews: PreviewProvider {
    
    static var previews: some View {
        
        ConfirmView(config: .defaultConfig)
    }
}

//MARK: - Preview Content

private extension DigitView.Config {
    
    static let defaultValue: Self = .init(
        foregroundColor: Color(red: 0.6, green: 0.6, blue: 0.6),
        font: Font.custom("Inter", size: 32)
            .weight(.bold),
        filColor: .grayMedium
    )
}

private extension Color {
    
    static let grayMedium = Color(red: 0.83, green: 0.83, blue: 0.83)
}

extension Array where Element == String? {
    
    static let code: Self = ["1","7", nil, nil, nil, nil]
}
