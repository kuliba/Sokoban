//
//  TemplatesItemViewModels.swift
//  ForaBank
//
//  Created by Dmitry Martynov on 05.05.2023.
//

import SwiftUI
import Combine

extension TemplatesListViewModel {
    
    class ItemViewModel: Identifiable, ObservableObject {
        
        let id: Int
        var sortOrder: Int
        @Published var state: State
        let image: Image?
        @Published var title: String
        @Published var subTitle: String
        let logoImage: Image?
        let ammount: String
        
        var timer: DeletingTimer?
        
        let tapAction: (ItemViewModel.ID) -> Void
        let deleteAction: (ItemViewModel.ID) -> Void
        let renameAction: (ItemViewModel.ID) -> Void
        
        let kind: Kind //TODO: refactor into inheritance
        
        lazy var swipeLeft: () -> Void = { //TODO: -
            
            switch self.state {
            case .normal:
                
                withAnimation(.easeInOut(duration: 0.2)) {
                    self.state = .delete(.init(icon: .ic32Trash, subTitle: "Удалить", action: self.deleteAction))
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
        
        init(id: Int = 0,
             sortOrder: Int = 0,
             state: TemplatesListViewModel.ItemViewModel.State = .normal,
             image: Image? = nil,
             title: String = "",
             subTitle: String = "",
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
            
        }
        
        struct ToggleRoundButtonViewModel {
            
            let isSelected: Bool
            let action: (ItemViewModel.ID) -> Void
        }
        
        struct ItemActionViewModel: Identifiable {
            
            var id: UUID = UUID()
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
    
    func getItemViewModel(with data: PaymentTemplateData, model: Model) -> ItemViewModel? {
        
        guard let amount = amount(for: data,
                                  amountFormatted: model.amountFormatted(amount:currencyCode:style:))
        else { return nil }
        
        return .init(id: data.paymentTemplateId,
                     sortOrder: data.sort,
                     image: data.svgImage.image,
                     title: data.name,
                     subTitle: data.groupName,
                     ammount: amount,
                     tapAction: { [weak self] itemId in
                        self?.action.send(TemplatesListViewModelAction.Item.Tapped(itemId: itemId)) },
                     deleteAction: { [weak self] itemId in
                        self?.action.send(TemplatesListViewModelAction.Item.Delete(itemId: itemId)) },
                     renameAction: { [weak self] itemId in
                        self?.action.send(TemplatesListViewModelAction.Item.Rename(itemId: itemId)) })
    }
    
    func getItemAddNewTemplateModel() -> ItemViewModel {
        
        return ItemViewModel(id: Int.max,
                             sortOrder: Int.max,
                             image: .ic40Star,
                             title: "Добавить шаблон",
                             subTitle: "Из любой успешной операции\nв разделе «История»",
                             tapAction: { [weak self] _ in  self?.action.send(TemplatesListViewModelAction.AddTemplateTapped()) },
                             kind: .add)
    }
    
    func getItemsMenuViewModel() -> [ItemViewModel.ItemActionViewModel]? {
            
        [
            .init(icon: .ic32Trash, subTitle: "Удалить", action: { [weak self] id in
                self?.action.send(TemplatesListViewModelAction.Item.Delete(itemId: id)) }),
            
                .init(icon: .ic32Edit2, subTitle: "Переименовать", action: { [weak self] id in
                self?.action.send(TemplatesListViewModelAction.Item.Rename(itemId: id)) })
            ]

    }
    
    class DeletingTimer {
        
        let timerPublisher = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
        let startDate = Date()
        let maxCount = 5

        deinit {

            timerPublisher.upstream.connect().cancel()
        }
    }
    
    
    func amount(for template: PaymentTemplateData,
                amountFormatted: (Double, String?, Model.AmountFormatStyle) -> String?) -> String? {
        
        if template.type == .contactAdressless ,
           let parameterList = template.parameterList.first as? TransferAnywayData,
           let currencyAmount = parameterList.additional.first(where: { $0.fieldname == "CURR" }),
           let amount = template.amount {
            
            return amountFormatted(amount, currencyAmount.fieldvalue, .normal)
            //amount.currencyFormatter(symbol: currencyAmount.fieldvalue)
            
        } else {
            
            if template.parameterList.count > 1 {
                var amount: Double?
                var currencyAmount: String?
                
                template.parameterList.forEach { parameter in
                    if let paramAmount = parameter.amount {
                        amount = NSDecimalNumber(decimal: paramAmount).doubleValue
                    }
                    currencyAmount = parameter.currencyAmount
                }
                
                if let amount = amount,
                   let currencyAmount = currencyAmount {
                    
                    return amountFormatted(amount, currencyAmount, .normal)
                    //return amount.currencyFormatter(symbol: currencyAmount)
                    
                } else {
                    
                    return nil
                }
                
            } else {
                
                guard let transfer = template.parameterList.first,
                      let amount = template.amount
                else { return nil }
                return amount.currencyFormatter(symbol: transfer.currencyAmount)
                //return amountFormatted(amount, transfer.currencyAmount, .normal)
            }
        }
    }
  
}
