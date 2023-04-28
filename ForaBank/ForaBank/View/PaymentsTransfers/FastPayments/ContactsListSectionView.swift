//
//  ContactsListSectionView.swift
//  ForaBank
//
//  Created by Max Gribov on 14.11.2022.
//

import SwiftUI

struct ContactsListSectionView: View {
    
    @ObservedObject var viewModel: ContactsListSectionViewModel
    @State var isScrolling: Bool = true
    
    var body: some View {
        
        VStack {
         
            if let selfContactViewModel = viewModel.selfContact {
                
                SelfContactView(viewModel: selfContactViewModel)
            }
            
            ScrollView(.vertical) {
                
                LazyVGrid(columns: [.init()]) {
                    
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
                    .padding(.bottom, 16)
                }
                .padding(.bottom, 10)
                .padding(.horizontal, 20)
                .background(GeometryReader { geo in
                    
                    Color.clear
                        .preference(key: ScrollOffsetKey.self, value: -geo.frame(in: .named("scroll")).origin.y)
                })
                .onPreferenceChange(ScrollOffsetKey.self) { value in
                    
                    guard value > 200, isScrolling else {
                        
                        if  value < 200 {
                            isScrolling = true
                            viewModel.action.send(ContactsViewModelAction.ContactsDidScroll(isVisible: true))
                        }
                        
                        return
                    }
                    
                    isScrolling = false
                    viewModel.action.send(ContactsViewModelAction.ContactsDidScroll(isVisible: false))
                }
            }
            .coordinateSpace(name: "scroll")
        }
    }
}

extension ContactsListSectionView {
    
    struct ScrollOffsetKey: PreferenceKey {
        
        typealias Value = CGFloat
        static var defaultValue = CGFloat.zero
        static func reduce(value: inout Value, nextValue: () -> Value) {
            value += nextValue()
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
