//
//  PaymentsAntifraudView.swift
//  ForaBank
//
//  Created by Дмитрий Савушкин on 02.12.2022.
//

import SwiftUI

struct PaymentsAntifraudView: View {
    
    let viewModel: PaymentsAntifraudViewModel
    
    var body: some View {
        
        VStack(spacing: 24) {
            
            HeaderView(viewModel: viewModel.header)
            
            MainView(viewModel: viewModel.main)
            
            BottomView(viewModel: viewModel.bottom)
        }
        .padding(.top, 24)
        .padding(.bottom, 44)
    }
    
    struct HeaderView: View {
        
        let viewModel: PaymentsAntifraudViewModel.HeaderViewModel
        
        var body: some View {
            
            VStack(spacing: 24) {
                
                ZStack {
                    
                    Circle()
                        .foregroundColor(.systemColorError)
                        .frame(width: 64, height: 64, alignment: .center)
                    
                    viewModel.icon
                        .foregroundColor(.white)
                }
                
                VStack(spacing: 8) {
                    
                    Text(viewModel.title)
                        .foregroundColor(.textSecondary)
                        .font(.textH4M16240())
                        .multilineTextAlignment(.center)
                    
                    Text(viewModel.description)
                        .foregroundColor(.textPlaceholder)
                        .font(.textBodySR12160())
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 20)
                }
            }
        }
    }
    
    struct MainView: View {
        
        let viewModel: PaymentsAntifraudViewModel.MainViewModel
        
        var body: some View {
            
            VStack(spacing: 32) {
                
                VStack {
                    
                    Text(viewModel.name)
                        .font(.textH4R16240())
                        .foregroundColor(.textSecondary)
                    
                    Text(viewModel.phone)
                        .font(.textH4R16240())
                        .foregroundColor(.textSecondary)
                }
                
                Text(viewModel.amount)
                    .font(.textH1Sb24322())
                    .foregroundColor(.textSecondary)
                
                TimerView(viewModel: viewModel.timer)
                    .font(.textBodySR12160())
                    .foregroundColor(.red)
            }
        }
    }
    
    struct TimerView: View {
        
        @ObservedObject var viewModel: PaymentsAntifraudViewModel.TimerViewModel
        
        var body: some View {
            
            HStack(spacing: 8) {
                
                Image.ic16Clock
                    .foregroundColor(.red)
                
                Text(viewModel.value)
                    .font(.textBodySR12160())
                    .foregroundColor(.red)
            }
        }
    }
    
    struct BottomView: View {
        
        let viewModel: PaymentsAntifraudViewModel.BottomViewModel
        
        var body: some View {
            
            HStack(spacing: 8) {
                
                ButtonSimpleView(viewModel: viewModel.cancelButton)
                    .frame(height: 56)
                
                ButtonSimpleView(viewModel: viewModel.continueButton)
                    .frame(height: 56)
            }
            .padding(.horizontal, 20)
        }
    }
}

struct PaymentsAntifraudView_Previews: PreviewProvider {
    static var previews: some View {
        PaymentsAntifraudView(viewModel: .init(header: .init(), main: .init(name: "Юрий Андреевич К.", phone: "+7 (903) 324-54-15", amount: "- 1 000,00 ₽", timer: .init(delay: .init(110.0), completeAction: {})), bottom: .init(cancelButton: .init(title: "Отменить", style: .gray, action: {}), continueButton: .init(title: "Продолжить", style: .gray, action: {}))))
    }
}
