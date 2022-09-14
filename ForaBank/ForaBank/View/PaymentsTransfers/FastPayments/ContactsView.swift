//
//  ContactsView.swift
//  ForaBank
//
//  Created by Дмитрий Савушкин on 12.09.2022.
//

import SwiftUI

struct ContactsView: View {
    
    @ObservedObject var viewModel: ContactsViewModel
    
    var body: some View {
        
        VStack(alignment: .leading, spacing: 16) {
            
            VStack(alignment: .leading, spacing: 20) {
                
                Text(viewModel.title)
                    .font(.textH3SB18240())
                
                SearchBarComponent(viewModel: viewModel.searchViewModel)
                
            }
            .padding(.horizontal, 20)
            
            if let topList = viewModel.topListViewModel {
                
                ScrollView(.horizontal, showsIndicators: false) {
                    
                    ForEach(topList, id: \.self) { item in
                        
                        VStack {
                            
                            if let image = item.image {
                                
                                image
                                    .resizable()
                                    .frame(width: 56, height: 56, alignment: .center)
                            } else {
                                
                                ZStack {
                                    
                                    Color.mainColorsGrayLightest
                                        .frame(width: 56, height: 56, alignment: .center)
                                        .cornerRadius(90)
                                    
                                    Image.ic24Smartphone
                                }
                            }
                            
                            Text(item.name)
                                .foregroundColor(Color.textSecondary)
                                .lineLimit(5)
                                .font(.system(size: 12))
                            
                            if let description = item.description {
                             
                                Text(description)
                            }
                        }
                        .frame(width: 82)
                    }
                }
                .padding(.horizontal, 20)
            }
            
            if let selfContact = viewModel.selfContact {
                
                Divider()
                    .frame(height: 1)
                
                Button {
                    
                    selfContact.action()
                } label: {
                    
                    ContactView(viewModel: selfContact)
                        .padding(.horizontal, 20)
                }
                
                Divider()
                    .frame(height: 1)
            }
            
            ScrollView(.vertical, showsIndicators: false) {
                
                VStack(spacing: 24) {
                    
                    ForEach(viewModel.contacts, id: \.self) { contact in
                        
                        Button {
                            
                            contact.action()
                        } label: {
                            
                            ContactView(viewModel: contact)
                        }
                    }
                }
                .padding(.bottom, 50)
                .padding(.horizontal, 20)
            }
        }
    }
}

extension ContactsView {
    
    struct ContactView: View {
        
        @ObservedObject var viewModel: ContactsViewModel.Contact
        
        var body: some View {
            
            HStack(alignment: .center, spacing: 20) {
                
                if let avatar = viewModel.image {
                    
                    avatar
                        .resizable()
                        .frame(width: 40, height: 40, alignment: .center)
                        .cornerRadius(90)
                    
                } else {
                    
                    IconPlaceholder()
                }
                
                VStack(alignment: .leading, spacing: 8) {
                    
                    if let fullName = viewModel.fullName {
                        
                        Text(fullName)
                            .foregroundColor(Color.textSecondary)
                            .lineLimit(1)
                            .font(.system(size: 16))
                    }
                    
                    if let phone = viewModel.phone {
                        
                        Text(phone)
                            .foregroundColor(Color.textPlaceholder)
                            .font(.system(size: 12))
                    }
                }
                
                Spacer()
                
                if let icon = viewModel.icon {
                    
                    icon
                        .resizable()
                        .frame(width: 24, height: 24)
                }
            }
        }
        
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
}

struct ContactsView_Previews: PreviewProvider {
    static var previews: some View {

        Group {
            
            ContactsView(viewModel: .sample)
                .previewLayout(.fixed(width: 375, height: 400))
                .previewDisplayName("Contacts List")
            
            ContactsView(viewModel: .emptyNameSample)
                .previewLayout(.fixed(width: 375, height: 400))
                .previewDisplayName("Empty Name Contact")
        }
    }
}
