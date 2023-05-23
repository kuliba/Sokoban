//
//  TemplatesItemViewModels.swift
//  ForaBank
//
//  Created by Dmitry Martynov on 05.05.2023.
//

import SwiftUI
import Combine

extension TemplatesListViewModel {
    
    class ItemViewModel: Identifiable, Equatable, ObservableObject {
        
        let id: Int
        var sortOrder: Int
        @Published var state: State
        let image: Image
        @Published var title: String
        @Published var subTitle: String
        let logoImage: Image?
        let ammount: String
        
        var timer: MyTimer?
        
        let tapAction: (ItemViewModel.ID) -> Void
        let deleteAction: (ItemViewModel.ID) -> Void
        let renameAction: (ItemViewModel.ID) -> Void
        
        let kind: Kind
        
        lazy var swipeLeft: () -> Void = {
            
            switch self.state {
            case .normal:
                
                withAnimation(.easeInOut(duration: 0.2)) {
                    self.state = .delete(.init(icon: Image("trash_empty"), subTitle: "Удалить", action: self.deleteAction))
                }
                
            default:
                break
            }
        }
        
        lazy var swipeRight: () -> Void = {
            
            switch self.state {
            case .delete:
                withAnimation(.easeInOut(duration: 0.2)) {
                    self.state = .normal
                }
                
            default:
                break
            }
        }
        
        init(id: Int, sortOrder: Int, state: TemplatesListViewModel.ItemViewModel.State,
            image: Image, title: String, subTitle: String,
            logoImage: Image? = nil,
            ammount: String = "",
            tapAction: @escaping (ItemViewModel.ID) -> Void = { _ in },
            deleteAction: @escaping (ItemViewModel.ID) -> Void = { _ in },
            renameAction: @escaping (ItemViewModel.ID) -> Void = { _ in },
            kind: Kind = .regular) {
            
            self.id = id
            self.sortOrder = sortOrder
            self.state = state
            self.image = image
            self.title = title
            self.subTitle = subTitle
            self.logoImage = logoImage
            self.ammount = ammount
            self.tapAction = tapAction
            self.deleteAction = deleteAction
            self.renameAction = renameAction
            self.kind = kind
        }
        
        static func == (lhs: TemplatesListViewModel.ItemViewModel, rhs: TemplatesListViewModel.ItemViewModel) -> Bool {
            lhs.id == rhs.id
        }
        
        
        enum State {
            
            case normal
            case select(ToggleRoundButtonViewModel)
            case delete(ItemActionViewModel)
            case deleting(DeletingProgressViewModel)
            
            var roundButtonViewModel: ToggleRoundButtonViewModel? {
                
                guard case .select(let viewModel) = self
                else { return nil }
                
                return viewModel
            }
            
//            var deleteButtonViewModel: ItemActionViewModel? {
//
//                guard case .delete(let viewModel) = self
//                else { return nil }
//
//                return viewModel
//            }
            
//            var deletingProgressViewModel: DeletingProgressViewModel? {
//
//                guard case .deleting(let viewModel) = self
//                else { return nil }
//
//                return viewModel
//            }
        }
        
        struct ToggleRoundButtonViewModel {
            
            let isSelected: Bool
            let action: (ItemViewModel.ID) -> Void
        }
        
        struct ItemActionViewModel: Identifiable {
            
            let id = UUID()
            let icon: Image
            let subTitle: String
            let action: (ItemViewModel.ID) -> Void
        }
        
        class DeletingProgressViewModel: ObservableObject {
            
            @Published var progress: Int
            @Published var countTitle: String
            let cancelButton: CancelButtonViewModel
            let title: String
            let subTitle: String
            let style: TemplatesListViewModel.Style
            let id: Int
            
            init(progress: Int,
                 countTitle: String,
                 cancelButton: CancelButtonViewModel,
                 title: String,
                 subTitle: String = "Удаление...",
                 style: TemplatesListViewModel.Style,
                 id: Int) {
                
                self.progress = progress
                self.countTitle = countTitle
                self.cancelButton = cancelButton
                self.title = title
                self.subTitle = subTitle
                self.style = style
                self.id = id
            }
        }
        
        class ItemProgressViewModel: ObservableObject {
            
            @Published var progress: Int
            @Published var title: String
            @Published  var style: TemplatesListViewModel.Style
            let maxCount: Int
            
            init(progress: Int, title: String, style: TemplatesListViewModel.Style, maxCount: Int = 5) {
                self.progress = progress
                self.title = title
                self.style = style
                self.maxCount = maxCount
            }

