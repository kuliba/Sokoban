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
        @Published var person: PersonViewModel
        @Published var isEditing: Bool
        
        lazy var buttonAction: () -> Void = { [weak self] in withAnimation{ self?.isEditing.toggle() }}
        
        var fullName: String {
            
            return person.components.reduce("") { result, component in
                
                return component.count > 0 ?  "\(result) \(component)" : result
       
            }.trimmingCharacters(in: .whitespaces)
        }
        
        var buttonIcon: Image { isEditing ? Image("Payments Minus Squares") : Image("Payments Plus Squares")}
        
        private static let iconPlaceholder = Image("Payments Icon Person")
        
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
                lastName: .init(
                    title: parameterName.lastName.title,
                    value: parameterName.lastName.value),
                firstName: .init(
                    title: parameterName.firstName.title,
                    value: parameterName.firstName.value),
                middleName: .init(
                    title: parameterName.middleName.title,
                    value: parameterName.middleName.value))
            self.isEditing = false
            super.init(source: parameterName)
        }
        
        struct PersonViewModel {

            var lastName: NameViewModel
            var firstName: NameViewModel
            var middleName: NameViewModel
   
            var components: [String] { [lastName.value, firstName.value, middleName.value] }
        }
        
        class NameViewModel: ObservableObject {
            
            let title: String
            @Published var value: String
            
            init(title: String, value: String) {
                
                self.title = title
                self.value = value
            }
        }
    }
}

//MARK: - View

struct PaymentsNameView: View {
    
    @ObservedObject var viewModel: PaymentsNameView.ViewModel
    
    var body: some View {
        
        if viewModel.isEditable == true {
            
            VStack(alignment: .leading, spacing: 30)  {
                
                if viewModel.isEditing == false {
                    
                    FieldView(icon: viewModel.icon, title: viewModel.title, value: .constant(viewModel.fullName), button: (viewModel.buttonIcon, viewModel.buttonAction))
                    
                } else {
                    
                    VStack(spacing: 8) {
                        
                        FieldView(icon: viewModel.icon, title: viewModel.person.lastName.title, value: $viewModel.person.lastName.value, isEditing: true, button: (viewModel.buttonIcon, viewModel.buttonAction))
                        
                        FieldView(title: viewModel.person.firstName.title, value: $viewModel.person.firstName.value, isEditing: true)
                        
                        FieldView(title: viewModel.person.middleName.title, value: $viewModel.person.middleName.value, isEditing: true)
                    }
                }
            }
            
        } else {
            
            HStack(spacing: 0) {
                
                FieldView(icon: viewModel.icon, title: viewModel.title, value: .constant(viewModel.fullName), isDivider: false)
                
                Spacer()
            }
        }
    }
    
    struct FieldView: View {
        
        var icon: Image? = nil
        let title: String
        @Binding var value: String
        var isEditing: Bool = false
        var button: (icon: Image, action: () -> Void)? = nil
        var isDivider: Bool = true
        
        private var displayTitle: String { value.count > 0 ? title : "" }
        private var displayValue: String { value.count > 0 ? value : title }
        private var displayValueColor: Color { value.count > 0 ? Color.textSecondary : Color.textPlaceholder }
        
        var body: some View {
            
            VStack(alignment: .leading, spacing: 0) {
                
                Text(displayTitle)
                    .font(.textBodySR12160())
                    .foregroundColor(.textPlaceholder)
                    .padding(.leading, 48)
                    .padding(.bottom, 4)
                
                HStack(spacing: 0) {
                    
                    if let icon = icon {
                        
                        icon
                            .resizable()
                            .frame(width: 24, height: 24)
                            .padding(.leading, 4)
                        
                    } else {
                        
                        Color.clear
                            .frame(width: 24, height: 24)
                            .padding(.leading, 4)
                    }
 
                    if isEditing == true {
                        
                        TextField(title, text: $value)
                            .foregroundColor(.textSecondary)
                            .font(.textBodyMM14200())
                            .padding(.leading, 20)
                        
                    } else {
                        
                        Text(displayValue)
                            .font(.textBodyMR14200())
                            .foregroundColor(displayValueColor)
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
            
            PaymentsNameView.FieldView(title: "ФИО", value: .constant(""))
                .previewLayout(.fixed(width: 375, height: 56))
            
            PaymentsNameView.FieldView(title: "ФИО", value: .constant("Иванов Иван Иванович"))
                .previewLayout(.fixed(width: 375, height: 56))
            
            PaymentsNameView.FieldView(title: "Фамилия", value: .constant(""))
                .previewLayout(.fixed(width: 375, height: 56))
            
            PaymentsNameView.FieldView(title: "Фамилия", value: .constant("Иванов"), isEditing: true)
                .previewLayout(.fixed(width: 375, height: 56))
            
            PaymentsNameView.FieldView(title: "Имя", value: .constant("Иван"), isEditing: true)
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
