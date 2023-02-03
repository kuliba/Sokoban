//
//  QRSearchItemComponent.swift
//  ForaBank
//
//  Created by Константин Савялов on 18.11.2022.
//

import SwiftUI

//MARK: - ViewModel

extension QRSearchItemView {
    
    class ViewModel: Identifiable, Equatable {
        
        let id: UUID
        let icon: Image
        let title: String
        let content: String
        let model: Model

        internal init(id: UUID = UUID(), icon: Image, title: String, content: String, model: Model = .emptyMock) {
            
            self.id = id
            self.icon = icon
            self.title = title
            self.content = content
            self.model = model
        }
        
        static func == (lhs: QRSearchItemView.ViewModel, rhs: QRSearchItemView.ViewModel) -> Bool {
            lhs.id == rhs.id
        }
    }
}

//MARK: - View

struct QRSearchItemView: View {
    
    let viewModel: QRSearchItemView.ViewModel
    
    var body: some View {
        
        HStack(alignment: .top, spacing: 20) {
            
            VStack(alignment: .center) {
                
                ZStack {
                    
                    Circle()
                        .frame(width: 40, height: 40)
                        .foregroundColor(.bGIconRedLight)
                    
                    viewModel.icon
                        .resizable()
                        .frame(width: 24, height: 24)
                        .foregroundColor(.iconWhite)
                }
                
                Spacer()
            }
            
            VStack(alignment: .leading, spacing: 6)  {
                
                Text(viewModel.title)
                    .font(.textH4M16240())
                    .foregroundColor(.textSecondary)
                
                Text(viewModel.content)
                    .font(.textBodySR12160())
                    .foregroundColor(.gray)
                    .lineLimit(2)
            }
            Spacer()
        }
    }
}

//MARK: - Preview

struct QRSearchItemComponentView_Previews: PreviewProvider {
    
    static var previews: some View {
        
        QRSearchItemView(viewModel:.sample)
            .previewLayout(.fixed(width: 375, height: 100))
    }
}

//MARK: - Preview Content

extension QRSearchItemView.ViewModel {
    
    static let sample = QRSearchItemView.ViewModel(icon: Image.ic24MoreHorizontal, title: "МосЭнерго", content: "ИНН 7702070139")
}

