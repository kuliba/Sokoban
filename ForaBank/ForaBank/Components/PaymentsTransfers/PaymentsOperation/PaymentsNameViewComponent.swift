//
//  PaymentsNameViewComponent.swift
//  ForaBank
//
//  Created by Константин Савялов on 10.02.2022.
//

import SwiftUI
import Combine
import TextFieldComponent

//MARK: - ViewModel

extension PaymentsNameView {
    
    class ViewModel: PaymentsParameterViewModel, ObservableObject {
        
        let icon: Image
        let title: String
        let person: PersonViewModel
        @Published var isExpanded: Bool
        
        var fullName: String? { return Self.nameReduce(personViewModel: person) }
        var fullNameViewModel: FullNameViewModel {
            
            .init(title: title, value: fullName ?? "", button: .init(icon: .ic24ChevronDown, action: buttonAction))
        }
        
        override var isValid: Bool {
            
            guard let parameterName = parameterName else {
                return false
            }
            
            switch parameterName.mode {
            case .regular:
                return parameterName.lastName.validator.isValid(value: person.lastName.textField.text) &&
                        parameterName.firstName.validator.isValid(value: person.firstName.textField.text) &&
                        parameterName.middleName.validator.isValid(value: person.middleName.textField.text)
                
            case .abroad:
                if value.isChanged  {
                    
                    return parameterName.lastName.validator.isValid(value: person.lastName.textField.text) &&
                            parameterName.firstName.validator.isValid(value: person.firstName.textField.text) &&
                            parameterName.middleName.validator.isValid(value: person.middleName.textField.text)
                    
                } else {
                    
                    return false
                }
            }
        }
        
        private var parameterName: Payments.ParameterName? { source as? Payments.ParameterName }
        private lazy var buttonAction: () -> Void = { [weak self] in withAnimation { self?.isExpanded.toggle() }}
        
        init(icon: Image, title: String, person: PersonViewModel, isExpanded: Bool, source: PaymentsParameterRepresentable = Payments.ParameterMock(id: UUID().uuidString)) {
            
            self.icon = icon
            self.title = title
            self.person = person
            self.isExpanded = isExpanded
            super.init(source: source)
        }
        
        convenience init(with parameterName: Payments.ParameterName) {
            
            let person = PersonViewModel(
                lastName: .init(name: parameterName.lastName),
                firstName: .init(name: parameterName.firstName),
                middleName: .init(name: parameterName.middleName))
            
            self.init(icon: .ic24User, title: parameterName.title, person: person, isExpanded: false, source: parameterName)
            
            person.lastName.button = .init(icon: .ic24ChevronRight, action: buttonAction)
            
            bind()
        }
        
