//
//  PaymentsNameViewComponent.swift
//  ForaBank
//
//  Created by Константин Савялов on 10.02.2022.
//

import SwiftUI
import Combine

//MARK: - ViewModel

extension PaymentsNameView {
    
    class ViewModel: PaymentsParameterViewModel, ObservableObject {
        
        let icon: Image
        let title: String
        let person: PersonViewModel
        @Published var isEditing: Bool
        
        lazy var buttonAction: () -> Void = { [weak self] in withAnimation{ self?.isEditing.toggle() }}
        
        var fullName: String? {
            
            return Self.nameReduce(personViewModel: person)
        }
        
        var buttonIcon: Image { isEditing ? Image.ic24MinusSquares : Image.ic24PlusSquares}
        
        private static let iconPlaceholder = Image.ic24Customer
        
        init(icon: Image, title: String, person: PersonViewModel, isEditing: Bool, source: PaymentsParameterRepresentable = Payments.ParameterMock(id: UUID().uuidString)) {
            
            self.icon = icon
            self.title = title
            self.person = person
            self.isEditing = isEditing
            super.init(source: source)
        }
        
        init(with parameterName: Payments.ParameterName) {
            
            self.icon = Self.iconPlaceholder
            self.title = parameterName.title
            
            self.person = PersonViewModel(
                lastName: .init(title: parameterName.lastName.title, textField: .init(text: parameterName.lastName.value, placeholder: parameterName.lastName.title, style: .default, limit: 160)),
                firstName: .init(title: parameterName.firstName.title, textField: .init(text: parameterName.firstName.value, placeholder: parameterName.firstName.title, style: .default, limit: 160)),
                middleName: .init(title: parameterName.firstName.title, textField: .init(text: parameterName.middleName.value, placeholder: parameterName.middleName.title, style: .default, limit: 160)))
            
            self.isEditing = false
            super.init(source: parameterName)
            
            bind()
        }
        
        struct PersonViewModel {

            var lastName: NameViewModel
            var firstName: NameViewModel
            var middleName: NameViewModel
   
            var components: [String?] { [lastName.textField.text ?? nil, firstName.textField.text ?? nil, middleName.textField.text ?? nil] }
        }
        
        class NameViewModel: ObservableObject {
            
            @Published var title: String?
            @Published var textField: TextFieldRegularView.ViewModel
            
            let icon: Image?
            let button: ButtonViewModel?
            
            var bindings = Set<AnyCancellable>()
            
            init(title: String?, textField: TextFieldRegularView.ViewModel, icon: Image? = nil, button: ButtonViewModel? = nil) {
                
                self.title = title
                self.textField = textField
                self.icon = icon
                self.button = button
                
                bind()
            }
            
            struct ButtonViewModel {
                
                let icon: Image
                let action: () -> Void
            }
            
            func bind() {
                
                textField.$text
                    .receive(on: DispatchQueue.main)
                    .sink { [unowned self] content in
                        
                        withAnimation(.easeInOut(duration: 0.2)) {
                            
                            title = (textField.text != nil || textField.text != "") ? textField.placeholder : ""
                        }
                        
                    }.store(in: &bindings)
            }
        }
    }
}

//MARK: - Bindings

extension PaymentsNameView.ViewModel {

    private func bind() {
        
        person.firstName.textField.$text
            .receive(on: DispatchQueue.main)
            .sink { [unowned self] text in
                
                update(value: Self.nameReduce(personViewModel: self.person))

            }.store(in: &bindings)
        
        person.middleName.textField.$text
            .receive(on: DispatchQueue.main)
            .sink { [unowned self] text in
            
                update(value: Self.nameReduce(personViewModel: self.person))

            }.store(in: &bindings)
        
        person.lastName.textField.$text
            .receive(on: DispatchQueue.main)
            .sink { [unowned self] text in
            
                update(value: Self.nameReduce(personViewModel: self.person))

            }.store(in: &bindings)
    }
}

//MARK: Reduce's

extension PaymentsNameView.ViewModel {
    
    static func nameReduce(personViewModel: PersonViewModel) -> String? {
        
        var fullName = ""
        
        for name in personViewModel.components {
            
            guard let name = name else {
                continue
            }
            
            fullName += String("\(name) ")
        }
        
        let trimName = fullName.trimmingCharacters(in: .whitespaces)
        
        if trimName == "" {
            
            return nil
        } else {
            
            return fullName
        }
    }
}

//MARK: - View

struct PaymentsNameView: View {
    
    @ObservedObject var viewModel: PaymentsNameView.ViewModel
    
    var body: some View {
        
        if viewModel.isEditable == true {
            
            VStack(alignment: .leading, spacing: 24)  {
                
                if viewModel.isEditing == false {
                    
                    FieldView(icon: viewModel.icon, button: (viewModel.buttonIcon, viewModel.buttonAction), viewModel: .init(title: viewModel.title, textField: .init(text: viewModel.fullName, placeholder: viewModel.title, style: .default, limit: 158)))
                    
                } else {
                    
                    FieldView(icon: viewModel.icon, isEditing: true, button: (viewModel.buttonIcon, viewModel.buttonAction), viewModel: viewModel.person.lastName)
                        
                    FieldView(isEditing: true, viewModel: viewModel.person.firstName)
                        
                    FieldView(isEditing: true, viewModel: viewModel.person.middleName)
                }
            }
            
        } else {
            
            HStack(spacing: 0) {
                
                FieldView(icon: viewModel.icon, isDivider: false, viewModel: .init(title: viewModel.title, textField: .init(text: viewModel.fullName, placeholder: viewModel.title, style: .default, limit: 158)))
                
                Spacer()
            }
        }
    }
    
