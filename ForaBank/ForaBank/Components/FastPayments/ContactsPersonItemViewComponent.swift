//
//  ContactsPersonItemViewComponent.swift
//  ForaBank
//
//  Created by Max Gribov on 11.11.2022.
//

import SwiftUI

//MARK: - ViewModel

extension ContactsPersonItemView {
    
    class ViewModel: ContactsItemViewModel {

        let id: AddressBookContact.ID
        let icon: Icon
        let name: String?
        let phone: String
        let isBankIcon: Bool
        let action: () -> Void
        
        enum Icon {
            
            case image(Image)
            case initials(String)
            case placeholder
        }
        
        init(id: AddressBookContact.ID, icon: ContactsPersonItemView.ViewModel.Icon, name: String?, phone: String, isBankIcon: Bool, action: @escaping () -> Void) {
           
            self.id = id
            self.icon = icon
            self.name = name
            self.phone = phone
            self.isBankIcon = isBankIcon
            self.action = action
        }
    }
}

//MARK: - View

struct ContactsPersonItemView: View {
    
    let viewModel: ViewModel
    
    var body: some View {
        
        Button(action: viewModel.action) {
            
            HStack(alignment: .center, spacing: 20) {
                
                switch viewModel.icon {
                case let .image(image):
                    
                    image
                        .resizable()
                        .frame(width: 40, height: 40, alignment: .center)
                        .cornerRadius(90)
                    
                case let .initials(initials):
                    
                    ZStack {
                        
                        Color.mainColorsGrayLightest
                            .frame(width: 40, height: 40, alignment: .center)
                            .cornerRadius(90)
                        
                        Text(initials)
                            .foregroundColor(.textPlaceholder)
                            .font(.textH3M18240())
                    }
                    
                case .placeholder:
                    
                    IconPlaceholder()
                }
                
                if let name = viewModel.name {
                    
                    VStack(alignment: .leading, spacing: 8) {
                        
                        Text(name)
                            .foregroundColor(Color.textSecondary)
                            .lineLimit(1)
                            .font(.textH4M16240())
                        
                        Text(viewModel.phone)
                            .foregroundColor(Color.textPlaceholder)
                            .font(.textBodySR12160())
                    }
                    
                } else {
                    
                    Text(viewModel.phone)
                        .foregroundColor(Color.textSecondary)
                        .lineLimit(1)
                        .font(.textH4M16240())
                }

                Spacer()
                
                if viewModel.isBankIcon == true {
                    
                    Image.ic24LogoForaColor
                        .resizable()
                        .renderingMode(.original)
                        .frame(width: 24, height: 24)
                }
            }
            
        }.buttonStyle(PushButtonStyle())
    }
}

//MARK: - Internal Views

extension ContactsPersonItemView {
    
    struct IconPlaceholder: View {
        
        var body: some View {
            
            ZStack {
                
                Color.mainColorsGrayLightest
                    .frame(width: 40, height: 40, alignment: .center)
                    .cornerRadius(90)
                
                Image.ic24Smartphone
                    .foregroundColor(Color.textPlaceholder)
            }
        }
    }
}

//MARK: - Preview

struct ContactsPersonItemView_Previews: PreviewProvider {
    
    static var previews: some View {
        
        Group {
            
            ContactsPersonItemView(viewModel: .sampleSelf)
                .previewLayout(.fixed(width: 375, height: 100))
            
            ContactsPersonItemView(viewModel: .sampleInitials)
                .previewLayout(.fixed(width: 375, height: 100))
            
            ContactsPersonItemView(viewModel: .sampleClient)
                .previewLayout(.fixed(width: 375, height: 100))
        }
    }
}

//MARK: - Preview Content

extension ContactsPersonItemView.ViewModel {
    
    static let sampleSelf = ContactsPersonItemView.ViewModel(id: UUID().uuidString, icon: .placeholder, name: "Себе", phone: "+7 925 555-5555", isBankIcon: false, action: { })
    
    static let sampleInitials = ContactsPersonItemView.ViewModel(id: UUID().uuidString, icon: .initials("ИИ"), name: "Иванов Иван Иванович", phone: "+7 925 555-5555", isBankIcon: false, action: {})
    
    static let sampleClient = ContactsPersonItemView.ViewModel(id: UUID().uuidString, icon: .initials("ИИ"), name: "Иванов Иван Иванович", phone: "+7 925 555-5555", isBankIcon: true, action: {})
}

