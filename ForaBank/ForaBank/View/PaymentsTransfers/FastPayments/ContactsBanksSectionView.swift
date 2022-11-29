//
//  ContactsBanksSectionView.swift
//  ForaBank
//
//  Created by Max Gribov on 15.11.2022.
//

import SwiftUI

struct ContactsBanksSectionView: View {
    
    @ObservedObject var viewModel: ContactsBanksSectionViewModel
    
    var body: some View {
      
        switch viewModel.mode {
        case .fastPayment:
            
            if let searchBar = viewModel.searchBar {
                
                SearchBarView(viewModel: searchBar)
                    .padding(.horizontal, 20)
                    .padding(.vertical, 0)
                
            } else {
                
                ContactsSectionHeaderView(viewModel: viewModel.header)
                    .padding(.vertical, 0)
            }
            
            if viewModel.header.isCollapsed {
                
                OptionSelectorView(viewModel: viewModel.options)
                    .padding(.horizontal, 20)
                    .padding(.top, 0)
                    .padding(.bottom, 24)

                ScrollView(.vertical) {
                    
                    VStack(spacing: 24) {
                        
                        if let searchPlaceholder = viewModel.searchPlaceholder {
                            
                            SearchPlaceholderView(viewModel: searchPlaceholder)
                        }
                        
                        ForEach(viewModel.visible) { item in
                            
                            switch item {
                            case let bankItemViewModel as ContactsBankItemView.ViewModel:
                                ContactsBankItemView(viewModel: bankItemViewModel)
                                
                            case let placeholderViewModel as ContactsPlaceholderItemView.ViewModel:
                                ContactsPlaceholderItemView(viewModel: placeholderViewModel)
                                
                            default:
                                EmptyView()
                            }
                        }
                    }
                    .padding(.bottom, 10)
                    .padding(.horizontal, 20)
                }
            }
            
        case .select:
            
            ScrollView(.vertical) {
                
                VStack(spacing: 24) {
                    
                    ForEach(viewModel.visible) { item in
                        
                        switch item {
                        case let bankItemViewModel as ContactsBankItemView.ViewModel:
                            ContactsBankItemView(viewModel: bankItemViewModel)
                            
                        case let placeholderViewModel as ContactsPlaceholderItemView.ViewModel:
                            ContactsPlaceholderItemView(viewModel: placeholderViewModel)
                            
                        default:
                            EmptyView()
                        }
                    }
           
                }
                .padding(.bottom, 10)
                .padding(.horizontal, 20)
            }
        }
    }
}

//MARK: - SearchPlaceholder

struct SearchPlaceholderView: View {
    
    let viewModel: ContactsBanksSectionViewModel.SearchPlaceholder
    
    var body: some View {
        
        VStack(spacing: 20) {
            
            ZStack {

                Circle()
                    .frame(width: 76, height: 76, alignment: .center)
                    .foregroundColor(Color.mainColorsGrayLightest)
                
                viewModel.image
            }
            
            VStack(spacing: 16) {
                
                Text(viewModel.title)
                    .font(.textH4SB16240())
                    .foregroundColor(.mainColorsBlack)
                    .multilineTextAlignment(.center)

                Text(viewModel.description)
                    .font(.textH4R16240())
                    .foregroundColor(.mainColorsGray)
                    .multilineTextAlignment(.center)
            }
        }
        .padding(.horizontal, 20)
    }
}

//MARK: - Preview

struct ContactsBanksSectionView_Previews: PreviewProvider {
    
    static var previews: some View {
        
        ContactsBanksSectionView(viewModel: .sample)
        
        SearchPlaceholderView(viewModel: .init())
    }
}

//MARK: - Preview Content

extension ContactsBanksSectionViewModel {
    
    static let sample = ContactsBanksSectionViewModel(.emptyMock, header: .init(kind: .banks), isCollapsed: true, mode: .fastPayment, searchBar: nil, options: .sample, visible: [ContactsBankItemView.ViewModel.sample, ContactsBankItemView.ViewModel.sample], items: [ContactsBankItemView.ViewModel.sample, ContactsBankItemView.ViewModel.sample], phone: nil)
}
