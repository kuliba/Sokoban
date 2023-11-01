//
//  ContentPreviewForBuild.swift
//  StickerPreview
//
//  Created by Дмитрий Савушкин on 25.10.2023.
//

import Foundation

extension BusinessLogic {
    
    static let preview: BusinessLogic = .init(
        dictionaryService: { fatalError() }(),
        transfer: { fatalError() }(),
        reduce: { fatalError() }()
    )
}

extension OperationStateViewModel {
    
    static let previewWithBusinessLogic: OperationStateViewModel = .init(
        businessLogic: .preview
    )
    
    convenience init(
        businessLogic: BusinessLogic
    ) {
        self.init(blackBoxGet: { request, completion in
            
            let (operation, event) = request
            businessLogic.operationResult(
                operation: operation,
                event: event,
                completion: completion
            )
        })
    }
}

extension OperationStateViewModel {
    
    public static let preview: OperationStateViewModel = .init(
        parameters: .preview
    )
    
    convenience init(
        parameters: [Operation.Parameter] = []
    ) {
        self.init(
            state: .operation(.init(parameters: parameters)),
            blackBoxGet: { request, completion in
                
                let (operation, event) = request
                let result = Self.reduce(operation, with: event)
                
                switch result {
                case let .success(operation):
                    completion(.success(.operation(operation)))
                    
                case let .failure(error):
                    completion(.failure(error))
                }
            })
    }
    
    // MARK: - Reducer
    
    // TODO: maybe replace generic `Error` with error type
    typealias OperationStateResult = Result<Operation, Error>
    
    static func reduce(
        _ operation: Operation,
        with event: Event
    ) -> OperationStateResult {
        
        var newOperation: Operation?
        
        switch event {
        case let .select(selectEvents):
            newOperation = Self.reduce(operation, with: selectEvents)
            
        case let .product(productEvents):
            
            switch productEvents {
            case let .chevronTapped(product, state):
                let operation = operation.updateOperation(
                    operation: operation,
                    newParameter: .product(.init(
                        state: state,
                        selectedProduct: product.selectedProduct,
                        allProducts: product.allProducts
                    ))
                )
                newOperation = operation
                
            case let .selectProduct(option, product):
                break
            }
            
        case .continueButtonTapped:
            newOperation = Self.reduceWithContinueButtonTapped(operation)
            
        case let .input(inputEvents):
            newOperation = Self.reduceInput(operation, with: inputEvents)
        }
        
        if let newOperation {
            
            return .success(newOperation)
            
        } else {
            
            return .failure(NSError(domain: "No Operation", code: -1))
        }
    }
    
    static func reduceInput(
        _ operation: Operation,
        with event: Event.InputEvent
    ) -> Operation {
        
        switch event {
        case .getOtpCode:
            
            #warning("setup getCode request")
            //TODO: setup getCode request
            return operation
            
        case let .valueUpdate(input):
            
            return operation.updateOperation(
                operation: operation,
                newParameter: .input(input)
            )
        }
    }
    
    static func reduce(
        _ operation: Operation,
        with event: Event.SelectEvent
    ) -> Operation? {
        
        switch event {
        case let .selectOption(id, parameter):
            
            // TODO: repeated pattern - extract to settable subscript
            guard let option = parameter.options.first(where: { $0.id == id })
            else { return nil }
            
            let parameter = parameter.updateValue(
                parameter: parameter,
                option: option
            )
            
            let updateParameter = parameter.updateState(with: option)
            
            return operation.updateOperation(
                operation: operation,
                newParameter: .select(updateParameter)
            )

        case .openBranch:
            //TODO: send Branch View
            return nil
        }
    }
    
    fileprivate static func appendCitySelector(_ operation: Operation) -> Operation {
        
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
    }
    
    fileprivate static func appendAmount(_ operation: Operation) -> Operation {
        
        var operation = operation
        operation.parameters.append(.amount(.init(value: "790 Р")))
        
        return operation
    }
    
    fileprivate static func appendBranchSelector(_ operation: Operation) -> Operation {
        
        var operation = operation
        operation.parameters.append(.select(.init(
            id: "branches",
            value: "",
            title: "Выберите отделение",
            placeholder: "Выберите отделение",
            options: [],
            state: .idle(.init(
                iconName: "",
                title: "Выберите отделение"
            ))))
        )
        
        return operation
    }
    
    fileprivate static func appendCode(_ operation: Operation) -> Operation {
        
        var operation = operation
        if let indexAmountParameter = operation.parameters.firstIndex(where: { $0.id == .amount }) {
            
            operation.parameters.remove(at: indexAmountParameter)
        }
        
        operation.parameters.append(.input(.init(value: "", title: "Введите код", icon: "system name")))
        
        return operation
    }
    
    static func reduceWithContinueButtonTapped(
        _ operation: Operation
    ) -> Operation {
        
        if operation.parameters.contains(where: { $0.id == .amount }) {
            
            return appendCode(operation)
            
        } else if operation.parameters.contains(where: { $0.id == .city }) {
            
            return appendAmount(operation)
            
        } else if let select = operation.parameters.getParameterTransferType() {
            
            if select.value == "Получить в офисе" {
                
                var operation = operation
                operation = appendCitySelector(operation)
                
                return appendBranchSelector(operation)
                
            } else {
                //select.value == "Доставка курьером"
                return appendCitySelector(operation)
            }
        }
        
        return operation
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
            state: .select,
            selectedProduct: .init(number: "3387", paymentSystem: "", background: "", value: "", title: "Счет списания", nameProduct: "Gold", balance: "654 367 ₽", description: "・3387・Все включено"),
            allProducts: [.init(number: "3387", paymentSystem: "", background: "", value: "", title: "Счет списания", nameProduct: "Gold", balance: "654 367 ₽", description: "・3387・Все включено")])
        ),
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
