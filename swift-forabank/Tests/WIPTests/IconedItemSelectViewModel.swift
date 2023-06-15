//
//  IconedItemSelectViewModel.swift
//  
//
//  Created by Igor Malyarov on 03.06.2023.
//

import Combine
import Foundation

final class IconedItemSelectViewModel<Item, IconData>: ObservableObject
where Item: Equatable,
      IconData: Equatable {
    
    @Published private(set) var state: State
    
    let title: String
    let textField: any TextField
    private let send: (ItemSelectModel<Item>.Action) -> Void
    
    typealias SelectState = ItemSelectModel<Item>.State
    
    init(
        title: String,
        initialState: State,
        textField: any TextField,
        selectStateLoader: AnyPublisher<SelectState, Never>,
        send: @escaping (ItemSelectModel<Item>.Action) -> Void,
        iconDataLoader: AnyPublisher<IconData, Never>,
        scheduler: AnySchedulerOfDispatchQueue = .makeMain()
    ) {
        self.title = title
        self.textField = textField
        self.state = initialState
        self.send = send
        
        Publishers
            .MergeMany(
                selectStateLoader
                    .map { (SelectState?.some($0), IconData?.none) }
                    .eraseToAnyPublisher()
                ,
                iconDataLoader
                    .map { (SelectState?.none, IconData?.some($0)) }
                    .eraseToAnyPublisher()
            )
            .scan(initialState) { state, tuple in
                
                    .init(
                        selectState: tuple.0 ?? state.selectState,
                        iconData: tuple.1 ?? state.iconData
                    )
            }
            .removeDuplicates()
            .receive(on: scheduler)
            .assign(to: &$state)
    }
    
    func send(_ action: ItemSelectModel<Item>.Action) {
        
        send(action)
    }
    
    struct State: Equatable {
        
        let selectState: SelectState
        let iconData: IconData
    }
}

@available(iOS 16.0.0, *)
extension IconedItemSelectViewModel {
    
    @available(macOS 13.0.0, *)
    convenience init(
        title: String,
        initialState: State,
        itemSelectModel: ItemSelectModel<Item>,
        iconDataLoader: AnyPublisher<IconData, Never>,
        scheduler: AnySchedulerOfDispatchQueue = .makeMain()
    ) {
        self.init(
            title: title,
            initialState: initialState,
            textField: itemSelectModel.textField,
            selectStateLoader: itemSelectModel.$state.eraseToAnyPublisher(),
            send: itemSelectModel.send(_:),
            iconDataLoader: iconDataLoader,
            scheduler: scheduler
        )
    }
}

// MARK: - adaptation for `Model` singleton
/*
 extension ItemSelectViewModel {
 
 convenience init(
 // Payments.ParameterSelectCountry
 value: String?,
 // model
 modelSingleton: any ModelSingleton<Item, ID, Data>,
 // would be injected  by default using convenience init for concrete types
 mapper: any ItemMapper<Item, ItemViewModel, ID, ImageData>,
 scheduler: AnySchedulerOfDispatchQueue = .makeMain()
 ) {
 let initialState: State = {
 if let item = modelSingleton.findItem(value: value, at: modelSingleton.searchItemKeyPath) {
 let itemViewModel = mapper.map(item)
 return .selected(itemViewModel, listState: .collapsed)
 } else {
 let items = modelSingleton.allItems()
 let itemViewModels = items.map(mapper.map(_:))
 return .expanded(itemViewModels)
 }
 }()
 
 self.init(
 )
 }
 }
 
 typealias ModelSingleton<Item, ID, ImageData> = Finder<Item> & ImageLoader<ID, ImageData>
 
 protocol Finder<Item> {
 
 associatedtype Item
 
 typealias SearchItemKeyPath = KeyPath<Item, String>
 
 var searchItemKeyPath: SearchItemKeyPath { get }
 
 func allItems() -> [Item]
 func findItem(value: String?, at keyPath: SearchItemKeyPath) -> Item?
 }
 
 protocol ImageLoader<ID, ImageData> {
 
 associatedtype ID
 associatedtype ImageData
 
 var imageLoader: AnyPublisher<ImageLoaderResult, Never> { get }
 
 func requestImages(ids: [ID])
 }
 */
