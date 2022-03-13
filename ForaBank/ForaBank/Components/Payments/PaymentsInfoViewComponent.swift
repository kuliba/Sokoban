//
//  PaymentsInfoViewComponent.swift
//  ForaBank
//
//  Created by Константин Савялов on 07.02.2022.
//

import SwiftUI

//MARK: - ViewModel

extension PaymentsInfoView {
    
    class ViewModel: PaymentsParameterViewModel {
        
        let icon: Image
        let title: String
        let content: String
        
        //TODO: real placeholder required
        private static let iconPlaceholder = Image("Payments Icon Placeholder")

        internal init(icon: Image, title: String, content: String) {
            
            self.icon = icon
            self.title = title
            self.content = content
            super.init(source: Payments.ParameterMock())
        }
        
        init(with parameterInfo: Payments.ParameterInfo) throws {
            
            self.icon = parameterInfo.icon.image ?? Self.iconPlaceholder
            self.title = parameterInfo.title
            self.content = parameterInfo.parameter.value ?? ""
            super.init(source: parameterInfo)
        }
    }
}

//MARK: - View

struct PaymentsInfoView: View {
    
    let viewModel: PaymentsInfoView.ViewModel
    
    var body: some View {
        
        VStack {
        
        HStack(alignment: .top, spacing: 16) {
            
            viewModel.icon
                .resizable()
                .frame(width: 32, height: 32)
                .padding(.top, 12)
            
            VStack(alignment: .leading, spacing: 4)  {
                
                Text(viewModel.title)
                    .font(Font.custom("Inter-Regular", size: 12))
                    .foregroundColor(Color(hex: "#999999"))
                
                Text(viewModel.content)
                    .font(Font.custom("Inter-Medium", size: 14))
                    .foregroundColor(Color(hex: "#1C1C1C"))
            }
            
            Spacer()
        }
            
            Divider()
                .frame(height: 1)
                .background(Color(hex: "#EAEBEB"))
                .opacity(0.2)
                .padding(.top, 12)
                .padding(.leading, 48)
        }
    }
}

//MARK: - Preview

struct PaymentsInfoView_Previews: PreviewProvider {
    
    static var previews: some View {
        
        Group {
            
            PaymentsInfoView(viewModel:.sampleParameter)
                .previewLayout(.fixed(width: 375, height: 156))
                .previewDisplayName("Parameter")
            
            PaymentsInfoView(viewModel:.sample)
                .previewLayout(.fixed(width: 375, height: 156))
        }
    }
}

//MARK: - Preview Content

extension PaymentsInfoView.ViewModel {
    
    static let sample = PaymentsInfoView.ViewModel(icon: Image("Payments List Sample"), title: "Основание", content: "Налог на имущество физических лиц, взимаемый по ставкам, применяемым к объектам налогообложения, расположенным в границах внутригородских муниципальных образований городов федерального значения (сумма платеж...)")
    
    static let sampleParameter = try! PaymentsInfoView.ViewModel(with: .init(.init(id: UUID().uuidString, value: "УФК по г. Москве (ИФНС России №26 по г. Москве)"), icon: .empty, title: "Получатель платежа"))
}
