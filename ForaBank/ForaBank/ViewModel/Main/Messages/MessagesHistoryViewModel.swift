//
//  MessagesHistoryViewModel.swift
//  ForaBank
//
//  Created by Константин Савялов on 21.04.2022.
//

import SwiftUI
import Combine

class MessagesHistoryViewModel: ObservableObject {
    
    let action: PassthroughSubject<Action, Never> = .init()
    //TODO: refactor this
    @Published var sections: [MessagesHistorySectionView]
    
    private var state: State
    private var bindings = Set<AnyCancellable>()
    private let model: Model
    
    init(sections: [MessagesHistorySectionView], model: Model, state: State) {
        
        self.model = model
        self.sections = sections
        self.state = state
    }
    
    init( model: Model) {
        
        self.model = model
        self.sections = []
        self.state = .stating
        
        bind()
        model.action.send(ModelAction.Notification.Fetch.New.Request())
    }
    
    func bind() {
        
        model.notifications
            .receive(on: DispatchQueue.main)
            .sink { [unowned self] notifications in
                
                sections = reduce(notifications: notifications).map{ MessagesHistorySectionView(viewModel: $0) }
                
            }.store(in: &bindings)
        
        model.action
            .receive(on: DispatchQueue.main)
            .sink { [unowned self] action in
                
                switch action {
                case _ as ModelAction.Notification.Fetch.New.Response:
                    state = .normal
                    
                case _ as ModelAction.Notification.Fetch.Next.Response:
                    state = .normal
                default:
                    break
                }
                
            }.store(in: &bindings)
        
        action
            .receive(on: DispatchQueue.main)
            .sink { [unowned self] action in
                
                switch action {
                case _ as MessagesHistoryViewModelAction.ScrolledToEnd:
                    
                    guard state == .normal else { return }
                    state = .updating
                    model.action.send(ModelAction.Notification.Fetch.Next.Request())
                    
                default:
                    break
                }
                
            }.store(in: &bindings)
    }
    
    func reduce(notifications: [NotificationData]) -> [MessagesHistorySectionView.ViewModel] {
        
        let groupsIndexes = Array(Set(notifications.map({ $0.date.groupDayIndex }))).sorted(by: >)
        
        let formatter = DateFormatter.historyShortDateFormatter
        var sections = [MessagesHistorySectionView.ViewModel]()
        
        for index in groupsIndexes {
            
            let items = notifications.filter({ $0.date.groupDayIndex == index }).sorted(by: { $0.date > $1.date })
            
            guard items.isEmpty == false else {
                
                continue
            }
            
            let date = items[0].date
            let dateSring = formatter.string(from: date)
            
            let section = MessagesHistorySectionView.ViewModel(section: dateSring, items: items)
            sections.append(section)
        }
        
        return sections
    }
}

extension MessagesHistoryViewModel {
    
    enum State {
        case stating
        case normal
        case updating
    }
}

enum MessagesHistoryViewModelAction {
    struct ScrolledToEnd: Action {}
}
