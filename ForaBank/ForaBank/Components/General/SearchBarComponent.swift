//
//  SearchBarComponent.swift
//  ForaBank
//
//  Created by Дмитрий Савушкин on 12.09.2022.
//

import SwiftUI
import Combine
import PhoneNumberKit

extension SearchBarComponent {
 
    class ViewModel: ObservableObject {
        
        let action: PassthroughSubject<Action, Never> = .init()
        
        @Published var text: String = ""
        @Published var isEditing = false
        let placeHolder: PlaceHolder
        let cancelButtonLabel = "Отмена"
        
        private var bindings = Set<AnyCancellable>()
        
        internal init(isEditing: Bool = false, placeHolder: PlaceHolder) {
            
            self.isEditing = isEditing
            self.placeHolder = placeHolder
            
            bind()
        }
        
        convenience init(_ model: Model, placeHolder: PlaceHolder) {
            
            self.init(placeHolder: placeHolder)
        }
        
        private func bind() {
            
            $text
                .receive(on: DispatchQueue.main)
                .sink { [unowned self] text in
                    
                    let phoneNumberKit = PhoneNumberKit()
                    let phone = try? phoneNumberKit.parse(text)
                    if let phone = phone {
                     
                        let contactPhone = phoneNumberKit.format(phone, toType: .national)
                        
                        self.text = contactPhone
                    }
                }.store(in: &bindings)
        }

        enum PlaceHolder: String {
            
            case contacts = "Номер телефона или имя"
        }
    }
}

struct SearchBarComponent: View {
    
    @ObservedObject var viewModel: SearchBarComponent.ViewModel
   
      var body: some View {
          
          HStack {
              
              TextField(viewModel.placeHolder.rawValue, text: $viewModel.text)
                  .padding(10)
                  .padding(.leading, 15)
                  .cornerRadius(8)
                  .onTapGesture {
                      self.viewModel.isEditing = true
                  }
                  .foregroundColor(.textPlaceholder)
              
              if viewModel.isEditing {
                  
                  HStack(spacing: 20) {
                   
                      Button(action: {
                          
                          self.viewModel.isEditing = false
                          self.viewModel.text = ""
                      }) {
                          
                          Image.ic24Close
                              .resizable()
                              .frame(width: 12, height: 12, alignment: .center)
                              .foregroundColor(.mainColorsGray)
                          
                      }
                      
                      Button(action: {
                          self.viewModel.isEditing = false
                          self.viewModel.text = ""
                          
                      }) {
                          Text(viewModel.cancelButtonLabel)
                              .foregroundColor(.mainColorsGray)
                              .font(Font.system(size: 14))
                      }
                      .padding(.trailing, 20)
                      .transition(.move(edge: .trailing))
                      .animation(.default)
                  }
              }
          }
          .overlay(
            RoundedRectangle(cornerRadius: 8)
                .stroke(Color.bordersDivider, lineWidth: 1)
          )
      }
}

struct SearchBarComponent_Previews: PreviewProvider {
    static var previews: some View {
        
        Group {
         
            SearchBarComponent(viewModel: .init(placeHolder: .contacts))
                .previewLayout(.fixed(width: 375, height: 100))
            
            SearchBarComponent(viewModel: .init(isEditing: true, placeHolder: .contacts))
                .previewLayout(.fixed(width: 375, height: 100))
        }
    }
}
