//
//  TemplatesListViewModel+Preview.swift
//  ForaBank
//
//  Created by Max Gribov on 25.01.2022.
//

import SwiftUI

extension TemplatesListViewModel {
    
    static let sampleSelector: OptionSelectorView.ViewModel = {
       
        .init(options: [
                .init(id: "all", name: "Все" ),
                .init(id: "add", name: "Пополнение"),
                .init(id: "addi", name: "Коммунальные"),
                .init(id: "addit", name: "Переводы") ],
              selected: "all",
              style: .template)
    }()
    
    static let sampleItems: [TemplatesListViewModel.ItemViewModel] = {
        
        [
            .init(id: 0, sortOrder: 0,
                  state: .normal,
                  image: Image("Bank Logo Sample"),
                  title: "Маме на Сбер",
                  subTitle: "Перевод по СБП",
                  logoImage: nil, ammount: "450 ₽",
                  tapAction: {_ in},
                  deleteAction: {_ in},
                  renameAction: {_ in} ),
            
            .init(id: 1, sortOrder: 1,
                  state: .select(.init(isSelected: true, action: { _ in })),
                  image: Image("Bank Logo Sample"),
                  title: "Паме на Сбер",
                  subTitle: "Перевод по СБП",
                  logoImage: nil, ammount: "324 000 ₽",
                  tapAction: {_ in},
                  deleteAction: {_ in},
                  renameAction: {_ in} ),
            
            .init(id: 2, sortOrder: 2,
                  state: .delete(.init(icon: Image("trash_empty"),
                                       subTitle: "Удалить",
                                       action: { _ in })),
                  image: Image("Bank Logo Sample"),
                  title: "Жене на Сбер",
                  subTitle: "Перевод по СБП",
                  logoImage: nil, ammount: " 1,31 млн. ₽",
                  tapAction: {_ in},
                  deleteAction: {_ in},
                  renameAction: {_ in} ),
            
            .init(id: 3, sortOrder: 3,
                  state: .deleting(.init(progress: 0.76,
                                         countTitle: "3",
                                         cancelButton: .init(title: "Отменить",
                                                             action: { _ in }))),
                  image: Image("Bank Logo Sample"),
                  title: "Жене на Сбер",
                  subTitle: "Удаление...",
                  logoImage: nil, ammount: " 1,31 млн. ₽",
                  tapAction: {_ in},
                  deleteAction: {_ in},
                  renameAction: {_ in} ),
            
                .init(id: 4, sortOrder: 4,
                      state: .normal,
                      image: Image("Templates Add New Icon"),
                      title: "Добавить шаблон",
                      subTitle: "Из операции в разделе История",
                      logoImage: nil, ammount: "",
                      tapAction: {_ in},
                      deleteAction: {_ in},
                      renameAction: {_ in},
                      kind: .add )
        ]
    }()
    
    static let sampleItems2: [TemplatesListViewModel.ItemViewModel] = {
        
        [
            .init(id: 0, sortOrder: 0,
                  state: .normal,
                  image: Image("Bank Logo Sample"),
                  title: "Между своими счетами",
                  subTitle: "Перевод по СБП",
                  logoImage: nil, ammount: "450 ₽",
                  tapAction: {_ in},
                  deleteAction: {_ in},
                  renameAction: {_ in} ),
            
            .init(id: 1, sortOrder: 1,
                  state: .normal,
                  image: Image("Bank Logo Sample"),
                  title: "Паме на Сбер",
                  subTitle: "Перевод по СБП",
                  logoImage: nil, ammount: "324 000 ₽",
                  tapAction: {_ in},
                  deleteAction: {_ in},
                  renameAction: {_ in} ),
            
            .init(id: 2, sortOrder: 2,
                  state: .normal,
                  image: Image("Ban§k Logo Sample"),
                  title: "Жене на Сбер",
                  subTitle: "Перевод по СБП",
                  logoImage: Image("beline"), ammount: " 1,31 млн. ₽",
                  tapAction: {_ in},
                  deleteAction: {_ in},
                  renameAction: {_ in} ),
            
                .init(id: 4, sortOrder: 4,
                      state: .normal,
                      image: Image("Templates Add New Icon"),
                      title: "Добавить шаблон",
                      subTitle: "Из операции в разделе История",
                      logoImage: nil, ammount: "",
                      tapAction: {_ in},
                      deleteAction: {_ in},
                      renameAction: {_ in},
                      kind: .add )
        ]
    }()
    
