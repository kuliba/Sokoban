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
        let iconStyle: IconStyle
        
        //TODO: real placeholder required
        private static let iconPlaceholder = Image("Payments Icon Placeholder")

        init(icon: Image, title: String, content: String, iconStyle: IconStyle, source: PaymentsParameterRepresentable = Payments.ParameterMock(id: UUID().uuidString)) {
            
            self.icon = icon
            self.title = title
            self.content = content
            self.iconStyle = iconStyle
            super.init(source: source)
        }
        
        init(with parameterInfo: Payments.ParameterInfo) {
            
            self.icon = parameterInfo.icon.image ?? Self.iconPlaceholder
            self.title = parameterInfo.title
            self.content = parameterInfo.parameter.value ?? ""
            self.iconStyle = .init(with: parameterInfo.icon)
            super.init(source: parameterInfo)
        }
        
        enum IconStyle {
            
            case small
            case large
            
            init(with imageData: ImageData) {
                
                if let uiImage = imageData.uiImage, uiImage.size.width / UIScreen.main.scale < 32 {
                    
                    self = .small
                    
                } else {
                    
                    self = .large
                }
            }
        }
    }
}

//MARK: - View

struct PaymentsInfoView: View {
    
    let viewModel: PaymentsInfoView.ViewModel
    
    var body: some View {
        
        switch viewModel.iconStyle {
        case .small:
            VStack {
                
                HStack(alignment: .top, spacing: 20) {
                    
                    viewModel.icon
                        .resizable()
                        .frame(width: 24, height: 24)
                        .padding(.top, 16)
                        .padding(.leading, 4)
                    
                    VStack(alignment: .leading, spacing: 4)  {
                        
                        Text(viewModel.title)
                            .font(.textBodySR12160())
                            .foregroundColor(.textPlaceholder)
                        
                        Text(viewModel.content)
                            .font(.textBodyMR14200())
                            .foregroundColor(.textSecondary)
                    }
                    
                    Spacer()
                }
                
                Divider()
                    .frame(height: 1)
                    .background(Color.bordersDivider)
                    .opacity(0.2)
                    .padding(.top, 12)
                    .padding(.leading, 44)
            }
            
        case .large:
            VStack {
                
                HStack(alignment: .top, spacing: 16) {
                    
                    viewModel.icon
                        .resizable()
                        .frame(width: 32, height: 32)
                        .padding(.top, 12)
                    
                    VStack(alignment: .leading, spacing: 4)  {
                        
                        Text(viewModel.title)
                            .font(.textBodySR12160())
                            .foregroundColor(.textPlaceholder)
                        
                        Text(viewModel.content)
                            .font(.textBodyMM14200())
                            .foregroundColor(.textSecondary)
                    }
                    
                    Spacer()
                }
                
                Divider()
                    .frame(height: 1)
                    .background(Color.bordersDivider)
                    .opacity(0.2)
                    .padding(.top, 12)
                    .padding(.leading, 48)
            }
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
    
    static let sample = PaymentsInfoView.ViewModel(icon: Image("Payments List Sample"), title: "Основание", content: "Налог на имущество физических лиц, взимаемый по ставкам, применяемым к объектам налогообложения, расположенным в границах внутригородских муниципальных образований городов федерального значения (сумма платеж...)", iconStyle: .large)
    
    static let sampleParameter = PaymentsInfoView.ViewModel(with: .init(.init(id: UUID().uuidString, value: "УФК по г. Москве (ИФНС России №26 по г. Москве)"), icon: .parameterLocation, title: "Получатель платежа"))
}
