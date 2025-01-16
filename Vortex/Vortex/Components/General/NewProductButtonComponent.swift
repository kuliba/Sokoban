//
//  NewProductButtonComponent.swift
//  Vortex
//
//  Created by Андрей Лятовец on 04.03.2022.
//

import SwiftUI

//MARK: - ViewModel

extension NewProductButton {
    
    class ViewModel: Identifiable, ObservableObject {
        
        let id: String 
        let icon: Image
        let title: String
        @Published var subTitle: String
        let tapActionType: TapActionType
        
        enum TapActionType {
            
            case action(() -> Void)
            case url(URL)
        }
        
        init(id: String = UUID().description, icon: Image, title: String, subTitle: String, action: @escaping () -> Void) {
            
            self.id = id
            self.icon = icon
            self.title = title
            self.subTitle = subTitle
            self.tapActionType = .action(action)
        }
        
        init(id: String = UUID().description, icon: Image, title: String, subTitle: String, url: URL) {
            
            self.id = id
            self.icon = icon
            self.title = title
            self.subTitle = subTitle
            self.tapActionType = .url(url)
        }
        
        init(
            openProductType: OpenProductType,
            subTitle: String,
            action: TapActionType
        ) {
            self.id = openProductType.rawValue
            self.icon = openProductType.openButtonIcon
            self.title = openProductType.openButtonTitle
            self.subTitle = subTitle
            self.tapActionType = action
        }
    }
}

//MARK: - View

struct NewProductButton: View {
    
    @ObservedObject var viewModel: ViewModel
    
    var body: some View {
        
        switch viewModel.tapActionType {
        case let .action(action):
            Button(action: action) {
                
                ZStack(alignment: .leading) {
                    
                    RoundedRectangle(cornerRadius: 12)
                        .foregroundColor(.mainColorsGrayLightest)
                    
                    VStack(alignment: .leading) {
                        
                        viewModel.icon
                            .renderingMode(.original)
                        
                        Spacer()
                        
                        VStack(alignment: .leading, spacing: 4) {
                            
                            Text(viewModel.title)
                                .font(.textBodyMM14200())
                                .foregroundColor(.textSecondary)
                            
                            Text(viewModel.subTitle)
                                .font(.textBodyMR14200())
                                .foregroundColor(.textPlaceholder)
                                .lineLimit(1)
                        }
                        
                    }.padding(11)
                }

            }
            .buttonStyle(PushButtonStyle())
            .accessibilityIdentifier("buttonOpenNewProduct")
            
        case let .url(url):
            
            Link(destination: url) {
                
                ZStack(alignment: .leading) {
                    
                    RoundedRectangle(cornerRadius: 12)
                        .foregroundColor(.mainColorsGrayLightest)
                    
                    VStack(alignment: .leading) {
                        
                        viewModel.icon
                            .renderingMode(.original)
                        
                        Spacer()
                        
                        VStack(alignment: .leading, spacing: 4) {
                            
                            Text(viewModel.title)
                                .font(.textBodyMM14200())
                                .foregroundColor(.textSecondary)
                            
                            Text(viewModel.subTitle)
                                .font(.textBodyMR14200())
                                .foregroundColor(.textPlaceholder)
                                .lineLimit(1)
                        }
                        
                    }.padding(11)
                }
                
            }
            .buttonStyle(PushButtonStyle())
            .accessibilityIdentifier("linkOpenNewProduct")
        }
    }
}

//MARK: - Preview

struct NewProductButton_Previews: PreviewProvider {
    
    static var previews: some View {
        
        Group {
            
            NewProductButton(viewModel: .sample)
                .previewLayout(.fixed(width: 112, height: 124))
            
            NewProductButton(viewModel: .sampleEmptySubtitle)
                .previewLayout(.fixed(width: 112, height: 124))
            
            NewProductButton(viewModel: .sampleLongSubtitle)
                .previewLayout(.fixed(width: 140, height: 80))
        }
    }
}

//MARK: - Preview Content

extension NewProductButton.ViewModel {
    
    static let sample =  NewProductButton.ViewModel.init(id: "CARD", icon: .ic24NewCardColor, title: "Карту", subTitle: "62 дня без %", action: {})
    
    static let sampleAccount =  NewProductButton.ViewModel.init(id: "ACCOUNT", icon: .ic24FilePluseColor, title: "Счет", subTitle: "Бесплатно", action: {})
    
    static let sampleEmptySubtitle =  NewProductButton.ViewModel.init(id: "CARD", icon: .ic24NewCardColor, title: "Карту", subTitle: "", action: {})
    
    static let sampleLongSubtitle =  NewProductButton.ViewModel.init(id: "CARD", icon: .ic24NewCardColor, title: "Карту", subTitle: "13,08 % годовых", action: {})
}
