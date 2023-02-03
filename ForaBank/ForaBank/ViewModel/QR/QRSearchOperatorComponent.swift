//
//  QRSearchOperatorComponent.swift
//  ForaBank
//
//  Created by Константин Савялов on 12.12.2022.
//

import SwiftUI

extension QRSearchOperatorComponent {
    
    class ViewModel: Identifiable {
    
        let id: String
        let image: ImageData?
        let title: String
        let description: String?
        let action: (String) -> Void
        
        init(id: String, image: ImageData?, title: String, description: String?, action: @escaping (String) -> Void) {
            
            self.id = id
            self.image = image
            self.title = title
            self.description = description
            self.action = action
        }
        
        convenience init(id: String, operators: OperatorGroupData.OperatorData, action: @escaping (String) -> Void) {
            
            self.init(id: id, image: operators.iconImageData, title: operators.title, description: operators.description, action: action)
        }
    }
}

struct QRSearchOperatorComponent: View {
    
    let viewModel: QRSearchOperatorComponent.ViewModel
    
    var body: some View {
        
        Button(action: { viewModel.action(viewModel.id.description) }) {
            
            HStack(spacing: 20) {
                
                if let image = viewModel.image?.image {
                    
                    image
                        .resizable()
                        .frame(width: 40, height: 40)
                    
                } else  {
                    
                    Spacer()
                        .frame(width: 40, height: 40)
                }
                
                VStack(alignment: .leading, spacing: 8) {
                    
                    Text(viewModel.title)
                        .font(Font.textH4M16240())
                        .foregroundColor(.black)
                        .multilineTextAlignment(.leading)
                    
                    if let description = viewModel.description {
                        Text(description)
                            .foregroundColor(.textPlaceholder)
                            .font(Font.textBodySR12160())
                    }
                }
                
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 8)
        }
    }
}

struct QRSearchOperatorComponent_Previews: PreviewProvider {
    static var previews: some View {
        
        QRSearchOperatorComponent(viewModel: .init(id: "0", image: ImageData(with: .checkmark)!, title: "Мосэнергосбытde (произвольная сумма)", description: "7701208190", action: {_ in }))
    }
}

