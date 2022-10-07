//
//  UserAccountDocumentInfoView.swift
//  ForaBank
//
//  Created by Mikhail on 31.05.2022.
//

import SwiftUI
import Combine

extension UserAccountDocumentInfoView {
    
    class ViewModel: ObservableObject {
        
        let action: PassthroughSubject<Action, Never> = .init()
        let itemType: DocumentCellType
        let content: String
        
        @Published var button: ButtonSimpleView.ViewModel?
        
        private var bindings = Set<AnyCancellable>()
        
        internal init(itemType: DocumentCellType, content: String) {
            
            self.itemType = itemType
            self.content = content
            
            self.button = .init(
                title: "Скопировать",
                style: .gray,
                action: {
                    
                    self.action.send(UserAccountDocumentInfoViewAction.CopyDocument(type: itemType))
                }
            )
            bind()
        }
        
        func bind() {
            
            action
                .receive(on: DispatchQueue.main)
                .sink { [unowned self] action in
                    
                    switch action {
                    case _ as UserAccountDocumentInfoViewAction.CopyDocument:
                        button?.title = "Скопировано"
                        button?.style = .inactive
                        
                    default:
                        break
                        
                    }
                }
                .store(in: &bindings)
        }
    }
}

enum UserAccountDocumentInfoViewAction {
    
    struct CopyDocument: Action {
        let type: DocumentCellType
    }
}


struct UserAccountDocumentInfoView: View {
    
    @ObservedObject var viewModel: UserAccountDocumentInfoView.ViewModel
    
    var body: some View {
        
        VStack(spacing: 24) {
            
            ZStack {
                
                RoundedRectangle(cornerRadius: 32)
                    .foregroundColor(viewModel.itemType.iconBackground)
                    .frame(width: 64, height: 64)
                
                viewModel.itemType.icon
                    .resizable()
                    .frame(width: 39, height: 39)
                    .foregroundColor(.iconWhite)
            }
            .padding(.top, 20)
            
            switch viewModel.itemType {
            case .inn:
                VStack(spacing: 16) {
                    
                    Text(verbatim: viewModel.itemType.title)
                        .font(.textH4SB16240())
                        .foregroundColor(.textSecondary)
                    
                    Text(verbatim: viewModel.content)
                        .font(.textH1SB24322())
                        .foregroundColor(.textSecondary)
                }
                
            case .adress, .adressPass:
                Text(verbatim: viewModel.content)
                    .font(.textH4SB16240())
                    .foregroundColor(.textSecondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 16)
                
            default: EmptyView()
            }
            
            if let button = viewModel.button {
                ButtonSimpleView(viewModel: button)
                    .frame(height: 48)
                    .padding(.horizontal, 20)
                    .padding(.vertical, 60)
            }
        }
    }
}

struct UserAccountDocumentInfoView_Previews: PreviewProvider {
    
    static var previews: some View {
        
        UserAccountDocumentInfoView(viewModel: .init(
            itemType: .inn,
            content: "123456789"
        ))
    }
}
