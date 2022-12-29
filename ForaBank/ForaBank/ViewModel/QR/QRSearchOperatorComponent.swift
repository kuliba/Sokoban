//
//  QRSearchOperatorComponent.swift
//  ForaBank
//
//  Created by Константин Савялов on 12.12.2022.
//

import SwiftUI

extension QRSearchOperatorComponent {
    
    class ViewModel: Identifiable {
    
        let id: String?
        let image: ImageData?
        let title: String
        let description: String?
        
        init(id: String, image: ImageData?, title: String, description: String?) {
            self.id = id
            self.image = image
            self.title = title
            self.description = description
        }
        
        convenience init (operators: OperatorGroupData.OperatorData) {
            
            self.init(id: UUID().uuidString, image: operators.iconImageData, title: operators.title, description: operators.description)
        }
    }
}

struct QRSearchOperatorComponent: View {
    
    let viewModel: QRSearchOperatorComponent.ViewModel
    
    var body: some View {
        HStack(spacing: 20) {
            
            if let image = viewModel.image?.image {
                image
                    .resizable()
                    .frame(width: 40, height: 40)
            } else  {
                Spacer().frame(width: 40, height: 40)
            }
            
            VStack(alignment: .leading, spacing: 4) {
                
                Text(viewModel.title)
                    .font(Font.textH4M16240())
                    .foregroundColor(.black)
                
                if let description = viewModel.description {
                    Text(description)
                        .font(Font.textBodySR12160())
                }
            }
        } .padding(.horizontal, 20)
    }
}

struct QRSearchOperatorComponent_Previews: PreviewProvider {
    static var previews: some View {
        QRSearchOperatorComponent(viewModel: .init(id: "0", image: ImageData(with: .checkmark)!, title: "MosObl", description: "123123123"))
    }
}

