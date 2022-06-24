//
//  ButtonNewProductComponent.swift
//  ForaBank
//
//  Created by Андрей Лятовец on 04.03.2022.
//

import SwiftUI

//MARK: - ViewModel

extension ButtonNewProduct {
    
    struct ViewModel: Identifiable {
        
        let id: UUID
        let icon: Image
        let title: String
        let subTitle: String
        let action: () -> Void
        
        internal init(id: UUID = UUID(), icon: Image, title: String, subTitle: String, action: @escaping () -> Void) {
            
            self.id = id
            self.icon = icon
            self.title = title
            self.subTitle = subTitle
            self.action = action
        }
    }
}

//MARK: - View

struct ButtonNewProduct: View {
    
    var viewModel: ViewModel
    
    var body: some View {
        
        Button(action: viewModel.action) {
            
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
                }
                .padding(11)
            }

        }.buttonStyle(PushButtonStyle())
    }
}

//MARK: - Preview

struct ButtonNewProduct_Previews: PreviewProvider {
    
    static var previews: some View {
        
        Group {
            
            ButtonNewProduct(viewModel: .sample)
                .previewLayout(.fixed(width: 112, height: 124))
            
            ButtonNewProduct(viewModel: .sampleEmptySubtitle)
                .previewLayout(.fixed(width: 112, height: 124))
            
            ButtonNewProduct(viewModel: .sampleLongSubtitle)
                .previewLayout(.fixed(width: 112, height: 124))
        }
    }
}

//MARK: - Preview Content

extension ButtonNewProduct.ViewModel {
    
    static let sample =  ButtonNewProduct.ViewModel.init(icon: .ic24NewCardColor, title: "Карту", subTitle: "62 дня без %", action: {})
    
    static let sampleEmptySubtitle =  ButtonNewProduct.ViewModel.init(icon: .ic24NewCardColor, title: "Карту", subTitle: "", action: {})
    
    static let sampleLongSubtitle =  ButtonNewProduct.ViewModel.init(icon: .ic24NewCardColor, title: "Карту", subTitle: "13,08 % годовых", action: {})
}
