//
//  ContactsBankPrefferedItemViewComponent.swift
//  ForaBank
//
//  Created by Max Gribov on 11.11.2022.
//

import SwiftUI

//MARK: - View Model

extension ContactsBankPrefferedItemView {
    
    class ViewModel: ContactsItemViewModel {
        
        let id: BankData.ID
        let icon: Image?
        let name: String
        let isFavorite: Bool
        let contactName: String?
        let action: () -> Void
        
        init(id: BankData.ID, icon: Image?, name: String, isFavorite: Bool, contactName: String?, action: @escaping () -> Void) {
            
            self.id = id
            self.icon = icon
            if name.count > 12 {
                
                self.name = "\(name.prefix(12))."
            } else {
                
                self.name = name
            }
            self.isFavorite = isFavorite
            
            if let contactName = contactName {
                
                self.contactName = "\(contactName.prefix(12))."
            } else {
                
                self.contactName = nil
            }
            
            self.action = action
        }
    }
}

//MARK: - View

struct ContactsBankPrefferedItemView: View {
    
    let viewModel: ViewModel
    
    var body: some View {
        
        Button(action: viewModel.action) {
            
            VStack(spacing: 8) {
                
                if let icon = viewModel.icon {
                    
                    icon
                        .resizable()
                        .frame(width: 56, height: 56)
                        .cornerRadius(90)
                        .overlay(FavoritesIcon(isFavorite: viewModel.isFavorite).offset(x: 20, y: -16))
                    
                } else {
                    
                    Circle()
                        .foregroundColor(.mainColorsGrayLightest)
                        .frame(width: 56, height: 56)
                        .overlay(FavoritesIcon(isFavorite: viewModel.isFavorite).offset(x: 20, y: -16))
                }
                
                VStack(spacing: 4) {
                    
                    if let contactName = viewModel.contactName {
                        
                        Text(contactName)
                            .font(.textBodyXSSB11140())
                            .foregroundColor(Color.textSecondary)
                    }
                    
                    Text(viewModel.name)
                        .foregroundColor(Color.textPlaceholder)
                        .font(.textBodyXSR11140())
                }
            }
        }
    }
}

//MARK: - Internal Views

extension ContactsBankPrefferedItemView {
    
    struct FavoritesIcon: View {
        
        let isFavorite: Bool
        
        var body: some View {
            
            if isFavorite == true {
                
                ZStack {
                    
                    Circle()
                        .foregroundColor(.mainColorsBlack)
                    
                    Image.ic24Star
                        .resizable()
                        .frame(width: 16, height: 16, alignment: .center)
                        .foregroundColor(Color.mainColorsWhite)
                    
                }
                .frame(width: 24, height: 24)
                
            } else {
                
                Color.clear
                    .frame(width: 24, height: 24)
            }
        }
    }
}

//MARK: - Preview

struct ContactsBankPrefferedItemView_Previews: PreviewProvider {
    
    static var previews: some View {
        
        Group {
            
            ContactsBankPrefferedItemView(viewModel: .sample)
                .previewLayout(.fixed(width: 120, height: 120))
            
            ContactsBankPrefferedItemView(viewModel: .sampleFavorite)
                .previewLayout(.fixed(width: 120, height: 120))
            
            ContactsBankPrefferedItemView(viewModel: .sampleContact)
                .previewLayout(.fixed(width: 120, height: 100))
        }
    }
}

//MARK: - Preview Content

extension ContactsBankPrefferedItemView.ViewModel {
    
    static let sample = ContactsBankPrefferedItemView.ViewModel(id: UUID().uuidString, icon: Image("Bank Logo Sample"), name: "Сбербанк", isFavorite: false, contactName: nil, action: {})
    
    static let sampleFavorite = ContactsBankPrefferedItemView.ViewModel(id: UUID().uuidString, icon: Image("Bank Logo Sample"), name: "Сбербанк", isFavorite: true, contactName: nil, action: {})
    
    static let sampleContact = ContactsBankPrefferedItemView.ViewModel(id: UUID().uuidString, icon: Image("Bank Logo Sample"), name: "Сбербанк", isFavorite: false, contactName: "Иванов И.", action: {})
}
