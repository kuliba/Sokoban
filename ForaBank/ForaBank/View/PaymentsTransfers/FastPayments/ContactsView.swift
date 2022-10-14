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
                
                if let contacts = contacts {
                    
                    ContactListView(viewModel: contacts)
                    
                }
                
            case let .contacts(latestPayments, contacts):
                
                if let latestPayments {
                    
                    LatestPaymentsViewComponent(viewModel: latestPayments)
                }
                
                ContactListView(viewModel: contacts)
                
            case let .banks(topBanks, collapsable):
                
                if let topBanks {
                    
                    ScrollView(.horizontal, showsIndicators: false) {
                        
                        switch topBanks {
                        case let .banks(topBanks):
                            
                            TopBankView(viewModel: topBanks)
                            
                        case .placeHolder:
                            HStack(alignment: .top, spacing: 4) {
                                
                                ForEach(0..<5) {_ in
                                    
                                    LatestPaymentsViewComponent.PlaceholderView(viewModel: .init())
                                }
                            }
                        }
                    }
                    .padding(.leading, 8)
                }
                
                Divider()
                    .frame(height: 1)
                    .foregroundColor(Color.mainColorsGrayLightest)
                
                VStack {
                    
                    ForEach(collapsable, id: \.self) { item in
                        
                        CollapsableView(viewModel: item)
                        
                    }
                }
                
                Spacer()
            case let .banksSearch(collapsable):
                
                Divider()
                    .frame(height: 1)
                    .foregroundColor(Color.mainColorsGrayLightest)
                
                ForEach(collapsable, id: \.self) { item in
                    
                    CollapsableView(viewModel: item)
                    
                }
                
                Spacer()
            }
        }
    }
}

extension ContactsView {
    
    struct TopBankView: View {
        
        let viewModel: ContactsViewModel.TopBanksViewModel
        
        var body: some View {
            
            HStack(alignment: .top, spacing: 4) {
                
                ForEach(viewModel.banks, id: \.self) { bank in
                    
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
                            
                            if bank.defaultBank {
                                
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
    }
    
    struct CollapsableView: View {
        
        @ObservedObject var viewModel: ContactsViewModel.CollapsableViewModel
        
        var body: some View {
            
            switch viewModel.mode {
            case .normal:
                
                HeaderView(viewModel: viewModel.header)
                
            case .search:
                
                SearchBarComponent(viewModel: viewModel.searchBar)
                    .padding(.horizontal, 20)
            }
            
            if viewModel.isCollapsed {
                
                if let viewModel = viewModel.options {
                    
                    OptionSelectorView(viewModel: viewModel)
                        .padding()
                }
                
                ListView(viewModel: viewModel.items)
            }
        }
    }
    
    struct ListView: View {
        
        let viewModel: ContactsViewModel.ItemsListViewModel
        
        var body: some View {
            
            VStack {
                
                ScrollView(.vertical, showsIndicators: false) {
                    
                    VStack(spacing: 24) {
                        
                        ForEach(viewModel.items, id: \.self) { item in
                            
                            Button {
                                
                                item.action()
                            } label: {
                                
                                ItemView(viewModel: item)
                            }
                        }
                    }
                }
                .padding(.horizontal, 20)
            }
        }
    }
    
    struct HeaderView: View {
        
        let viewModel: ContactsViewModel.CollapsableViewModel.HeaderViewModel
        
        var body: some View {
            
            HStack(alignment: .center, spacing: 8.5) {
                
                viewModel.icon
                    .renderingMode(.original)
                    .resizable()
                    .frame(width: 24, height: 24)
                
                Text(viewModel.title.rawValue)
                    .foregroundColor(Color.textSecondary)
                    .font(.textH3SB18240())
                
                Spacer()
                
                if let searchButton = viewModel.searchButton {
                    
                    Button {
                        
                        searchButton.action()
                        
                    } label: {
                        
                        searchButton.icon
                            .resizable()
                            .frame(width: 24, height: 24)
                            .foregroundColor(Color.iconGray)
                    }
                }
                
                Button {
                    
                    viewModel.toggleButton.action()
                    
                } label: {
                    
                    viewModel.toggleButton.icon
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
                    .foregroundColor(Color.mainColorsGrayLightest)
                
                Button {
                    
                    selfContact.action()
                } label: {
                    
                    ContactListView.ContactView(viewModel: selfContact)
                        .padding(.horizontal, 20)
                }
                
                Divider()
                    .frame(height: 1)
                    .foregroundColor(Color.mainColorsGrayLightest)
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
                .padding(.bottom, 10)
            }
            .padding(.horizontal, 20)
        }
        
        struct ContactView: View {
            
            @ObservedObject var viewModel: ContactsViewModel.ContactViewModel
            
            var body: some View {
                
                HStack(alignment: .center, spacing: 20) {
                    
                    switch viewModel.image {
                        
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
                        
                    default:
                        
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
    
    struct ItemView: View {
        
        let viewModel: ContactsViewModel.ItemsListViewModel.Item
        
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
        }
    }
}
