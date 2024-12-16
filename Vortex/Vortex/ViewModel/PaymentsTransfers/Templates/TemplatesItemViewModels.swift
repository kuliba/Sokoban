//
//  TemplatesItemViewModels.swift
//  Vortex
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
        @Published var avatar: Avatar
        @Published var title: String
        @Published var subTitle: String
        let topImage: Image?
        let amount: String
        
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
             avatar: Avatar = .placeholder,
             title: String = "",
             subTitle: String = "",
             topImage: Image? = nil,
             amount: String = "",
             tapAction: @escaping (ItemViewModel.ID) -> Void = { _ in },
             deleteAction: @escaping (ItemViewModel.ID) -> Void = { _ in },
             renameAction: @escaping (ItemViewModel.ID) -> Void = { _ in },
             kind: Kind = .regular) {
            
            self.id = id
            self.sortOrder = sortOrder
            self.state = state
            self.avatar = avatar
            self.title = title
            self.subTitle = subTitle
            self.topImage = topImage
            self.amount = amount
            self.tapAction = tapAction
            self.deleteAction = deleteAction
            self.renameAction = renameAction
            self.kind = kind
        }
        
        enum State {
            
            case normal
            case processing
            case select(ToggleRoundButtonViewModel)
            case delete(ItemActionViewModel)
            case deleting(DeletingProgressViewModel)
            
            var roundButtonViewModel: ToggleRoundButtonViewModel? {
                
                guard case .select(let viewModel) = self
                else { return nil }
                
                return viewModel
            }
            
            var isProcessing: Bool {
                
                if case .processing = self { return true }
                else { return false }
            }
            
            var isDeleting: Bool {
                
                if case .deleting = self { return true }
                else { return false }
            }
            
            var isDeleteProcessing: Bool {
                
                if case .deleting(let viewModel) = self, viewModel.progress > 0 {
                    
                    return true }
                else { return false }
            }
            
        }
        
        enum Avatar {
            case image(Image)
            case text(String)
            case placeholder
            
            var isPlaceholder: Bool {
                if case .placeholder = self {
                    return true
                } else {
                    return false
                }
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
            @Published var isDisableCancelButton: Bool
            
            let cancelButton: CancelButtonViewModel
            let title: String
            let subTitle: String
            let style: TemplatesListViewModel.Style
            let id: Int
            
            init(progress: Int,
                 countTitle: String,
                 cancelButton: CancelButtonViewModel,
                 isDisableCancelButton: Bool = false,
                 title: String,
                 subTitle: String = "Удаление...",
                 style: TemplatesListViewModel.Style,
                 id: Int) {
                
                self.progress = progress
                self.countTitle = countTitle
                self.cancelButton = cancelButton
                self.isDisableCancelButton = isDisableCancelButton
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
        
        var avatar: ItemViewModel.Avatar = .placeholder
        var topImage: Image? = nil
        
        var mainImage: Image? = nil
        if let imgData = model.images.value["Template\(data.id)"],
           let img = imgData.image {
            
            mainImage = img
        }
        
        if let phoneNumber = getPhoneNumber(for: data),
           let contact = model.contact(for: phoneNumber),
           let img = contact.avatar?.image {
           
                avatar = .image(img)
                topImage = mainImage
            
        } else {
            
            if let img = mainImage {
                
                avatar = .image(img)
            }
        }
        
        return .init(id: data.paymentTemplateId,
                     sortOrder: data.sort,
                     avatar: avatar,
                     title: data.name,
                     subTitle: data.groupName,
                     topImage: topImage,
                     amount: amount,
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
                             avatar: .image(.ic40Star),
                             title: "Добавить шаблон",
                             subTitle: "Из любой успешной операции в разделе «История»",
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
    
    func getPhoneNumber(for data: PaymentTemplateData) -> String? {
        
        let phone: String? = {
            switch data.type {
            case .mobile:
                
                guard let parameterList = data.parameterList.first as? TransferAnywayData,
                      let phoneField = parameterList.additional.first(where: { $0.fieldname == "a3_NUMBER_1_2" })
                else { return nil }
                
                return phoneField.fieldvalue
                
            case .sfp:
                
                guard let parameterList = data.parameterList.first as? TransferAnywayData,
                      let phoneField = parameterList.additional.first(where: { $0.fieldname == "RecipientID" })
                else { return nil }
                
                return phoneField.fieldvalue
                
            case .byPhone:
                
                guard let transfer = data.parameterList.first as? TransferGeneralData,
                      let phoneNumber = transfer.payeeInternal?.phoneNumber
                else { return nil }
                
                return phoneNumber
                
            case .direct, .newDirect:
                
                guard let parameterList = data.parameterList.first as? TransferAnywayData,
                      let phoneField = parameterList.additional.first(where: { $0.fieldname == "RECP" })
                else { return nil }
                
                return phoneField.fieldvalue
                
            default: return nil
            }
        }()
        
        if let phone {
            return PhoneNumberKitFormater().format( phone.count == 10 ? "7\(phone)" : phone)
        } else {
            return nil
        }
    }
    
    func amount(for template: PaymentTemplateData,
                amountFormatted: (Double, String?, Model.AmountFormatStyle) -> String?) -> String? {
        
        if template.type == .contactAdressless,
           let parameterList = template.parameterList.first as? TransferAnywayData,
           let currencyAmount = parameterList.additional.first(where: { $0.fieldname == "CURR" }),
           let amount = template.amount {
            
            return amountFormatted(amount, currencyAmount.fieldvalue, .normal)
            
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
                    
                } else {
                    
                    return nil
                }
                
            } else {
                
                guard let transfer = template.parameterList.first,
                      let currencyAmount = transfer.currencyAmount,
                      let amount = template.amount
                else { return nil }
                
                return amountFormatted(amount, currencyAmount, .fraction)
            }
        }
    }
  
}