        private func bind() {
            
            // last name
            person.lastName.textField.textPublisher()
                .receive(on: DispatchQueue.main)
                .sink { [unowned self] text in
                    
                    update(value: fullName)
                    
                }.store(in: &bindings)
            
            person.lastName.textField.isEditing()
                .dropFirst()
                .receive(on: DispatchQueue.main)
                .sink { [unowned self] isEditing in
                    
                    guard let parameterName = parameterName else {
                        return
                    }
                    
                    withAnimation(.easeInOut(duration: 0.2)) {
                        
                        if isEditing == true {
                            
                            // title
                            person.lastName.title = parameterName.lastName.title
                            
                            // warning
                            person.lastName.warning = nil
                            
                        } else {
      
                            // title
                            person.lastName.title = (person.lastName.textField.text != nil && person.lastName.textField.text != "") ? parameterName.lastName.title : nil
                            
                            // warning
                            if let action = parameterName.lastName.validator.action(with: person.lastName.textField.text, for: .post),
                               case .warning(let message) = action {
                                
                                person.lastName.warning = message
                                
                            } else {
                                
                                person.lastName.warning = nil
                            }
                        }
                    }
                    
                }.store(in: &bindings)
            
            // first name
            person.firstName.textField.textPublisher()
                .receive(on: DispatchQueue.main)
                .sink { [unowned self] text in
                    
                    update(value: fullName)
                    
                }.store(in: &bindings)
            
            person.firstName.textField.isEditing()
                .dropFirst()
                .receive(on: DispatchQueue.main)
                .sink { [unowned self] isEditing in
                    
                    guard let parameterName = parameterName else {
                        return
                    }
                    
                    withAnimation(.easeInOut(duration: 0.2)) {
                        
                        if isEditing == true {
                            
                            // title
                            person.firstName.title = parameterName.firstName.title
                            
                            // warning
                            person.firstName.warning = nil
                            
                        } else {
      
                            // title
                            person.firstName.title = (person.firstName.textField.text != nil && person.firstName.textField.text != "") ? parameterName.firstName.title : nil
                            
                            // warning
                            if let action = parameterName.firstName.validator.action(with: person.firstName.textField.text, for: .post),
                               case .warning(let message) = action {
                                
                                person.firstName.warning = message
                                
                            } else {
                                
                                person.firstName.warning = nil
                            }
                        }
                    }
                    
                }.store(in: &bindings)
            
            // middle name
            person.middleName.textField.textPublisher()
                .receive(on: DispatchQueue.main)
                .sink { [unowned self] text in
                    
                    update(value: fullName)
                    
                }.store(in: &bindings)
            
            person.middleName.textField.isEditing()
                .dropFirst()
                .receive(on: DispatchQueue.main)
                .sink { [unowned self] isEditing in
                    
                    guard let parameterName = parameterName else {
                        return
                    }
                    
                    withAnimation(.easeInOut(duration: 0.2)) {
                        
                        if isEditing == true {
                            
                            // title
                            person.middleName.title = parameterName.middleName.title
                            
                            // warning
                            person.middleName.warning = nil
                            
                        } else {
      
                            // title
                            person.middleName.title = (person.middleName.textField.text != nil && person.middleName.textField.text != "") ? parameterName.middleName.title : nil
                            
                            // warning
                            if let action = parameterName.middleName.validator.action(with: person.middleName.textField.text, for: .post),
                               case .warning(let message) = action {
                                
                                person.middleName.warning = message
                                
                            } else {
                                
                                person.middleName.warning = nil
                            }
                        }
                    }
                    
                }.store(in: &bindings)
        }
        
        override func updateValidationWarnings() {
            
            guard isValid == false, let parameterName = parameterName else {
                return
            }
            
            withAnimation {
                
                isExpanded = true
            }
            
            withAnimation(.easeInOut(duration: 0.2)) {
                
                if let lastNameAction = parameterName.lastName.validator.action(with: person.lastName.textField.text, for: .post),
                   case .warning(let message) = lastNameAction {
                    
                    person.lastName.warning = message
                    
                }
                
                if let firstNameAction = parameterName.firstName.validator.action(with: person.firstName.textField.text, for: .post),
                   case .warning(let message) = firstNameAction {
                    
                    person.firstName.warning = message
                    
                }
                
                if let middleNameAction = parameterName.middleName.validator.action(with: person.middleName.textField.text, for: .post),
                   case .warning(let message) = middleNameAction {
                    
                    person.middleName.warning = message
                }
            }
        }
    }
}

//MARK: - Types

extension PaymentsNameView.ViewModel {
    
    struct PersonViewModel {

        var lastName: NameViewModel
        var firstName: NameViewModel
        var middleName: NameViewModel

        var components: [String?] { [lastName.textField.text ?? nil, firstName.textField.text ?? nil, middleName.textField.text ?? nil] }
    }
    
    class NameViewModel: ObservableObject {
        
        @Published var title: String?
        @Published var textField: RegularFieldViewModel
        @Published var button: ButtonViewModel?
        @Published var warning: String?
        
        init(title: String?, textField: RegularFieldViewModel, button: ButtonViewModel? = nil) {
            
            self.title = title
            self.textField = textField
            self.button = button
        }
        
