//
//  ContactsListSectionView.swift
//  ForaBank
//
//  Created by Max Gribov on 14.11.2022.
//

import SwiftUI

struct ContactsListSectionView: View {
    
    @ObservedObject var viewModel: ContactsListSectionViewModel
    
    var body: some View {
        
        VStack {
         
            if let selfContactViewModel = viewModel.selfContact {
                
                SelfContactView(viewModel: selfContactViewModel)
            }
            
            ScrollView(.vertical) {
                
                VStack(spacing: 24) {
                    
                    ForEach(viewModel.visible) { contact in
                        
                        switch contact {
                        case let personViewModel as ContactsPersonItemView.ViewModel:
                            ContactsPersonItemView(viewModel: personViewModel)
                            
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

//MARK: - Internal Views

extension ContactsListSectionView {
    
    struct SelfContactView: View {
        
        let viewModel: ContactsPersonItemView.ViewModel
        
        var body: some View {
            
            VStack(spacing: 8) {
                
                Divider()
                    .foregroundColor(Color.mainColorsGrayLightest)
                
                ContactsPersonItemView(viewModel: viewModel)
                    .padding(.horizontal, 20)
                
                Divider()
                    .foregroundColor(Color.mainColorsGrayLightest)
            }
        }
    }
}


//MARK: - Preview

struct ContactsListSectionView_Previews: PreviewProvider {
    
    static var previews: some View {
        
        ContactsListSectionView(viewModel: .sample)
    }
}

//MARK: - Preview Content

extension ContactsListSectionViewModel {
    
    static let sample = ContactsListSectionViewModel(.emptyMock, selfContact: ContactsPersonItemView.ViewModel.sampleSelf, visible: [ContactsPersonItemView.ViewModel.sampleClient, ContactsPersonItemView.ViewModel.sampleInitials], contacts: [], filter: nil, mode: .fastPayment)
}
