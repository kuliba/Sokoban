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
        
        let icon: Image?
        @Published var text: String
        @Published var isEditing = false
        let placeHolder: PlaceHolder
        let cancelButtonLabel = "Отмена"
        var textColor: Color
        let phoneNumberKit = PhoneNumberKit()
        
        private var bindings = Set<AnyCancellable>()
        
        internal init(isEditing: Bool = false, placeHolder: PlaceHolder, icon: Image? = nil, text: String = "", textColor: Color) {
            
            self.isEditing = isEditing
            self.placeHolder = placeHolder
            self.icon = icon
            self.text = text
            self.textColor = textColor
            
            bind()
        }
        
        convenience init(_ model: Model, placeHolder: PlaceHolder) {
            
            self.init(placeHolder: placeHolder, textColor: .textPlaceholder)
        }
        
        enum PlaceHolder: String {
            
            case contacts = "Номер телефона или имя"
            case banks = "Введите название банка"
        }
        
        private func bind() {
            
            $text
                .receive(on: DispatchQueue.main)
                .sink { [unowned self] text in
                    
//                    self.parseNumber(text)
                    
                }.store(in: &bindings)
        }
        
        func parseNumber(_ number: String) {
            do {
                let phoneNumber = try phoneNumberKit.parse(number, ignoreType: true)
                self.text = self.phoneNumberKit.format(phoneNumber, toType: .international)
//                self.parsedCountryCodeLabel.text = String(phoneNumber.countryCode)
                if let regionCode = phoneNumberKit.mainCountry(forCode: phoneNumber.countryCode) {
                    let country = Locale.current.localizedString(forRegionCode: regionCode)
//                    self.parsedCountryLabel.text = country
                }
            } catch {
//                self.clearResults()
                print("Something went wrong")
            }
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
                .foregroundColor(viewModel.textColor)
                
            
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
            
            SearchBarComponent(viewModel: .init(.emptyMock, placeHolder: .contacts))
                .previewLayout(.fixed(width: 375, height: 100))
            
            SearchBarComponent(viewModel: .init(isEditing: true, placeHolder: .contacts, textColor: .textPlaceholder))
                .previewLayout(.fixed(width: 375, height: 100))
        }
    }
}
