//
//  Select.swift
//  StickerPreview
//
//  Created by Igor Malyarov on 19.10.2023.
//

extension Operation.Parameter {
    
    public struct Select: Hashable, Identifiable {
        
        public let id: ParameterID
        let value: String
        public let title: String
        let placeholder: String
        public let options: [Option]
        public let state: State
        
        public enum ParameterID: String {
        
            case selector
            case transferTypeSticker
            case citySelector
            case officeSelector
        }
        
        public init(
            id: ParameterID,
            value: String,
            title: String,
            placeholder: String,
            options: [Operation.Parameter.Select.Option],
            state: Operation.Parameter.Select.State
        ) {
            self.id = id
            self.value = value
            self.title = title
            self.placeholder = placeholder
            self.options = options
            self.state = state
        }
        
        public struct Option: Hashable {
            
            public let id: String
            let name: String
            //TODO: setup ImageData 
            public let iconName: String
            
            public init(
                id: String,
                name: String,
                iconName: String
            ) {
                self.id = id
                self.name = name
                self.iconName = iconName
            }
        }
        
        public enum State: Hashable {
            
            case idle(IdleViewModel)
            case selected(SelectedOptionViewModel)
            case list(OptionsListViewModel)
            
            public struct IdleViewModel: Hashable {
                
                public let iconName: String
                public let title: String
                
                public init(
                    iconName: String,
                    title: String
                ) {
                    self.iconName = iconName
                    self.title = title
                }
            }
            
            public struct SelectedOptionViewModel: Hashable {
                
                public let title: String
                let placeholder: String
                public let name: String
                public let iconName: String
                
                public init(
                    title: String,
                    placeholder: String,
                    name: String,
                    iconName: String
                ) {
                    self.title = title
                    self.placeholder = placeholder
                    self.name = name
                    self.iconName = iconName
                }
            }
            
            public struct OptionsListViewModel: Hashable {
                
                public let iconName: String
                public let title: String
                let placeholder: String
                let options: [OptionViewModel]
                
                public init(
                    iconName: String,
                    title: String,
                    placeholder: String,
                    options: [Operation.Parameter.Select.State.OptionsListViewModel.OptionViewModel]
                ) {
                    self.iconName = iconName
                    self.title = title
                    self.placeholder = placeholder
                    self.options = options
                }
                
                public struct OptionViewModel: Hashable, Identifiable {
                    
                    public let id: OptionType
                    let iconName: String
                    let name: String
                    
                    public init(
                        id: OptionType,
                        iconName: String,
                        name: String
                    ) {
                        self.id = id
                        self.iconName = iconName
                        self.name = name
                    }
                    
                    public enum OptionType: String {
                        
                        case typeDeliveryOffice
                        case stickerOrderDeliveryCourier
                        case option
                    }
                }
            }
        }
    }
}

//MARK: Helper

extension Operation.Parameter.Select {

    public typealias IdleViewModel = Operation.Parameter.Select.State.IdleViewModel
    
    public func updateSelect(
        parameter: Operation.Parameter.Select,
        idleViewModel: IdleViewModel
    ) -> Operation.Parameter.Select {
     
        .init(
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
    }
}

typealias Select = Operation.Parameter.Select
typealias OptionViewModel = Select.State.OptionsListViewModel.OptionViewModel

extension Operation.Parameter.Select {

    func updateOptions(
        parameter: Select,
        options: [Select.Option]
    ) -> Select {
    
        .init(
            id: self.id,
            value: self.value,
            title: self.title,
            placeholder: self.placeholder,
            options: options,
            state: self.state
        )
    }
}

extension Operation.Parameter.Select.Option {
    
    typealias OptionType = Operation.Parameter.Select.State.OptionsListViewModel.OptionViewModel.OptionType
    
    static func optionViewModelMapper(option: Select.Option) -> OptionViewModel {
        
        let id = OptionType(rawValue: option.id) ?? .option
        return .init(id: id, iconName: option.iconName, name: option.name)
    }
}