    struct FieldView: View {
        
        var icon: Image? = nil
        var isEditing: Bool = false
        var button: (icon: Image, action: () -> Void)? = nil
        var isDivider: Bool = true
        
        @ObservedObject var viewModel: PaymentsNameView.ViewModel.NameViewModel
        
        var body: some View {
            
            VStack(alignment: .leading, spacing: 0) {
                
                if let title = viewModel.title, viewModel.textField.text != nil, viewModel.textField.text != "" {
                    
                    Text(title)
                        .font(.textBodySR12160())
                        .foregroundColor(.textPlaceholder)
                        .padding(.bottom, 4)
                        .padding(.leading, 48)
                        .transition(.asymmetric(insertion: .move(edge: .bottom), removal: .opacity))
                }
                
                HStack(spacing: 0) {
                    
                    if let icon = icon {
                        
                        icon
                            .resizable()
                            .frame(width: 24, height: 24)
                            .padding(.leading, 4)
                            .foregroundColor(Color.mainColorsGray)
                        
                    } else {
                        
                        Color.clear
                            .frame(width: 24, height: 24)
                            .padding(.leading, 4)
                    }
 
                    if isEditing == true {
                        
                        TextFieldRegularView(viewModel: viewModel.textField, font: .systemFont(ofSize: 14), textColor: .textSecondary)
                            .frame(minWidth: 24)
                            .font(.textBodyMM14200())
                            .padding(.leading, 20)
                        
                    } else {
                        
                        Text(viewModel.textField.text ?? viewModel.title ?? "")
                            .lineLimit(1)
                            .font(.textBodyMR14200())
                            .foregroundColor(viewModel.textField.text == nil ? .textPlaceholder : .textSecondary)
                            .padding(.leading, 20)
                    }
     
                    if let button = button {
                        
                        Spacer()
     
                        Button(action: button.action) {
                            
                            button.icon
                                .renderingMode(.template)
                                .resizable()
                                .frame(width: 24, height: 24)
                                .foregroundColor(.textPlaceholder)
                        }
                    }
                }
                .onTapGesture {
                    
                    if isEditing == false {
                        
                        button?.action()
                    }
                }
                
                Divider()
                    .frame(height: 1)
                    .background(Color.bordersDivider)
                    .opacity(isDivider ? 1.0 : 0.2)
                    .padding(.top, 12)
                    .padding(.leading, 48)
            }
        }
    }
}

//MARK: - Preview

struct PaymentsNameView_Previews: PreviewProvider {
    
    static var previews: some View {
       
        Group {

            PaymentsNameView(viewModel: .normal)
                .previewLayout(.fixed(width: 375, height: 100))

            PaymentsNameView(viewModel: .normalNotEditable)
                .previewLayout(.fixed(width: 375, height: 100))

            PaymentsNameView(viewModel: .edit)
                .previewLayout(.fixed(width: 375, height: 200))

            PaymentsNameView(viewModel: .editPart)
                .previewLayout(.fixed(width: 375, height: 200))

            PaymentsNameView.FieldView(viewModel: .init(title: "ФИО", textField: .init(text: nil, placeholder: nil, style: .default, limit: 157)))
                .previewLayout(.fixed(width: 375, height: 56))
        }
    }
}

//MARK: - Preview Content

extension PaymentsNameView.ViewModel {
    
    static let normal = try! PaymentsNameView.ViewModel(with: .init(.init(id: UUID().uuidString, value: "Иванов Иван Иванович"), title: "ФИО", lastName: .init(title: "Фамилия", value: "Иванов"), firstName: .init(title: "Имя", value: "Иван"), middleName: .init(title: "Отчество", value: "Иванович")))

    static let normalNotEditable = try! PaymentsNameView.ViewModel(with: .init(.init(id: UUID().uuidString, value: "Иванов Иван Иванович"), title: "ФИО", lastName: .init(title: "Фамилия", value: "Иванов"), firstName: .init(title: "Имя", value: "Иван"), middleName: .init(title: "Отчество", value: "Иванович"), isEditable: false))

    static let edit: PaymentsNameView.ViewModel = {

        var viewModel = try! PaymentsNameView.ViewModel(with: .init(.init(id: UUID().uuidString, value: "Иванов Иван Иванович"), title: "ФИО", lastName: .init(title: "Фамилия", value: "Иванов"), firstName: .init(title: "Имя", value: "Иван"), middleName: .init(title: "Отчество", value: "Иванович")))

        viewModel.isEditing = true

        return viewModel
    }()


    static let editPart: PaymentsNameView.ViewModel = {

        var viewModel = try! PaymentsNameView.ViewModel(with: .init(.init(id: UUID().uuidString, value: "Иванов Иван Иванович"), title: "ФИО", lastName: .init(title: "Фамилия", value: "Иванов"), firstName: .init(title: "Имя", value: ""), middleName: .init(title: "Отчество", value: "")))

        viewModel.isEditing = true

        return viewModel
    }()
}
