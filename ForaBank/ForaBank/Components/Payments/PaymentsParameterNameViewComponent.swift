//
//  PaymentsParameterNameViewComponent.swift
//  ForaBank
//
//  Created by Константин Савялов on 10.02.2022.
//

import SwiftUI
import Combine

//MARK: - ViewModel

extension PaymentsParameterNameView {
    
    class ViewModel: PaymentsParameterViewModel {
        
        let icon: Image
        let title: String
        @Published var person: PersonViewModel
        @Published var isEditing: Bool
        
        lazy var action: () -> Void = { withAnimation{ self.isEditing.toggle() }}
        
        var fullName: String {
            
            return person.components.reduce("") { result, component in
                
                return component.count > 0 ?  "\(result) \(component)" : result
       
            }.trimmingCharacters(in: .whitespaces)
        }
        
        var buttonIcon: Image { isEditing ? Image("Payments Minus Squares") : Image("Payments Plus Squares")}
        
        private var bindings = Set<AnyCancellable>()
        
        init(icon: Image, title: String, person: PersonViewModel, isEditing: Bool, parameter: Payments.Parameter = .init(id: UUID().uuidString, value: "")) {
            
            self.icon = icon
            self.title = title
            self.person = person
            self.isEditing = isEditing
            super.init(parameter: parameter)
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

struct PaymentsParameterNameView: View {
    
    @ObservedObject var viewModel: PaymentsParameterNameView.ViewModel
    
    var body: some View {
        
        HStack(alignment: .top, spacing: 22) {
            
            viewModel.icon
                .resizable()
                .frame(width: 40, height: 40)
            
            VStack(alignment: .leading, spacing: 30)  {
                
                if viewModel.isEditing == false {
                    
                    FieldView(title: viewModel.title, value: .constant(viewModel.fullName), button: (viewModel.buttonIcon, viewModel.action))
                        .frame(height: 56)
                    
                } else {
                    
                    VStack(spacing: 0) {
                        
                        FieldView(title: viewModel.person.lastName.title, value: $viewModel.person.lastName.value, isEditable: true, button: (viewModel.buttonIcon, viewModel.action))
                            .frame(height: 56)
                        
                        FieldView(title: viewModel.person.firstName.title, value: $viewModel.person.firstName.value, isEditable: true)
                            .frame(height: 56)
                        
                        FieldView(title: viewModel.person.middleName.title, value: $viewModel.person.middleName.value, isEditable: true)
                            .frame(height: 56)
                    }
                }
            }
        }
    }
    
    struct FieldView: View {
        
        let title: String
        @Binding var value: String
        var isEditable: Bool = false
        var button: (icon: Image, action: () -> Void)?
        
        private var displayTitle: String { value.count > 0 ? title : "" }
        private var displayValue: String { value.count > 0 ? value : title }
        private var displayValueColor: Color { value.count > 0 ? Color(hex: "#1C1C1C") : Color(hex: "#999999") }
        
        var body: some View {
            
            VStack(alignment: .leading, spacing: 4) {
                
                Text(displayTitle)
                    .font(Font.custom("Inter-Regular", size: 12))
                    .foregroundColor(Color(hex: "#999999"))
                
                HStack(spacing: 0) {
                    
                    if isEditable == true {
                        
                        TextField(title, text: $value)
                            .foregroundColor(Color(hex: "#1C1C1C"))
                            .font(Font.custom("Inter-Medium", size: 14))
                        
                    } else {
                        
                        Text(displayValue)
                            .font(Font.custom("Inter-Regular", size: 14))
                            .foregroundColor(displayValueColor)
                    }
     
                    if let button = button {
                        
                        Spacer()
     
                        Button(action: button.action) {
                            
                            button.icon
                                .renderingMode(.template)
                                .resizable()
                                .frame(width: 24, height: 24)
                                .foregroundColor(Color(hex: "#999999"))
                        }
                    }
                }
                
                Divider()
                    .frame(height: 1)
                    .background(Color(hex: "#EAEBEB"))
                    .padding(.top, 8)
            }
        }
    }
}

//MARK: - Preview

struct PaymentsParameterNameView_Previews: PreviewProvider {
    
    static var previews: some View {
       
        Group {
            
            PaymentsParameterNameView(viewModel: .normal)
                .previewLayout(.fixed(width: 375, height: 100))
            
            PaymentsParameterNameView(viewModel: .edit)
                .previewLayout(.fixed(width: 375, height: 200))
            
            PaymentsParameterNameView(viewModel: .editPart)
                .previewLayout(.fixed(width: 375, height: 200))
            
            PaymentsParameterNameView.FieldView(title: "ФИО", value: .constant(""))
                .previewLayout(.fixed(width: 375, height: 56))
            
            PaymentsParameterNameView.FieldView(title: "ФИО", value: .constant("Иванов Иван Иванович"))
                .previewLayout(.fixed(width: 375, height: 56))
            
            PaymentsParameterNameView.FieldView(title: "Фамилия", value: .constant(""))
                .previewLayout(.fixed(width: 375, height: 56))
            
            PaymentsParameterNameView.FieldView(title: "Фамилия", value: .constant("Иванов"), isEditable: true)
                .previewLayout(.fixed(width: 375, height: 56))
            
            PaymentsParameterNameView.FieldView(title: "Имя", value: .constant("Иван"), isEditable: true)
                .previewLayout(.fixed(width: 375, height: 56))
        }
    }
}

//MARK: - Preview Content

extension PaymentsParameterNameView.ViewModel {
    
    static let normal = PaymentsParameterNameView.ViewModel(icon: Image("accountImage"), title: "ФИО", person: .init(lastName: .init(title: "Фамилия", value: "Иванов"), firstName: .init(title: "Имя", value: "Иван"), middleName: .init(title: "Отчество", value: "Иванович")), isEditing: false)
    
    static let edit = PaymentsParameterNameView.ViewModel(icon: Image("accountImage"), title: "ФИО", person: .init(lastName: .init(title: "Фамилия", value: "Иванов"), firstName: .init(title: "Имя", value: "Иван"), middleName: .init(title: "Отчество", value: "Иванович")), isEditing: true)
    
    static let editPart = PaymentsParameterNameView.ViewModel(icon: Image("accountImage"), title: "ФИО", person: .init(lastName: .init(title: "Фамилия", value: "Иванов"), firstName: .init(title: "Имя", value: ""), middleName: .init(title: "Отчество", value: "")), isEditing: true)
}
