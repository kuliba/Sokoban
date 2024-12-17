//
//  DocumentCellViewComponent.swift
//  ForaBank
//
//  Created by Mikhail on 22.04.2022.
//

import SwiftUI

//MARK: - ViewModel


extension DocumentCellView {
    
    class ViewModel: AccountCellDefaultViewModel, ObservableObject {
              
        let itemType: DocumentCellType
        let action: () -> Void
        
        internal init(id: UUID = UUID(), itemType: DocumentCellType, content: String, action: @escaping () -> Void) {
            
            self.action = action
            self.itemType = itemType
            super.init(id: id, icon: itemType.icon, content: itemType.title, title: content)
        }
        
    }
}

//MARK: - View

struct DocumentCellView: View {
    
    @ObservedObject var viewModel: ViewModel
    
    var body: some View {
        
        Button {
            
            viewModel.action()
            
        } label: {
            
            VStack(alignment: .leading, spacing: 0) {
                
                HStack {
                    
                    ZStack {
                        
                        RoundedRectangle(cornerRadius: 20)
                            .foregroundColor(viewModel.itemType.iconBackground)
                            .frame(width: 40, height: 40)
                        
                        viewModel.icon
                            .foregroundColor(.iconWhite)
                    }
                    
                    Spacer()
                }
                
                Spacer()
                
                VStack(alignment: .leading, spacing: 4) {
                    
                    Text(verbatim: viewModel.content)
                        .font(.textBodyMM14200())
                        .foregroundColor(.textSecondary)
                        .multilineTextAlignment(.leading)
                        .lineLimit(2)
                    
                    if let placeholder = viewModel.title {
                        
                        Text(verbatim: placeholder)
                            .font(.textBodyMR14200())
                            .foregroundColor(.textPlaceholder)
                            .lineLimit(1)
                    }
                }
            }
            .padding(12)
            .frame(width: 132, height: 134)
            .background(RoundedRectangle(cornerRadius: 8)
                .foregroundColor(.mainColorsGrayLightest))
        }
    }
}

//MARK: - Preview

struct DocumentCellView_Previews: PreviewProvider {
    
    static var previews: some View {
        
        Group {
            DocumentCellView(viewModel: .passport)
                .previewLayout(.fixed(width: 175, height: 180))
            
            DocumentCellView(viewModel: .inn)
                .previewLayout(.fixed(width: 175, height: 180))
            
            DocumentCellView(viewModel: .address)
                .previewLayout(.fixed(width: 175, height: 180))
            
            DocumentCellView(viewModel: .address2)
                .previewLayout(.fixed(width: 175, height: 180))
        }
    }
}

//MARK: - Preview Content

extension DocumentCellView.ViewModel {
    
    static let passport = DocumentCellView.ViewModel(
        itemType: .passport,
        content: "38 06 ****75",
        action: {})
    
    static let inn = DocumentCellView.ViewModel(
        itemType: .inn,
        content: "6525****3942",
        action: {})
    
    static let address = DocumentCellView.ViewModel(
        itemType: .adressPass,
        content: "г. Москва, Кут.",
        action: {})
    
    static let address2 = DocumentCellView.ViewModel(
        itemType: .adress,
        content: "г. Москва, Кут.",
        action: {})
    
}
