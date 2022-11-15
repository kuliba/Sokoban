//
//  ContactsCountryItemViewComponent.swift
//  ForaBank
//
//  Created by Max Gribov on 11.11.2022.
//

import SwiftUI

//MARK: - View Model

extension ContactsCountryItemView {
    
    class ViewModel: ContactsItemViewModel {

        let id: CountryData.ID
        let icon: Image?
        let name: String
        let action: () -> Void
        
        init(id: CountryData.ID, icon: Image?, name: String, action: @escaping () -> Void) {
            
            self.id = id
            self.icon = icon
            self.name = name
            self.action = action
        }
    }
}

//MARK: - View

struct ContactsCountryItemView: View {
    
    let viewModel: ViewModel
    
    var body: some View {
        
        Button(action: viewModel.action) {
            
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
                    .font(.textH4M16240())
                
                Spacer()
            }
            
        }.buttonStyle(PushButtonStyle())
        
    }
}

//MARK: - Preview

struct ContactsCountryItemView_Previews: PreviewProvider {
    
    static var previews: some View {
        
        ContactsCountryItemView(viewModel: .sample)
            .previewLayout(.fixed(width: 375, height: 100))
    }
}

//MARK: - Preview Content

extension ContactsCountryItemView.ViewModel {
    
    static let sample = ContactsCountryItemView.ViewModel(id: UUID().uuidString, icon: Image("Bank Logo Sample"), name: "Россия", action: {})
}

