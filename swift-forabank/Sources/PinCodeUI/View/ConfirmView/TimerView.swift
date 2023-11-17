//
//  TimerView.swift
//  
//
//  Created by Andryusina Nataly on 18.07.2023.
//

import SwiftUI

struct TimerView: View {
    
    @ObservedObject var viewModel: ConfirmViewModel.TimerViewModel
    let config: TimerView.Config
    
    var body: some View {
        
        VStack(spacing: 32) {
                        
            if viewModel.needRepeatButton {
                
                Text("Код отправлен на \(viewModel.phoneNumber.rawValue)")
                    .font(config.descFont)
                    .foregroundColor(config.descForegroundColor)
                    .multilineTextAlignment(.center)
                
                RepeatButtonView(config:
                        .init(
                            font: Font.custom("Inter", size: 12),
                            foregroundColor: Color(red: 1, green: 0.21, blue: 0.21),
                            backgroundColor: Color(red: 0.96, green: 0.96, blue: 0.97),
                            action: { viewModel.restartTimer() }
                        )
                )
            } else {
                
                Text("Код отправлен на \(viewModel.phoneNumber.rawValue)\nЗапросить повторно можно через")
                    .font(config.descFont)
                    .foregroundColor(config.descForegroundColor)
                    .lineLimit(2)
                    .multilineTextAlignment(.center)
                
                Text(viewModel.value)
                    .font(config.valueFont)
                    .foregroundColor(config.valueForegroundColor)
            }
            Spacer()
        }.onAppear {
            viewModel.instantiateTimer()
        }.onDisappear {
            viewModel.cancelTimer()
        }.onReceive(viewModel.timer) { newTime in
            viewModel.updateValue(
                startTime: viewModel.startTime,
                delay: viewModel.delay,
                time: newTime
            )
        }
    }
}

struct TimerView_Previews : PreviewProvider {
    
    static var previews: some View {
        
        TimerView.init(
            viewModel: .sample,
            config: .defaultConfig
        )
    }
}
