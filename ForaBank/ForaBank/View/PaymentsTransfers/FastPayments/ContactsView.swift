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
                
                SearchBarComponent(viewModel: viewModel.searchBar)
                
            }
            .padding(.horizontal, 20)
            
            switch viewModel.mode {
            
            case let .contactsSearch(contacts):
                
                ContactListView(viewModel: contacts)
                
            case let .contacts(latestPayments, contacts):
                
                LatestPaymentsViewComponent(viewModel: latestPayments)
                
                ContactListView(viewModel: contacts)
                
            case let .banks(phone, topBanks, banksList):
                
                ScrollView(.horizontal, showsIndicators: false) {
                    
                    HStack(alignment: .top, spacing: 4) {
                     
                        ForEach(topBanks.banks, id: \.self) { bank in
                            
                            Button {
                                
                                bank.action()
                                
                            } label: {
                                
                                ZStack {
                                    
                                    VStack(spacing: 8) {
                                        
                                        if let image = bank.image {
                                            
                                            ZStack {
                                                
                                                image
                                                    .resizable()
                                                    .frame(width: 56, height: 56, alignment: .center)
                                                    .cornerRadius(90)
                                            }

                                        } else {
                                            ZStack {
                                                
                                                Color.mainColorsGrayLightest
                                                    .frame(width: 56, height: 56, alignment: .center)
                                                    .cornerRadius(90)
                                                
                                            }
                                        }
                                        
                                        VStack(spacing: 4) {
                                            
                                            if let title = bank.name {
                                                
                                                Text(title)
                                                    .font(.textBodyXSSB11140())
                                                    .foregroundColor(Color.textSecondary)
                                            }
                                            
                                            Text(bank.bankName)
                                                .foregroundColor(Color.textPlaceholder)
                                                .font(.textBodyXSR11140())
                                        }
                                    }
                                    
                                    if bank.favorite {
                                        
                                        ZStack {
                                            
                                            Color.mainColorsBlack
                                                .frame(width: 24, height: 24, alignment: .top)
                                                .cornerRadius(90)
                                            
                                            Image.ic24Star
                                                .resizable()
                                                .frame(width: 16, height: 16, alignment: .center)
                                                .foregroundColor(Color.mainColorsWhite)
                                        }
                                        .offset(x: 25, y: -35)
                                    }
                                }
                                .frame(width: 80)
                            }
                        }
                    }
                }
                .padding(.horizontal, 20)
                
                Divider()
                    .frame(height: 1)
                
                CollapsebleView()
                
                OptionSelectorView(viewModel: .init(options: [.init(id: "Российские", name: "Российские"), .init(id: "Иностранные", name: "Иностранные"), .init(id: "Все", name: "Все")], selected: "Иностранные", style: .template))
                    .padding()
                
                ScrollView(.vertical, showsIndicators: false) {
                    
                    VStack(spacing: 24) {
                        
                        ForEach(banksList.bank, id: \.self) { bank in

                            Button {

                                bank.action()
                            } label: {

                                BankView(viewModel: bank)
                            }
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.bottom, 50)
                }
            }
        }
    }
}

extension ContactsView {
    
    struct CollapsebleView: View {
        
        var body: some View {
            
            HStack(alignment: .center, spacing: 8.5) {
            
                Image.ic24Bank
                    .resizable()
                    .frame(width: 24, height: 24)
                
                Text("В другой банк")
                    .foregroundColor(Color.textSecondary)
                    .font(.textH3SB18240())
                
                Spacer()
                
                Button {
                    
                } label: {
                    
                    Image.ic24Search
                        .resizable()
                        .frame(width: 24, height: 24)
                        .foregroundColor(Color.iconGray)
                    
                }
                
                Button {
                    
                } label: {
                    
                    Image.ic24ChevronDown
                        .resizable()
                        .frame(width: 24, height: 24)
                        .foregroundColor(Color.iconGray)
                    
                }
            }
            .padding(.horizontal, 20)
        }
    }
    
    struct ContactListView: View {
        
        @ObservedObject var viewModel: ContactsViewModel.ContactsListViewModel
        
        var body: some View {
            
            if let selfContact = viewModel.selfContact {
                
                Divider()
                    .frame(height: 1)
                
                Button {
                    
                    selfContact.action()
                } label: {
                    
                    ContactListView.ContactView(viewModel: selfContact)
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
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 50)
        }
        
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
    
    struct BankView: View {
        
        let viewModel: ContactsViewModel.BanksListViewModel.Bank
        
        var body: some View {
           
            HStack(alignment: .center, spacing: 20) {
                
                if let avatar = viewModel.image {
                    
                    avatar
                        .resizable()
                        .frame(width: 40, height: 40, alignment: .center)
                        .cornerRadius(90)
                    
                } else {
                    
                    Color.mainColorsGrayLightest
                        .frame(width: 40, height: 40, alignment: .center)
                        .cornerRadius(90)
                }
                
                VStack(alignment: .leading, spacing: 8) {
                        
                    Text(viewModel.title)
                            .foregroundColor(Color.textSecondary)
                            .lineLimit(1)
                            .font(.system(size: 16))
                }
                
                Spacer()
            }
        }
    }
}

struct ContactsView_Previews: PreviewProvider {
    static var previews: some View {

        Group {
            
            ContactsView(viewModel: .sample)
                .previewDisplayName("Contacts List")

            ContactsView(viewModel: .sampleLatestPayment)
                .previewDisplayName("Contacts List")

            ContactsView(viewModel: .sampleBanks)
                .previewDisplayName("Contact List Banks")
        }
    }
}
