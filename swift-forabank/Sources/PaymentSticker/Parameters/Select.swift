//
//  Select.swift
//  StickerPreview
//
//  Created by Igor Malyarov on 19.10.2023.
//

extension Operation.Parameter {
    
    public struct Select: Hashable, Identifiable {
        
        public let id: ParameterID
        let value: String?
        public let title: String
        let placeholder: String
        public let options: [Option]
        public let staticOptions: [Option]
        public let state: State
        
        public enum ParameterID: String {
        
            case selector
            case transferTypeSticker
            case citySelector
            case officeSelector
        }
        
        public init(
            id: ParameterID,
            value: String?,
            title: String,
            placeholder: String,
            options: [Operation.Parameter.Select.Option],
            staticOptions: [Operation.Parameter.Select.Option],
            state: Operation.Parameter.Select.State
        ) {
            self.id = id
            self.value = value
            self.title = title
            self.placeholder = placeholder
            self.options = options
            self.staticOptions = staticOptions
            self.state = state
        }
        
        public struct Option: Hashable, Identifiable {
            
            public let id: String
            let name: String
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
                    options: [OptionViewModel]
                ) {
                    self.iconName = iconName
                    self.title = title
                    self.placeholder = placeholder
                    self.options = options
                }
                
                public struct OptionViewModel: Hashable, Identifiable {
                    
                    public var id: Self { self }
                    let iconName: String
                    let name: String
                    
                    public init(
                        iconName: String,
                        name: String
                    ) {
                        self.iconName = iconName
                        self.name = name
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
            placeholder: parameter.placeholder,
            options: parameter.options,
            staticOptions: parameter.staticOptions,
            state: .list(
                .init(
                    iconName: idleViewModel.iconName,
                    title: parameter.title,
                    placeholder: parameter.placeholder,
                    options: parameter.options.map(
                        Option.optionViewModelMapper(option:)
                    )
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
            staticOptions: parameter.staticOptions,
            state: self.state
        )
    }
}

extension Operation.Parameter.Select.Option {
    
    static func optionViewModelMapper(option: Select.Option) -> OptionViewModel {
        
        return .init(iconName: option.iconName, name: option.name)
    }
}

extension Operation.Parameter.Select {
    
    static let branchSelect: Self = .init(
        id: .officeSelector,
        value: nil,
        title: "Выберите отделение",
        placeholder: "",
        options: [],
        staticOptions: [],
        state: .idle(.init(
            iconName: "ic24Bank",
            title: "Выберите отделение"
        )))
    
    static func officeSelect(office: Office) -> Self {
        
        .init(
            id: .officeSelector,
            value: office.id,
            title: "Выберите отделение",
            placeholder: "",
            options: [],
            staticOptions: [],
            state: .selected(.init(
                title: "Выберите отделение",
                placeholder: "",
                name: office.name,
                iconName: ""
            )))
    }
}
