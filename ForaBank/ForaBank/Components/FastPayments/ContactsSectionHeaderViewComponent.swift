//
//  ContactsSectionHeaderViewComponent.swift
//  ForaBank
//
//  Created by Max Gribov on 15.11.2022.
//

import SwiftUI
import Combine

//MARK: - ViewModel

extension ContactsSectionHeaderView {
    
    class ViewModel: ObservableObject {
        
        let action: PassthroughSubject<Action, Never> = .init()

        @Published var icon: Image
        var title: String
        @Published var isCollapsed: Bool
        @Published var searchButton: ButtonViewModel?
        
        enum Kind {
            
            case banks, country
        }
        
        init(icon: Image, isCollapsed: Bool = false, title: String, searchButton: ButtonViewModel? = nil) {
            
            self.icon = icon
            self.isCollapsed = isCollapsed
            self.title = title
            self.searchButton = searchButton
        }
        
        convenience init(kind: Kind) {
            
            switch kind {
            case .banks:
                let icon: Image = .ic24Sbp
                let title = "В другой банк"
                
                self.init(icon: icon, title: title, searchButton: nil)
                self.searchButton = ButtonViewModel(icon: .ic24Search, action: { [weak self] in
                    
                    self?.action.send(ContactsSectionViewModelAction.Collapsable.SearchDidTapped())
                })
                
                
            case .country:
                let icon: Image = .ic24Abroad
                let title = "Переводы за рубеж"
                self.init(icon: icon, title: title)
            }
        }
        
        struct ButtonViewModel {
            
            var icon: Image
            var action: () -> Void
        }
    }
}

//MARK: - View

struct ContactsSectionHeaderView: View {
   
    @ObservedObject var viewModel: ViewModel
    
    var body: some View {
        
        HStack(alignment: .center, spacing: 8.5) {
            
            viewModel.icon
                .renderingMode(.original)
                .resizable()
                .frame(width: 24, height: 24)
            
            Text(viewModel.title)
                .foregroundColor(Color.textSecondary)
                .font(.textH3SB18240())
            
            Spacer()
            
            if let search = viewModel.searchButton {
                
                Button(action: search.action) {
                    
                    search.icon
                        .resizable()
                        .frame(width: 24, height: 24)
                        .foregroundColor(Color.iconGray)
                    
                }.frame(width: 44, height: 44)
            }
            
            Image.ic24ChevronUp
                .resizable()
                .frame(width: 24, height: 24)
                .foregroundColor(Color.iconGray)
                .rotationEffect(viewModel.isCollapsed ? .degrees(0) : .degrees(180))
            
        }
        .padding(.horizontal, 20)
        .onTapGesture {
            
            withAnimation {
                
                viewModel.isCollapsed.toggle()
            }
        }
    }
}

//MARK: - Preview

struct ContactsSectionHeaderView_Previews: PreviewProvider {
    
    static var previews: some View {
        
        ContactsSectionHeaderView(viewModel: .sample)
    }
}

//MARK: - Preview Content
extension ContactsSectionHeaderView.ViewModel {
    
    static let sample = ContactsSectionHeaderView.ViewModel(kind: .banks)
}