    static let sampleItems3: [TemplatesListViewModel.ItemViewModel] = {
        
        [
            .init(id: 0, sortOrder: 0,
                  state: .normal,
                  image: Image("Bank Logo Sample"),
                  title: "Маме на Сбер",
                  subTitle: "Перевод по СБП",
                  logoImage: nil, ammount: "450 ₽",
                  tapAction: {_ in},
                  deleteAction: {_ in},
                  renameAction: {_ in}),
            
            .init(id: 1, sortOrder: 1,
                  state: .select(.init(isSelected: false, action: { _ in })),
                  image: Image("Bank Logo Sample"),
                  title: "Маме на Сбер",
                  subTitle: "Перевод по СБП",
                  logoImage: nil, ammount: "450 ₽",
                  tapAction: {_ in},
                  deleteAction: {_ in},
                  renameAction: {_ in}),
            
            .init(id: 2, sortOrder: 2,
                  state: .select(.init(isSelected: true, action: { _ in })),
                  image: Image("Bank Logo Sample"),
                  title: "Паме на Сбер",
                  subTitle: "Перевод по СБП",
                  logoImage: nil, ammount: "324 000 ₽",
                  tapAction: {_ in},
                  deleteAction: {_ in},
                  renameAction: {_ in} ),
            
            .init(id: 3, sortOrder: 3,
                  state: .deleting(TemplatesListViewModel.sampleDeletingProgress),
                  image: Image("Bank Logo Sample"),
                  title: "Жене на Сбер",
                  subTitle: "Удаление...",
                  logoImage: Image("beline"), ammount: " 1,31 млн. ₽",
                  tapAction: {_ in},
                  deleteAction: {_ in},
                  renameAction: {_ in} ),
            
            .init(id: 4, sortOrder: 4,
                  state: .delete(.init(icon: .ic24Trash, subTitle: "Удалить", action: { _ in } )),
                      image: Image("Bank Logo Sample"),
                      title: "Маме на Сбер",
                      subTitle: "Перевод по СБП",
                      logoImage: nil, ammount: "450 ₽",
                      tapAction: {_ in},
                      deleteAction: {_ in},
                      renameAction: {_ in}),
        ]
    }()
    
    static let sampleDeletePanel: TemplatesListViewModel.DeletePannelViewModel = {
        
        .init(description: "Выбрано 1 объект",
              button: .init(icon: Image("trash"),
                            caption: "Удалить все",
                            isEnabled: true,
                            action: { }))
    }()
    
    static let sampleDeletingProgress: TemplatesListViewModel.ItemViewModel.DeletingProgressViewModel = {
        
        .init(progress: 0.76,
              countTitle: "3",
              cancelButton: .init(title: "Отменить",
                                  action: { _ in }))
    }()
    
    static let sampleNavBarSearch: TemplatesListViewModel.NavBarState = {
        
        .search(.init(trailIcon: .ic24Search, searchText: ""))
    }()
    
    static let sampleNavBarRegular: TemplatesListViewModel.NavBarState = {
        
        .regular(.init(backButton: .init(icon: .ic24ChevronLeft, action: {}),
                       menuList: TemplatesListViewModel.menuListSample,
                       searchButton: .init(icon: .ic24Search, action: {})))
    }()
    
    static let sampleComplete: TemplatesListViewModel = {
        
        .init(state: .normal,
              style: .list,
              navBarState: TemplatesListViewModel.sampleNavBarRegular,
              categorySelector: TemplatesListViewModel.sampleSelector,
              items: TemplatesListViewModel.sampleItems,
              deletePannel: nil,
              model: .emptyMock)
    }()
    
    static let sampleTiles: TemplatesListViewModel = {
        
        .init(state: .normal,
              style: .tiles,
              navBarState: TemplatesListViewModel.sampleNavBarRegular,
              categorySelector: TemplatesListViewModel.sampleSelector,
              items: TemplatesListViewModel.sampleItems2,
              deletePannel: nil,
              model: .emptyMock)
    }()
    
    static let sampleDeleting: TemplatesListViewModel = {
        
        .init(state: .select,
              style: .tiles,
              navBarState: TemplatesListViewModel.sampleNavBarRegular,
              categorySelector: TemplatesListViewModel.sampleSelector,
              items: TemplatesListViewModel.sampleItems3,
              deletePannel: TemplatesListViewModel.sampleDeletePanel,
              model: .emptyMock)
    }()
}

extension TemplatesListViewModel.OnboardingViewModel {
    
    static let sample: TemplatesListViewModel.OnboardingViewModel =
        
        .init(icon: Image("Templates Onboarding Icon"),
              title: "Нет шаблонов",
              message: "Вы можете создать шаблон из любой успешной операции в разделе История",
              button: .init(title: "Перейти в историю",
                            action: { }))
}

extension TemplatesListViewModel {
    static let menuListSample: [TemplatesListViewModel.MenuItemViewModel] = {
        
        .init(
            [
                .init(icon: Image("bar-in-order"), textImage: "bar-in-order",
                      title: "Последовательность",
                      action: {}),
                .init(icon: Image("grid"), textImage: "grid",
                      title: "Вид (Плитка)",
                      action: {}),
                .init(icon: .ic24Trash, textImage: "ic24Trash",
                      title: "Удалить",
                      action: {})
            ])
    }()
}
