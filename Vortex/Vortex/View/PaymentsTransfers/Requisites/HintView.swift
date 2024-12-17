//
//  HintView.swift
//  ForaBank
//
//  Created by Дмитрий Савушкин on 14.12.2022.
//

import SwiftUI

struct HintView: View {
    
    let viewModel: HintViewModel
    
    var body: some View {
        
        VStack(spacing: 24) {
            
            HeaderView(viewModel: viewModel.header)
           
            ForEach(viewModel.content) { viewModelContent in
             
                ContentView(viewModel: viewModelContent)
            }
        }
        .padding(.top, 5)
        .padding(.bottom, 30)
        .padding(.horizontal, 20)
    }
    
    struct HeaderView: View {
        
        let viewModel: HintViewModel.HeaderViewModel
        
        var body: some View {
            
            VStack(spacing: 16) {
                
                ZStack {
                    
                    Circle()
                        .frame(width: 64, height: 64, alignment: .center)
                        .foregroundColor(.mainColorsGrayLightest)
                    
                    viewModel.icon
                        .resizable()
                        .frame(width: 32, height: 32, alignment: .center)
                        .foregroundColor(.iconBlack)
                }
                
                VStack(spacing: 8) {
                    
                    Text(viewModel.title)
                        .font(.textH3M18240())
                        .foregroundColor(.textSecondary)
                    
                    Text(viewModel.subtitle)
                        .font(.textBodyMR14180())
                        .foregroundColor(.textPlaceholder)
                        .multilineTextAlignment(.center)
                        .lineSpacing(5)
                }
            }
        }
    }
    
    struct ContentView: View {
        
        let viewModel: HintViewModel.ContentViewModel
        
        var body: some View {
            
            VStack(alignment: .leading, spacing: 12) {
                
                Text(viewModel.title)
                    .font(.textBodyMM14200())
                    .foregroundColor(.textSecondary)
                    .multilineTextAlignment(.leading)
                
                HStack {
                 
                    Text(viewModel.description)
                        .font(.textH4R16240())
                        .foregroundColor(.textSecondary)
                        .lineSpacing(6)
                    
                    Spacer()
                }
                .padding(.init(top: 14, leading: 20, bottom: 16, trailing: 20))
                .background(Color.mainColorsGrayLightest)
                .cornerRadius(12)
            }
        }
    }
}

struct HintView_Previews: PreviewProvider {
    
    static var previews: some View {
        
        HintView(viewModel: .sample)
    }
}

extension HintViewModel {
    
    static let sample = HintViewModel(header: HeaderViewModel(icon: .ic24Info, title: "Назначение платежа", subtitle: "Заполняется в соответствии\nс требованиями поставщика услуг"), content: [.init(title: "Рекомендуемый формат:", description: "ЕЛС;период оплаты///назначение платежа, № и дата счета, адрес. Показания. НДС (есть/нет)."), .init(title: "Пример:", description: "ЛСИ1105-12;09.2022///оплата по счету 10 от 30.09.22, потребление э/э, показания 52364, адрес. В т.ч. НДС. л/с1631245;10.2022///платеж за кап ремонт, адрес. Без НДС.")])
}
