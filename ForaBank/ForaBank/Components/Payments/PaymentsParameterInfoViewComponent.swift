//
//  PaymentsParameterInfoViewComponent.swift
//  ForaBank
//
//  Created by Константин Савялов on 07.02.2022.
//

import SwiftUI

//MARK: - ViewModel

extension PaymentsParameterInfoView {
    
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
            self.content = parameterInfo.content
            super.init(source: parameterInfo)
        }
    }
}

//MARK: - View

struct PaymentsParameterInfoView: View {
    
    let viewModel: PaymentsParameterInfoView.ViewModel
    
    var body: some View {
        
        HStack(alignment: .top, spacing: 16) {
            
            viewModel.icon
                .resizable()
                .frame(width: 40, height: 40)
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
    }
}

//MARK: - Preview

struct PaymentsParameterInfoView_Previews: PreviewProvider {
    
    static var previews: some View {
        
        Group {
            
            PaymentsParameterInfoView(viewModel:.sampleParameter)
                .previewLayout(.fixed(width: 375, height: 156))
                .previewDisplayName("Parameter")
            
            PaymentsParameterInfoView(viewModel:.sample)
                .previewLayout(.fixed(width: 375, height: 156))
        }
    }
}

//MARK: - Preview Content

extension PaymentsParameterInfoView.ViewModel {
    
    static let sample = PaymentsParameterInfoView.ViewModel(icon: Image("Payments List Sample"), title: "Основание", content: "Налог на имущество физических лиц, взимаемый по ставкам, применяемым к объектам налогообложения, расположенным в границах внутригородских муниципальных образований городов федерального значения (сумма платеж...)")
    
    static let sampleParameter = try! PaymentsParameterInfoView.ViewModel(with: .init(.init(id: UUID().uuidString, value: "a3_address_2_2"), icon: .empty, title: "Получатель платежа", content: "УФК по г. Москве (ИФНС России №26 по г. Москве)"))
}
