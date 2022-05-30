//
//  DocumentCellViewComponent.swift
//  ForaBank
//
//  Created by Mikhail on 22.04.2022.
//

import SwiftUI

//MARK: - ViewModel

enum DocumentCellType {
    
    case passport
    case inn
    case adressPass
    case adress
    
    var viewModel: DocumentCellTypeModel {
        
        switch self {
            
        case .passport:
            return .init(icon: .ic24Passport,
                         iconBackground: .bGIconDeepPurpleMedium,
                         background: Color(hex: "8676A2"))
        case .inn:
            return .init(icon: .ic24FileHash,
                         iconBackground: .bGIconTealLight,
                         background: Color(hex: "8676A2"))
        case .adressPass:
            return .init(icon: .ic24Home,
                         iconBackground: .bGIconDeepPurpleMedium,
                         background: Color(hex: "8676A2"))
        case .adress:
            return .init(icon: .ic24MapPin,
                         iconBackground: .bGIconBlueLightest,
                         background: Color(hex: "629FBB"))
        }
    }
    
    struct DocumentCellTypeModel {
        
        let icon: Image
        let iconBackground: Color
        let background: Color
    }
}

extension DocumentCellView {
    
    class ViewModel: AccountCellDefaultViewModel, ObservableObject {
              
        let itemType: DocumentCellType
        let action: () -> Void
        
        internal init(id: UUID = UUID(), itemType: DocumentCellType, content: String, title: String? = nil, action: @escaping () -> Void) {
            
            self.action = action
            self.itemType = itemType
            super.init(id: id, icon: itemType.viewModel.icon, content: content, title: title)
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
                            .foregroundColor(viewModel.itemType.viewModel.iconBackground)
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
                    
                    if let placeholder = viewModel.title {
                        
                        Text(verbatim: placeholder)
                            .font(.textBodyMR14200())
                            .foregroundColor(.textPlaceholder)
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
        content: "Паспорт РФ",
        title: "38 06 ****75",
        action: {})
    
    static let inn = DocumentCellView.ViewModel(
        itemType: .inn,
        content: "ИНН",
        title: "6525****3942",
        action: {})
    
    static let address = DocumentCellView.ViewModel(
        itemType: .adressPass,
        content: "Адрес регистрации",
        title: "г. Москва, Кут.",
        action: {})
    
    static let address2 = DocumentCellView.ViewModel(
        itemType: .adress,
        content: "Адрес проживания",
        title: "г. Москва, Кут.",
        action: {})
    
}
