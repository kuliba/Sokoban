//
//  ButtonAuthView.swift
//  ForaBank
//
//  Created by Pavel Samsonov on 23.11.2022.
//

import SwiftUI

// MARK: - ViewModel

extension ButtonAuthView {
    
    class ViewModel: ObservableObject, Identifiable {
        
        var id: ButtonType
        let icon: Image
        let title: String
        let subTitle: String
        let action: () -> Void
        
        init(id: ButtonType, icon: Image, title: String, subTitle: String, action: @escaping () -> Void) {
            
            self.id = id
            self.icon = icon
            self.title = title
            self.subTitle = subTitle
            self.action = action
        }
        
        convenience init(_ buttonType: ButtonType, action: @escaping () -> Void) {
            
            self.init(
                id: buttonType,
                icon: buttonType.icon,
                title: buttonType.title,
                subTitle: buttonType.subTitle,
                action: action
            )
        }
    }
}

extension ButtonAuthView.ViewModel {
    
    enum ButtonType {
        
        case abroad
        case card
        
        var icon: Image {
            
            switch self {
            case .abroad: return .init("Abroad Auth")
            case .card: return .init("Card Auth")
            }
        }
        
        var title: String {
            
            switch self {
            case .abroad: return "Переводы за рубеж"
            case .card: return "Нет карты?"
            }
        }
        
        var subTitle: String {
            
            switch self {
            case .abroad: return "Быстро и безопасно"
            case .card: return "Доставим в любую точку"
            }
        }
    }
}

// MARK: - View

struct ButtonAuthView: View {
    
    @ObservedObject var viewModel: ButtonAuthView.ViewModel
    
    var body: some View {
        
        Button(action: viewModel.action) {
            
            ZStack(alignment: .leading) {
                
                RoundedRectangle(cornerRadius: 12)
                    .foregroundColor(.mainColorsGrayLightest)
                
                HStack(spacing: 20) {
                    
                    viewModel.icon
                    
                    VStack(alignment: .leading, spacing: 4) {

                        Text(viewModel.title)
                            .font(.textH4M16240())
                            .foregroundColor(.mainColorsBlack)

                        Text(viewModel.subTitle)
                            .font(.textBodyMR14180())
                            .foregroundColor(.mainColorsGray)
                    }
                    
                }.padding(.horizontal, 20)
                
            }.frame(height: 108)
        }
    }
}

// MARK: - Preview

struct ButtonAuthView_Previews: PreviewProvider {
    
    static var previews: some View {
        
        Group {
            
            ButtonAuthView(viewModel: .init(.abroad, action: {}))
            ButtonAuthView(viewModel: .init(.card, action: {}))
        }
        .previewLayout(.sizeThatFits)
        .padding(8)
    }
}
