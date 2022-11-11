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
                
                SearchBarView(viewModel: viewModel.searchBar)
                
            }
            .padding(.horizontal, 20)
            .padding(.top, 20)
            
            switch viewModel.mode {
                
            case let .contactsSearch(contacts):
                
                ContactListView(viewModel: contacts)
                
            case let .contacts(latestPayments, contacts):
                
                if let latestPayments = latestPayments {
                    
                    LatestPaymentsView(viewModel: latestPayments)
                }
                
                ContactListView(viewModel: contacts)
                
            case let .banks(topBanks, collapsable):
                
                if let topBanks = topBanks {
                    
                    ScrollView(.horizontal, showsIndicators: false) {
                        
                        TopBankSectionView(viewModel: topBanks)
                        
                    }
                    .padding(.leading, 8)
                }
                
                Divider()
                    .frame(height: 1)
                    .foregroundColor(Color.mainColorsGrayLightest)
                
                VStack(spacing: 30) {
                    
                    ForEach(collapsable) { item in
                        
                        CollapsableView(viewModel: item)
                        
                    }
                }
                
                Spacer()
                
            case let .banksSearch(collapsable):
                
                Divider()
                    .frame(height: 1)
                    .foregroundColor(Color.mainColorsGrayLightest)
                
                ForEach(collapsable) { item in
                    
                    CollapsableView(viewModel: item)
                    
                }
                
                Spacer()
            }
        }
    }
}

extension ContactsView {
    
    struct TopBankSectionView: View {
        
        @ObservedObject var viewModel: ContactsTopBanksSectionViewModel
        
        var body: some View {
            
            switch viewModel.content {
            case .empty:
                EmptyView()
                
            case .banks(let topBanks):
                TopBanksView(viewModel: topBanks)
                
            case .placeHolder(let placeholders):
                HStack(alignment: .top, spacing: 4) {
                    
                    ForEach(placeholders) { placeholder in
                        
                        LatestPaymentsView.PlaceholderView(viewModel: placeholder)
                            .shimmering(active: true, bounce: true)
                    }
                }
            }
        }
        
        struct TopBanksView: View {
            
            @ObservedObject var viewModel: TopBanksViewModel
            
            var body: some View {
                
                HStack(alignment: .top, spacing: 4) {
                    
                    ForEach(viewModel.banks) { bank in
                        
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
    }
    
    struct CollapsableView: View {
        
        @ObservedObject var viewModel: ContactsSectionCollapsableViewModel
        
        var body: some View {
            
            VStack {
                
                if let viewModel = viewModel as? ContactsBanksSectionViewModel {
                    
                    switch viewModel.mode {
                    case .normal:
                        HeaderView(viewModel: viewModel)
                        
                    case let .search(searchViewModel):
                        SearchBarView(viewModel: searchViewModel)
                            .padding(.horizontal, 20)
                    }
                } else {
                    
                    HeaderView(viewModel: viewModel)
                }
                
                if viewModel.header.isCollapsed {
                    
                    if let viewModel = viewModel as? ContactsBanksSectionViewModel, let options = viewModel.options {
                        
                        OptionSelectorView(viewModel: options)
                            .padding()
                    }
                    
                    VStack {
                        
                        ScrollView(.vertical, showsIndicators: false) {
                            
                            VStack(spacing: 24) {
                                
                                ForEach(viewModel.items) { item in
                                    
                                    Button(action: item.action) {
                                        
                                        ItemView(viewModel: item)
                                    }
                                }
                            }
                        }
                        .padding(.horizontal, 20)
                    }
                }
            }
        }
        
        struct HeaderView: View {
            
            @ObservedObject var viewModel: ContactsSectionCollapsableViewModel
            
            var body: some View {
                
                HStack(alignment: .center, spacing: 8.5) {
                    
                    viewModel.header.icon
                        .renderingMode(.original)
                        .resizable()
                        .frame(width: 24, height: 24)
                    
                    Text(viewModel.header.title)
                        .foregroundColor(Color.textSecondary)
                        .font(.textH3SB18240())
                    
                    Spacer()
                    
                    if let search = viewModel.header.searchButton {
                        
                        Button {
                            
                            if let viewModel = viewModel as? ContactsBanksSectionViewModel {
                                
                                viewModel.header.searchButton?.action()
                            }
                            
                        } label: {
                            
                            search.icon
                                .resizable()
                                .frame(width: 24, height: 24)
                                .foregroundColor(Color.iconGray)
                            
                        }
                    }
                    
                    Button {
                        
                        withAnimation {
                            
                            viewModel.header.isCollapsed.toggle()
                            viewModel.header.toggleButton.icon = viewModel.header.toggleButton.icon == .ic24ChevronUp ? Image.ic24ChevronDown : .ic24ChevronUp
                        }
                        
                    } label: {
                        
                        viewModel.header.toggleButton.icon
                            .resizable()
                            .frame(width: 24, height: 24)
                            .foregroundColor(Color.iconGray)
                        
                    }
                }
                .padding(.horizontal, 20)
            }
        }
    }
    
    struct ContactListView: View {
        
        @ObservedObject var viewModel: ContactsListViewModel
        
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
                    
                    ForEach(viewModel.contacts) { contact in
                        
                        Button(action: contact.action) {

                            ContactView(viewModel: contact)
                        }
                    }
                }
                .padding(.bottom, 10)
            }
            .padding(.horizontal, 20)
        }
        
        struct ContactView: View {
            
            @ObservedObject var viewModel: ContactsListViewModel.ContactViewModel
            
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
}

struct ItemView: View {
    
    let viewModel: ContactsSectionCollapsableViewModel.ItemViewModel
    
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

struct ContactsView_Previews: PreviewProvider {

    static var previews: some View {

        Group {

            ContactsView.CollapsableView.HeaderView(viewModel: .init(header: .init(icon: .ic40SBP, title: "В другой банк", toggleButton: ContactsSectionCollapsableViewModel.HeaderViewModel.ButtonViewModel(icon: .ic24ChevronUp, action: {})), items: [.sampleItem], model: .emptyMock))
                .previewLayout(.fixed(width: 375, height: 100))
                .previewDisplayName("HeaderView")

            ContactsView.CollapsableView(viewModel: ContactsBanksSectionViewModel(.emptyMock, header: .sampleHeader, items: [.sampleItem], mode: .normal, options: .sample))
                .previewLayout(.fixed(width: 375, height: 100))
                .previewDisplayName("CollapsableView")

            ContactsView(viewModel: .sample)
                .previewDisplayName("Contacts List")

            ContactsView(viewModel: .sampleLatestPayment)
                .previewDisplayName("Contacts List")
        }
    }
}
