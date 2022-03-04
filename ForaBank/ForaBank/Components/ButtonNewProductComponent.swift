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
        
        var id: UUID
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
        
        static func == (lhs: ViewModel, rhs: ViewModel) -> Bool {
            
            lhs.id == rhs.id
        }
    }
}

//MARK: - View

struct ButtonNewProduct: View {
    
    var viewModel: ViewModel
    
    var body: some View {
        
        Button {

            viewModel.action()
            
        } label: {
            
            ZStack {
                
                RoundedRectangle(cornerRadius: 12)
                    .foregroundColor(.mainColorsGrayLightest)
                
                
                VStack(alignment: .leading) {

                    viewModel.icon
                        .renderingMode(.original)
                        .padding(.leading, 12)
                        .padding(.top, 12)
                        .padding(.bottom, 36)
                        .frame(alignment: .leading)

                    VStack(alignment: .leading, spacing: 4) {

                        Text(verbatim: viewModel.title)
                            .font(.textBodyMM14200())
                                .foregroundColor(.textSecondary)
                                .frame(alignment: .leading)

                        Text(verbatim: viewModel.subTitle)
                            .font(.textBodyMR14200())
                                .foregroundColor(.gray)
                                .frame(alignment: .leading)
                    }
                    .padding(.leading, 12)
                    .padding(.trailing, 10)
                    .padding(.bottom, 12)
                }
            }
            .frame(width: 112, height: 124)
        }
    }
}

//MARK: - Preview

struct ButtonNewProduct_Previews: PreviewProvider {
    
    static var previews: some View {
        
        Group {
            ButtonNewProduct(viewModel: .sample)
        }
    }
}

//MARK: - Preview Content

extension ButtonNewProduct.ViewModel {
    
    static let sample =  ButtonNewProduct.ViewModel.init(icon: .ic24NewCardColor,
                                                         title: "Карту",
                                                         subTitle: "62 дня без %",
                                                         action: {})
}
