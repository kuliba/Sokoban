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

        let id: BankData.ID
        let icon: Image?
        let name: String
        let type: BankType
        let action: () -> Void
        
        init(id: BankData.ID, icon: Image?, name: String, type: BankType, action: @escaping () -> Void) {
            
            self.id = id
            self.icon = icon
            self.name = name
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
                
                Text(viewModel.name)
                    .foregroundColor(Color.textSecondary)
                    .lineLimit(1)
                    .font(.system(size: 16))
                
                Spacer()
            }
            
        }.buttonStyle(PushButtonStyle())
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
    
    static let sample = ContactsBankItemView.ViewModel(id: UUID().uuidString, icon: Image("Bank Logo Sample"), name: "Сбербанк", type: .sfp, action: {})
}

