//
//  Select.swift
//  StickerPreview
//
//  Created by Igor Malyarov on 19.10.2023.
//

extension Operation.Parameter {
    
    struct Select: Hashable, Identifiable {
        
        let id: String
        let value: String
        let title: String
        let placeholder: String
        let options: [Option]
        let state: State
        
        struct Option: Hashable {
            
            let id: String
            let name: String
            let iconName: String
        }
        
        enum State: Hashable {
            
            case idle(IdleViewModel)
            case selected(SelectedOptionViewModel)
            case list(OptionsListViewModel)
            
            struct IdleViewModel: Hashable {
                
                let iconName: String
                let title: String
            }
            
            struct SelectedOptionViewModel: Hashable {
                
                let title: String
                let placeholder: String
                let name: String
                let iconName: String
            }
            
            struct OptionsListViewModel: Hashable {
                
                let iconName: String
                let title: String
                let placeholder: String
                let options: [OptionViewModel]
                
                struct OptionViewModel: Hashable, Identifiable {
                    
                    let id: String
                    let iconName: String
                    let name: String
                }
            }
        }
    }
}

//MARK: Helper

extension Operation.Parameter.Select {

    typealias IdleViewModel = Operation.Parameter.Select.State.IdleViewModel
    
    func updateSelect(
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
    
    static func optionViewModelMapper(option: Select.Option) -> OptionViewModel {
        
        return .init(id: option.id, iconName: option.iconName, name: option.name)
    }
}
