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
        @Published var toggleButton: ButtonViewModel
        
        enum Kind {
            
            case banks, country
        }
        
        init(icon: Image, isCollapsed: Bool = false, title: String, searchButton: ButtonViewModel? = nil, toggleButton: ButtonViewModel) {
            
            self.icon = icon
            self.isCollapsed = isCollapsed
            self.title = title
            self.searchButton = searchButton
            self.toggleButton = toggleButton
        }
        
        convenience init(kind: Kind) {
            
            switch kind {
            case .banks:
                let icon: Image = .ic24SBP
                let title = "В другой банк"
                let toggleButton = ButtonViewModel(icon: .ic24ChevronUp, action: {})
                
                self.init(icon: icon, title: title, searchButton: nil, toggleButton: toggleButton)
                self.searchButton = ButtonViewModel(icon: .ic24Search, action: { [weak self] in
                    
                    self?.action.send(ContactsSectionViewModelAction.Collapsable.SearchDidTapped())
                })
                
            case .country:
                let icon: Image = .ic24Abroad
                let title = "Переводы за рубеж"
                let button = ButtonViewModel(icon: .ic24ChevronUp, action: {})
                
                self.init(icon: icon, title: title, toggleButton: button)
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
                }
            }
            
            Button {
                
                withAnimation {
                    
                    //TODO: refactor
                    viewModel.isCollapsed.toggle()
                    viewModel.toggleButton.icon = viewModel.toggleButton.icon == .ic24ChevronUp ? Image.ic24ChevronDown : .ic24ChevronUp
                }
                
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
