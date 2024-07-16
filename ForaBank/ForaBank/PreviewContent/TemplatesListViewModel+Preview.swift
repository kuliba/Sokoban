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
            .init(id: 0,
                  sortOrder: 0,
                  kind: .placeholder),
            
            .init(id: 1,
                  sortOrder: 1,
                  state: .normal,
                  avatar: .image(Image("Bank Logo Sample")),
                  title: "Маме на Сбер",
                  subTitle: "Перевод по СБП",
                  amount: "450 ₽"),
            
            .init(id: 2,
                  sortOrder: 2,
                  state: .select(.init(isSelected: true, action: { _ in })),
                  avatar: .image(Image("Bank Logo Sample")),
                  title: "Паме на Сбер",
                  subTitle: "Перевод по СБП",
                  amount: "324 000 ₽"),
            
            .init(id: 3,
                  sortOrder: 3,
                  state: .delete(.init(icon: Image("trash_empty"),
                                       subTitle: "Удалить",
                                       action: { _ in })),
                  avatar: .image(Image("Bank Logo Sample")),
                  title: "Жене на Сбер",
                  subTitle: "Перевод по СБП",
                  amount: " 1,31 млн. ₽"),
            
            .init(id: 4,
                  sortOrder: 4,
                  state: .deleting(.init(progress: 3,
                                         countTitle: "3",
                                         cancelButton: .init(title: "Отменить",
                                                             action: { _ in }),
                                         title: "Жене на Сбер",
                                         style: .list,
                                         id: 3)),
                  avatar: .image(Image("Bank Logo Sample")),
                  title: "Жене на Сбер",
                  subTitle: "Удаление...",
                  amount: " 1,31 млн. ₽"),
            
                .init(id: 5,
                      sortOrder: 5,
                      state: .normal,
                      avatar: .text("K"),
                      title: "Маме на Сбер",
                      subTitle: "Перевод по СБП",
                      topImage: Image("Bank Logo Sample"),
                      amount: "450 ₽"),
            
                .init(id: 6, sortOrder: 6,
                      state: .normal,
                      avatar: .image(.ic40Star),
                      title: "Добавить шаблон",
                      subTitle: "Из любой успешной операции в разделе «История»",
                      kind: .add )
        ]
    }()
    
    static let sampleItems2: [TemplatesListViewModel.ItemViewModel] = {
        
        [
            .init(id: 0, sortOrder: 0,
                  state: .normal,
                  avatar: .image(Image("Bank Logo Sample")),
                  title: "Между своими счетами",
                  subTitle: "Перевод по СБП",
                  amount: "450 ₽"),
            
            .init(id: 1, sortOrder: 1,
                  state: .normal,
                  avatar: .image(Image("Bank Logo Sample")),
                  title: "Паме на Сбер",
                  subTitle: "Перевод по СБП",
                  amount: "324 000 ₽"),
            
            .init(id: 2, sortOrder: 2,
                  state: .normal,
                  avatar: .image(Image("Ban§k Logo Sample")),
                  title: "Жене на Сбер",
                  subTitle: "Перевод по СБП",
                  topImage: Image("beline"), amount: " 1,31 млн. ₽"),
            
                .init(id: 4, sortOrder: 4,
                      state: .normal,
                      avatar: .image(.ic40Star),
                      title: "Добавить шаблон",
                      subTitle: "Из операции в разделе История",
                      kind: .add )
        ]
    }()
    
    static let sampleItems3: [TemplatesListViewModel.ItemViewModel] = {
        
        [
            .init(id: 0, sortOrder: 0,
                  state: .normal,
                  avatar: .image(Image("Bank Logo Sample")),
                  title: "Маме на Сбер",
                  subTitle: "Перевод по СБП",
                  amount: "450 ₽"),
            
            .init(id: 1, sortOrder: 1,
                  state: .select(.init(isSelected: false, action: { _ in })),
                  avatar: .image(Image("Bank Logo Sample")),
                  title: "Маме на Сбер",
                  subTitle: "Перевод по СБП",
                  amount: "450 ₽"),
            
            .init(id: 2, sortOrder: 2,
                  state: .select(.init(isSelected: true, action: { _ in })),
                  avatar: .image(Image("Bank Logo Sample")),
                  title: "Паме на Сбер",
                  subTitle: "Перевод по СБП",
                  amount: "324 000 ₽"),
            
            .init(id: 3, sortOrder: 3,
                  state: .deleting(TemplatesListViewModel.sampleDeletingProgress),
                  avatar: .image(Image("Bank Logo Sample")),
                  title: "Жене на Сбер",
                  subTitle: "Удаление...",
                  topImage: Image("beline"), amount: " 1,31 млн. ₽"),
            
            .init(id: 4, sortOrder: 4,
                  state: .delete(.init(icon: .ic24Trash, subTitle: "Удалить", action: { _ in } )),
                  avatar: .image(Image("Bank Logo Sample")),
                  title: "Маме на Сбер",
                  subTitle: "Перевод по СБП",
                  amount: "450 ₽"),
        ]
    }()
    
    static let sampleDeletePanel: TemplatesListViewModel.DeletePannelViewModel = {
        
        .init(description: "Выбрано 2",
              selectAllButton: .init(icon: .ic24CheckCircle,
                                     title: "Выбрать все",
                                     isDisable: true,
                                     action: {}),
              deleteButton: .init(icon: .ic24Trash2,
                                  title: "Удалить",
                                  isDisable: false,
                                  action: {}))
    }()
    
    static let sampleDeletingProgress: TemplatesListViewModel.ItemViewModel.DeletingProgressViewModel = {
        
        .init(progress: 3,
              countTitle: "3",
              cancelButton: .init(title: "Отменить",
                                  action: { _ in }),
              title: "Жене на Сбер", style: .list, id: 3)
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
        
        .init(state: .select,
              style: .list,
              navBarState: TemplatesListViewModel.sampleNavBarRegular,
              categorySelector: TemplatesListViewModel.sampleSelector,
              items: TemplatesListViewModel.sampleItems,
              deletePannel: TemplatesListViewModel.sampleDeletePanel,
              updateFastAll: {},
              model: .emptyMock,
              flowManager: .preview
        )
    }()
    
    static let sampleTiles: TemplatesListViewModel = {
        
        .init(state: .normal,
              style: .tiles,
              navBarState: TemplatesListViewModel.sampleNavBarRegular,
              categorySelector: TemplatesListViewModel.sampleSelector,
              items: TemplatesListViewModel.sampleItems2,
              deletePannel: nil,
              updateFastAll: {},
              model: .emptyMock,
              flowManager: .preview
        )
    }()
    
    static let sampleDeleting: TemplatesListViewModel = {
        
        .init(state: .select,
              style: .tiles,
              navBarState: TemplatesListViewModel.sampleNavBarRegular,
              categorySelector: TemplatesListViewModel.sampleSelector,
              items: TemplatesListViewModel.sampleItems3,
              deletePannel: TemplatesListViewModel.sampleDeletePanel,
              updateFastAll: {},
              model: .emptyMock,
              flowManager: .preview
        )
    }()
}

extension TemplatesListViewModel.EmptyTemplateListViewModel {
    
    static let sample: TemplatesListViewModel.EmptyTemplateListViewModel =
        
        .init(icon: .ic40Star, //Image("Templates Onboarding Icon"),
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
