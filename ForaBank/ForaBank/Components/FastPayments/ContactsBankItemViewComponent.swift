//
//  ContactsBankItemViewComponent.swift
//  ForaBank
//
//  Created by Max Gribov on 11.11.2022.
//

import SwiftUI

//MARK: - View Model

extension ContactsBankItemView {
    
    class ViewModel: ContactsItemViewModel {

        let id: String
        let icon: Image?
        let name: String
        let subtitle: String?
        let type: BankType
        let action: () -> Void
        
        init(id: String = UUID().description, icon: Image?, name: String, subtitle: String?, type: BankType, action: @escaping () -> Void) {
            
            self.id = id
            self.icon = icon
            self.name = name
            self.subtitle = subtitle
            self.type = type
            self.action = action
        }
    }
}

//MARK: - View

struct ContactsBankItemView: View {
    
    let viewModel: ViewModel
    
    var body: some View {
        
        Button(action: viewModel.action){
            
            HStack(alignment: .center, spacing: 20) {
                
                if let icon = viewModel.icon {
                    
                    icon
                        .resizable()
                        .frame(width: 40, height: 40)
                        .cornerRadius(90)
                    
                } else {
                    
                    Circle()
                        .foregroundColor(.mainColorsGrayLightest)
                        .frame(width: 40, height: 40)
                }
                
                VStack(alignment: .leading, spacing: 8) {
                 
                    Text(viewModel.name)
                        .foregroundColor(.textSecondary)
                        .lineLimit(1)
                        .font(.textH4M16240())
                    
                    if let subtitle = viewModel.subtitle {
                     
                        Text(subtitle)
                            .foregroundColor(.textPlaceholder)
                            .lineLimit(1)
                            .font(.textH4R16240())
                            .multilineTextAlignment(.leading)
                    }
                }
                
                Spacer()
            }
        }
    }
}

//MARK: - Preview

struct ContactsBankItemView_Previews: PreviewProvider {
    
    static var previews: some View {
        
        ContactsBankItemView(viewModel: .sample)
            .previewLayout(.fixed(width: 375, height: 100))
    }
}

//MARK: - Preview Content

extension ContactsBankItemView.ViewModel {
    
    static let sample = ContactsBankItemView.ViewModel(id: UUID().uuidString, icon: Image("Bank Logo Sample"), name: "Сбербанк", subtitle: "0721821863", type: .sfp, action: {})
}