            var height: CGFloat {
                
                switch style {
                case .list: return 40
                case .tiles: return 56
                }
            }
            
            var width: CGFloat {
                
                switch style {
                case .list: return 40
                case .tiles: return 56
                }
            }
            
        }
        
        struct CancelButtonViewModel {
            
            let title: String
            let action: (ItemViewModel.ID) -> Void
        }
        
        enum Kind {
            
            case regular
            case add
            case placeholder
            case deleting
        }
    }
}

//Reduce
extension TemplatesListViewModel {
    
    func itemViewModel(with data: PaymentTemplateData) -> ItemViewModel? {
        
        guard let amount = amount(for: data)
        else { return nil }
        
        return .init(id: data.paymentTemplateId,
                     sortOrder: data.sort,
                     state: .normal,
                     image: data.svgImage.image ?? Image(""),
                     title: data.name,
                     subTitle: data.groupName,
                     logoImage: nil,
                     ammount: amount,
                     tapAction: { [weak self] itemId in
                        self?.action.send(TemplatesListViewModelAction.Item.Tapped(itemId: itemId)) },
                     deleteAction: { [weak self] itemId in
                        self?.action.send(TemplatesListViewModelAction.Item.Delete(itemId: itemId)) },
                     renameAction: { [weak self] itemId in
                        self?.action.send(TemplatesListViewModelAction.Item.Rename(itemId: itemId)) })
    }
    
    func itemAddNewTemplateViewModel() -> ItemViewModel {
        
        return ItemViewModel(id: Int.max,
                             sortOrder: Int.max,
                             state: .normal,
                             image: Image("Templates Add New Icon"),
                             title: "Добавить шаблон",
                             subTitle: "Из любой успешной операции\nв разделе «История»",
                             logoImage: nil,
                             ammount: "",
                             tapAction: { [weak self] _ in  self?.action.send(TemplatesListViewModelAction.AddTemplate()) },
                             deleteAction: { _ in },
                             renameAction: { _ in },
                             kind: .add)
    }
    
    func itemPlaceholderTemplateViewModel() -> ItemViewModel {
        
        return ItemViewModel(id: 0,
                             sortOrder: 0,
                             state: .normal,
                             image: Image(""),
                             title: "Placeholder",
                             subTitle: "",
                             logoImage: nil,
                             ammount: "",
                             tapAction: { _ in },
                             deleteAction: { _ in },
                             renameAction: { _ in },
                             kind: .placeholder)
    }
    
    
    func getItemsMenuViewModel() -> [ItemViewModel.ItemActionViewModel]? {
            
        [
            .init(icon: Image("roundTrash"), subTitle: "Удалить", action: { [weak self] id in
                self?.action.send(TemplatesListViewModelAction.Item.Delete(itemId: id)) }),
            
            .init(icon: Image("roundEdit-2"), subTitle: "Переименовать", action: { [weak self] id in
                self?.action.send(TemplatesListViewModelAction.Item.Rename(itemId: id)) })
            ]

    }
    
    class MyTimer {
        
        let timerPublish = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
        let startDate =  Date()
        let maxCount = 5

        deinit {

            timerPublish.upstream.connect().cancel()
        }
    }
    
    func amount(for template: PaymentTemplateData) -> String? {
        
        if template.type == .contactAdressless ,
           let parameterList = template.parameterList.first as? TransferAnywayData,
           let currencyAmount = parameterList.additional.first(where: { $0.fieldname == "CURR" }),
           let amount = template.amount {
            
            return amount.currencyFormatter(symbol: currencyAmount.fieldvalue)
            
        } else {
            
            if template.parameterList.count > 1 {
                var amount: Double?
                var currencyAmount: String?
                
                template.parameterList.forEach { parameter in
                    if let paramAmount = parameter.amount {
                        //amount = Double(paramAmount)
                        amount = NSDecimalNumber(decimal: paramAmount).doubleValue
                    }
                    currencyAmount = parameter.currencyAmount
                }
                
                if let amount = amount,
                   let currencyAmount = currencyAmount {
                    
                    return amount.currencyFormatter(symbol: currencyAmount)
                    
                } else {
                    
                    return nil
                }
                
            } else {
                guard let transfer = template.parameterList.first,
                      let amount = template.amount else {
        
                    return nil
                }
                return amount.currencyFormatter(symbol: transfer.currencyAmount)
            }
            
        }
    }
}