        convenience init(name: Payments.ParameterName.Name) {
      
            let title = name.value != nil ? name.title : nil
            let textField = TextFieldFactory.makeTextField(
                text: name.value,
                placeholderText: name.title,
                keyboardType: .default,
                limit: name.limitator.limit
            )
            
            self.init(title: title, textField: textField)
        }
    }
    
    struct FullNameViewModel {

        let title: String
        let value: String
        let button: ButtonViewModel
    }
    
    struct ButtonViewModel {
        
        let icon: Image
        let action: () -> Void
    }
}

//MARK: - Helpers

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
            
            HStack(alignment: .top, spacing: 18) {
                
                viewModel.icon
                    .resizable()
                    .frame(width: 24, height: 24)
                    .padding(.leading, 4)
                    .padding(.top, viewModel.isExpanded ? 30: 12)
                    .foregroundColor(Color.mainColorsGray)
                
                VStack(alignment: .leading, spacing: 0)  {
                    
                    if viewModel.isExpanded == false {
                        
                        FullNameView(viewModel: viewModel.fullNameViewModel)
                        
                    } else {
                        
                        FieldView(viewModel: viewModel.person.lastName)
                            .frame(minHeight: 72)
                        
                        Divider()
                            .frame(height: 1)
                            .foregroundColor(.mainColorsGrayMedium)
                            .opacity(0.5)
                            
                        FieldView(viewModel: viewModel.person.firstName)
                            .frame(minHeight: 72)
                        
                        Divider()
                            .frame(height: 1)
                            .foregroundColor(.mainColorsGrayMedium)
                            .opacity(0.5)
                            
                        FieldView(viewModel: viewModel.person.middleName)
                            .frame(minHeight: 72)
                    }
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 13)
            
        } else {
            
            HStack(spacing: 18) {
                
                viewModel.icon
                    .resizable()
                    .frame(width: 24, height: 24)
                    .padding(.leading, 4)
                    .foregroundColor(Color.mainColorsGray)
                
                FullNameView(viewModel: viewModel.fullNameViewModel, isUserInterractionEnabled: false)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 13)
        }
    }
}

//MARK: - Internal Views

extension PaymentsNameView {
    
    struct FullNameView: View {
        
        let viewModel: PaymentsNameView.ViewModel.FullNameViewModel
        var isUserInterractionEnabled: Bool = true
        
        var body: some View {
            
            VStack(alignment: .leading, spacing: 0) {
                
                Text(viewModel.title)
                    .font(.textBodyMR14180())
                    .foregroundColor(.textPlaceholder)
                    .padding(.bottom, 4)
                    .transition(.asymmetric(insertion: .move(edge: .bottom), removal: .opacity))
                
                HStack(spacing: 0) {
                    
                    Text(viewModel.value)
                        .lineLimit(1)
                        .font(.textBodyMR14200())
                        .foregroundColor(.textSecondary)
                        .frame(minHeight: 33)
                    
                    Spacer()
 
                    if isUserInterractionEnabled {
                        
                        Button(action: viewModel.button.action) {
                            
                            viewModel.button.icon
                                .renderingMode(.template)
                                .resizable()
                                .frame(width: 24, height: 24)
                                .foregroundColor(.textPlaceholder)
                        }
                    }
                }
            }
            .onTapGesture {
                
                if isUserInterractionEnabled == true {
                    
                    viewModel.button.action()
                }
            }
        }
    }
    
    struct FieldView: View {
        
        @ObservedObject var viewModel: PaymentsNameView.ViewModel.NameViewModel

        var body: some View {
            
            VStack(alignment: .leading, spacing: 0) {
                
                if let title = viewModel.title {
                    
                    Text(title)
                        .font(.textBodyMR14180())
                        .foregroundColor(.textPlaceholder)
                        .padding(.bottom, 4)
                        .transition(.asymmetric(insertion: .move(edge: .bottom), removal: .opacity))
                }
                
                HStack(spacing: 0) {
  
                    RegularTextFieldView(viewModel: viewModel.textField, font: .systemFont(ofSize: 14), textColor: .textSecondary)
                        .frame(minWidth: 24)
                        .font(.textBodyMM14200())
                    
                    Spacer()
     
                    if let button = viewModel.button {

                        Button(action: button.action) {
                            
                            button.icon
                                .renderingMode(.template)
                                .resizable()
                                .frame(width: 24, height: 24)
                                .foregroundColor(.textPlaceholder)
                        }
                    }
                }

                if let warning = viewModel.warning {
                    
                    Text(warning)
                        .font(.textBodySR12160())
                        .foregroundColor(.systemColorError)
                }
            }
        }
    }
}

