//
//  PreviewContent.swift
//  
//
//  Created by Дмитрий Савушкин on 10.10.2023.
//

import Foundation

extension OperationViewModel {
    
    static let preview: OperationViewModel = .init(
        parameters: .preview
    )
    
    convenience init(
        parameters: [Operation.Parameter] = []
    ) {
        self.init(
            operation: .init(parameters: parameters),
            blackBoxGet: { request, completion in
                
                let (operation, event) = request
                completion(Self.reduce(operation, with: event))
            }
        )
    }
    
    // MARK: - Reducer
    
    // TODO: maybe replace generic `Error` with error type
    typealias OperationResult = Result<Operation, Error>
    
    static func reduce(
        _ operation: Operation,
        with event: Event
    ) -> OperationResult {
        
        var newOperation: Operation?
        
        switch event {
        case let .select(select):
            newOperation = Self.reduce(operation, with: select)
            
        case let .product(parameter):
            break
            
        case .continueButtonTapped:
            newOperation = Self.reduceWithContinueButtonTapped(operation)
        }
        
        if let newOperation {
            
            return .success(newOperation)
            
        } else {
            
            return .failure(NSError(domain: "No Operation", code: -1))
        }
    }
    
    static func reduce(
        _ operation: Operation,
        with event: Event.SelectEvent
    ) -> Operation? {
        
        switch event {
        case let .chevronTapped(parameter):
            switch parameter.state {
            case let .idle(idleViewModel):
                
                typealias Option = Operation.Parameter.Select.Option
                
                // TODO: repeated pattern - extract to change(update) state helper
                let parameter: Operation.Parameter.Select = .init(
                    id: parameter.id,
                    value: parameter.value,
                    title: parameter.title,
                    placeholder: parameter.title,
                    options: parameter.options,
                    state: .list(
                        .init(
                            iconName: idleViewModel.iconName,
                            title: parameter.title,
                            placeholder: parameter.placeholder,
                            options: parameter.options.map(Option.optionViewModelMapper(option:))
                        )
                    )
                )
                
                // TODO: replace with settable subscript
                guard let index = operation.parameters.firstIndex(where: { $0.id == parameter.id })
                else { return nil }
                
                var operation = operation
                operation.parameters[index] = .select(parameter)
                return operation
                
            case let .selected(selectedViewModel):
                
                let parameter = parameter.updateState(iconName: selectedViewModel.iconName)
                
                // TODO: repeated pattern - extract to settable subscript
                guard let index = operation.parameters.firstIndex(where: { $0.id == parameter.id })
                else { return nil }
                
                var operation = operation
                operation.parameters[index] = .select(parameter)
                return operation
                
            case let .list(listViewModel):
                
                let parameter = parameter.updateState(
                    iconName: listViewModel.iconName,
                    title: listViewModel.title
                )
                
                // TODO: repeated pattern - extract to settable subscript
                guard let index = operation.parameters.firstIndex(where: { $0.id == parameter.id })
                else { return nil }
                
                var operation = operation
                operation.parameters[index] = .select(parameter)
                return operation
            }
            
        case let .selectOption(id, parameter):
            
            print("select \(id), \(parameter)")
            
            // TODO: repeated pattern - extract to settable subscript
            guard let option = parameter.options.first(where: { $0.id == id })
            else { return nil }
            
            let parameter = parameter.updateState(with: option)
            
            // TODO: repeated pattern - extract to settable subscript
            guard let index = operation.parameters.firstIndex(where: { $0.id == parameter.id })
            else { return nil }
            
            var operation = operation
            operation.parameters[index] = .select(parameter)
            return operation
        }
    }
    
    static func reduceWithContinueButtonTapped(
        _ operation: Operation
    ) -> Operation {
        
        if operation.parameters.contains(where: { $0.id == "transferType" }),
           !operation.parameters.contains(where: { $0.id == "city" }) {
            
            var operation = operation
            operation.parameters.append(
                .select(.init(
                    id: "city",
                    value: "Выберите город",
                    title: "Выберите город",
                    placeholder: "Выберите значение",
                    options: [
                        .init(
                            id: "Москва",
                            name: "Москва",
                            iconName: ""
                        ),
                        .init(
                            id: "Санкт-Петербург",
                            name: "Санкт-Петербург",
                            iconName: ""
                        )],
                    state: .idle(.init(
                        iconName: "", title: "Выберите город"
                    ))))
            )
            
            return operation
            
        } else {
            
            var operation = operation
            operation.parameters.append(.amount(.init(title: "Продолжить", value: "790 Р")))
            
            return operation
        }
    }
}

extension Operation.Parameter.Select {
    
    func updateState(
        iconName: String
    ) -> Self {
        
        .init(
            id: id,
            value: value,
            title: title,
            placeholder: placeholder,
            options: options,
            state: .list(
                .init(
                    iconName: iconName,
                    title: title,
                    placeholder: title,
                    options: options.map(Option.optionViewModelMapper(option:))
                )
            )
        )
    }
    
    func updateState(
        iconName: String,
        title: String
    ) -> Self {
        
        .init(
            id: id,
            value: value,
            title: title,
            placeholder: placeholder,
            options: options,
            state: .idle(
                .init(
                    iconName: iconName,
                    title: title
                )
            )
        )
    }

    func updateState(
        with option: Operation.Parameter.Select.Option
    ) -> Self {
        
        .init(
            id: id,
            value: value,
            title: title,
            placeholder: placeholder,
            options: options,
            state: .selected(
                .init(
                    title: title,
                    placeholder: placeholder,
                    name: option.name,
                    iconName: option.iconName
                )
            )
        )
    }
}

extension Array where Element == Operation.Parameter {
    
    static let preview: Self = [
        .tip(.init(title: "Выберите счет карты, к которому будет привязан стикер")),
        .sticker(.init(
            title: "Платежный стике",
            description: "Стоимость обслуживания взимается единоразово за весь срок при заказе стикера",
            options: [
                .init(
                    title: "При получении в офисе",
                    description: "790 Р"
                ),
                .init(
                    title: "При доставке курьером",
                    description: "1500 Р")
            ]
        )),
        .product(.init(
            value: "",
            title: "Счет списания",
            nameProduct: "Gold",
            balance: "654 367 ₽",
            description: "・3387・Все включено"
        )),
        .select(.init(
            id: "transferType",
            value: "",
            title: "Выберите способ доставки",
            placeholder: "Выберите значение",
            options: [
                .init(id: "Получить в офисе", name: "Получить в офисе", iconName: ""),
                .init(id: "Доставка курьером", name: "Доставка курьером", iconName: "")
            ],
            state: .idle(.init(iconName: "", title: "Выберите способ доставки"))))
    ]
}
