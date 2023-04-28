//
//  PaymentsInfoViewComponent.swift
//  ForaBank
//
//  Created by Константин Савялов on 07.02.2022.
//

import SwiftUI

//MARK: - ViewModel

extension PaymentsInfoView {
    
    class ViewModel: PaymentsParameterViewModel, ObservableObject {
        
        let icon: Image
        let title: String
        let content: String
        let iconStyle: IconStyle
        let lineLimit: Int?
        
        //TODO: real placeholder required
        private static let iconPlaceholder = Image("Payments Icon Placeholder")

        init(icon: Image, title: String, content: String, iconStyle: IconStyle, lineLimit: Int? = nil, source: PaymentsParameterRepresentable = Payments.ParameterMock(id: UUID().uuidString)) {
            
            self.icon = icon
            self.title = title
            self.content = content
            self.iconStyle = iconStyle
            self.lineLimit = lineLimit
            super.init(source: source)
        }
        
        init(with parameterInfo: Payments.ParameterInfo) {
            
            self.icon = parameterInfo.icon.image ?? Self.iconPlaceholder
            self.title = parameterInfo.title
            self.content = parameterInfo.parameter.value ?? ""
            self.iconStyle = .init(with: parameterInfo.icon)
            self.lineLimit = parameterInfo.lineLimit
            super.init(source: parameterInfo)
        }
        
        enum IconStyle {
            
            case small
            case large
            
            init(with imageData: ImageData) {
                
                if let uiImage = imageData.uiImage,
                   uiImage.size.width / UIScreen.main.scale < 32 {
                    
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
    var isCompact: Bool = false
    
    var body: some View {
        
        if isCompact == true {
            
            HStack {
                
                Text(viewModel.title)
                    .font(.textBodyMR14200())
                    .foregroundColor(.textPlaceholder)
                
                Spacer()
                
                if viewModel.content != "" {
                    
                    Text(viewModel.content)
                        .font(.textBodyMR14180())
                        .lineLimit(1)
                        .foregroundColor(.textSecondary)
                }
            }
            .padding(.leading, 13)
            .padding(.trailing, 25)
            
        } else {
           
            switch viewModel.iconStyle {
            case .small:
                HStack(alignment: .top, spacing: 20) {
                    
                    viewModel.icon
                        .resizable()
                        .renderingMode(.template)
                        .foregroundColor(.mainColorsGray)
                        .frame(width: 24, height: 24)
                        .padding(.top, 16)
                        .padding(.leading, 4)
                    
                    VStack(alignment: .leading, spacing: 4)  {
                        
                        Text(viewModel.title)
                            .font(.textBodySR12160())
                            .foregroundColor(.textPlaceholder)
                        
                        Text(viewModel.content)
                            .font(.textBodyMR14200())
                            .lineLimit(viewModel.lineLimit)
                            .foregroundColor(.textSecondary)
                    }
                    
                    Spacer()
                }
                .padding(.vertical, 13)
                .padding(.horizontal, 12)
                
            case .large:
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
                            .lineLimit(viewModel.lineLimit)
                            .foregroundColor(.textSecondary)
                    }
                    
                    Spacer()
                }
                .padding(.vertical, 13)
                .padding(.horizontal, 12)
            }
        }
    }
}

extension PaymentsInfoView {
    
    enum Style {
        
        case single
        case group
    }
}

//MARK: - Preview

struct PaymentsInfoView_Previews: PreviewProvider {
    
    static var previews: some View {
        
        Group {

            PaymentsInfoView(viewModel: .sample, isCompact: false)
                .previewLayout(.fixed(width: 375, height: 190))
            
            PaymentsInfoView(viewModel: .sampleParameter, isCompact: false)
                .previewLayout(.fixed(width: 375, height: 100))
            
            PaymentsInfoView(viewModel: .sampleParameter, isCompact: true)
                .previewLayout(.fixed(width: 375, height: 80))
            
            PaymentsGroupView(viewModel: .sampleSingleInfo)
                .previewLayout(.fixed(width: 375, height: 140))
            
            PaymentsInfoGroupView(viewModel: .sampleInfo)
                .previewLayout(.fixed(width: 375, height: 100))
        }
    }
}

//MARK: - Preview Content

extension PaymentsInfoView.ViewModel {
    
    static let sample = PaymentsInfoView.ViewModel(icon: Image("Payments List Sample"), title: "Основание", content: "Налог на имущество физических лиц, взимаемый по ставкам, применяемым к объектам налогообложения, расположенным в границах внутригородских муниципальных образований городов федерального значения (сумма платеж...)", iconStyle: .large, lineLimit: 1)
    
    static let sampleParameter = PaymentsInfoView.ViewModel(with: .init(.init(id: UUID().uuidString, value: "УФК по г. Москве (ИФНС России №26 по г. Москве)"), icon: .parameterLocation, title: "Получатель платежа"))
    
    static let sampleGroupOne = PaymentsInfoView.ViewModel(with: .init(.init(id: UUID().uuidString, value: "123563470"), icon: .parameterLocation, title: "Номер перевода"))
    
    static let sampleGroupTwo = PaymentsInfoView.ViewModel(with: .init(.init(id: UUID().uuidString, value: "100 $"), icon: .parameterLocation, title: "Сумма перевода"))
    
    static let sampleGroupThree = PaymentsInfoView.ViewModel(with: .init(.init(id: UUID().uuidString, value: "50 ₽"), icon: .parameterLocation, title: "Комиссия"))
    
    static let sampleGroupFour = PaymentsInfoView.ViewModel(with: .init(.init(id: UUID().uuidString, value: "7050 ₽"), icon: .parameterLocation, title: "Сумма списания"))
}

extension PaymentsGroupViewModel {
    
    static let sampleInfo = PaymentsInfoGroupViewModel(items: [PaymentsInfoView.ViewModel.sampleParameter])
}