//MARK: - Preview

struct PaymentsNameView_Previews: PreviewProvider {
    
    private static func preview(_ viewModel: PaymentsGroupViewModel) -> some View {
        PaymentsGroupView(viewModel: viewModel)
    }

    static var previews: some View {
       
        Group {

            preview(PaymentsGroupViewModel(items: [PaymentsNameView.ViewModel.normal]))
                .previewLayout(.fixed(width: 375, height: 100))
            
            preview(PaymentsGroupViewModel(items: [PaymentsNameView.ViewModel.normalNotEditable]))
                .previewLayout(.fixed(width: 375, height: 100))

            preview(PaymentsGroupViewModel(items: [PaymentsNameView.ViewModel.edit]))
                .previewLayout(.fixed(width: 375, height: 320))

            preview(PaymentsGroupViewModel(items: [PaymentsNameView.ViewModel.editPart]))
                .previewLayout(.fixed(width: 375, height: 320))
        }
    }
}

//MARK: - Preview Content

extension PaymentsNameView.ViewModel {
    
    static let normal = PaymentsNameView.ViewModel(with: .init(.init(id: UUID().uuidString, value: "Иванов Иван Иванович"), title: "ФИО", lastName: .init(title: "Фамилия", value: "Иванов", validator: .baseName, limitator: .init(limit: 158)), firstName: .init(title: "Имя", value: "Иван", validator: .baseName, limitator: .init(limit: 158)), middleName: .init(title: "Отчество", value: "Иванович", validator: .baseName, limitator: .init(limit: 158))))

    static let normalNotEditable = PaymentsNameView.ViewModel(with: .init(.init(id: UUID().uuidString, value: "Иванов Иван Иванович"), title: "ФИО", lastName: .init(title: "Фамилия", value: "Иванов", validator: .baseName, limitator: .init(limit: 158)), firstName: .init(title: "Имя", value: "Иван", validator: .baseName, limitator: .init(limit: 158)), middleName: .init(title: "Отчество", value: "Иванович", validator: .baseName, limitator: .init(limit: 158)), isEditable: false))

    static let edit: PaymentsNameView.ViewModel = {

        var viewModel = PaymentsNameView.ViewModel(with: .init(.init(id: UUID().uuidString, value: "Иванов Иван Иванович"), title: "ФИО", lastName: .init(title: "Фамилия", value: "Иванов", validator: .baseName, limitator: .init(limit: 158)), firstName: .init(title: "Имя", value: "Иван", validator: .baseName, limitator: .init(limit: 158)), middleName: .init(title: "Отчество", value: "Иванович", validator: .anyValue, limitator: .init(limit: 158))))

        viewModel.isExpanded = true
        

        return viewModel
    }()


    static let editPart: PaymentsNameView.ViewModel = {

        var viewModel = PaymentsNameView.ViewModel(with: .init(.init(id: UUID().uuidString, value: "Иванов Иван Иванович"), title: "ФИО", lastName: .init(title: "Фамилия", value: "Напу Амо Хала Она Она Анека Вехи Вехи Она Хивеа Нена Вава", validator: .baseName, limitator: .init(limit: 158)), firstName: .init(title: "Имя", value: nil, validator: .baseName, limitator: .init(limit: 158)), middleName: .init(title: "Отчество", value: nil, validator: .baseName, limitator: .init(limit: 158))))

        viewModel.isExpanded = true
        viewModel.person.firstName.warning = "Поле не может быть пустым."
        viewModel.person.middleName.warning = "Поле не может быть пустым."

        return viewModel
    }()
}
