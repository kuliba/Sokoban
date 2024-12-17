//
//  TemplatesListViewModelAction.swift
//  ForaBank
//
//  Created by Mikhail on 19.01.2022.
//

import Foundation

enum TemplatesListViewModelAction {

    struct ToggleStyle: Action {}
    
    enum Item {
        
        struct Tapped: Action {
            let itemId: TemplatesListViewModel.ItemViewModel.ID
        }
        
        struct Rename: Action {
            let itemId: TemplatesListViewModel.ItemViewModel.ID
        }
        
        struct Delete: Action {
            let itemId: TemplatesListViewModel.ItemViewModel.ID
        }
        
    }
    
    struct Search: Action {
        
        let text: String
    }
    
    enum RegularNavBar {
        
        struct SearchNavBarPresent: Action {}
        
        struct RegularNavBarPresent: Action {}
    }
    
    enum ReorderItems {
        
        struct EditModeEnabled: Action {}
        
        struct CloseEditMode: Action {}
        
        struct SaveReorder: Action {}
        
        struct ItemMoved: Action {
            let move: (from: IndexSet.Element, to: Int)
        }
    }
    
    enum SearchNavBarAction {
        
        struct Close: Action {}
    }
    
    enum RenameSheetAction {
        
        struct SaveNewName: Action {
            let newName: String
            let itemId: TemplatesListViewModel.ItemViewModel.ID
        }
    }
    
    enum ProductListAction {
        
        enum Item {
            
            struct Tapped: Action {
                let productId: String
            }
        }
    }
    
    enum Delete {
    
        // Delete selection mode actions
        enum Selection {
        
            // Enter selection mode
            struct Enter: Action {}
            
            // Toggle selection state for item
            struct ToggleItem: Action {
                
                let itemId: TemplatesListViewModel.ItemViewModel.ID
            }
            
            // SelectAll/DeselectAll items
            struct Toggle: Action {}
            
            // Delete selected items
            struct Accept: Action {}
            
            // Exit selection mode
            struct Exit: Action {}
            
            // cancel deleting selection
            struct CancelDeleting: Action {}
        }
        
        // Cancel button tapped for item in deletion state
        struct CancelItemDeletion: Action {
            
            let itemId: TemplatesListViewModel.ItemViewModel.ID
        }
    }
    
    // Add new template action
    struct OpenProductProfile: Action {
        let productId: ProductData.ID
    }
    
    // Should be observed from outside, is not handled in the TemplatesListViewModel
    struct OpenDefaultTemplate: Action, Equatable {
        
        let template: PaymentTemplateData
    }
    
    struct AddTemplateTapped: Action {}
    
    // Action to present payment screen
    enum Present {
        
        struct PaymentSFP: Action {
            let viewModel: PaymentByPhoneViewModel
        }
        
        struct PaymentInsideBankByPhone: Action {
            let viewModel: PaymentByPhoneViewModel
        }
        
        struct PaymentInsideBankByCard: Action {
            //TODO: Сделать модель для перевода по карте внутри банка в рефакторинге экрана по карте
            let viewModel: PaymentTemplateData
        }
        
        struct PaymentToMyCard: Action {
            //TODO: Сделать модель для перевода по карте на мои счета в рефакторинге экрана по карте
            let viewModel: PaymentTemplateData
        }
        
        struct PaymentContact: Action {
            //TODO: Сделать модель для перевода Контакт в рефакторинге экрана платежей
            let viewModel: PaymentTemplateData
        }
        
        struct PaymentMig: Action {
            //TODO: Сделать модель для перевода Миг в рефакторинге экрана экрана платежей
            let viewModel: PaymentTemplateData
        }
        
        struct PaymentRequisites: Action {
            //TODO: Сделать модель для перевода по реквизитам в рефакторинге экрана экрана платежей
            let viewModel: PaymentTemplateData
        }
        
        struct OrgPaymentRequisites: Action {
            //TODO: Сделать модель для перевода по реквизитам в рефакторинге экрана экрана платежей
            let viewModel: PaymentTemplateData
        }
        
        struct MobilePayment: Action {
            //TODO: Сделать модель для перевода по реквизитам в рефакторинге экрана экрана платежей
            let viewModel: PaymentTemplateData
        }
        
        struct InterneetPayment: Action {
            //TODO: Сделать модель для перевода по реквизитам в рефакторинге экрана экрана платежей
            let viewModel: PaymentTemplateData
        }
        
        struct GKHPayment: Action {
            //TODO: Сделать модель для перевода по реквизитам в рефакторинге экрана экрана платежей
            let viewModel: PaymentTemplateData
        }
        
        struct TransportPayment: Action {
            //TODO: Сделать модель для перевода по реквизитам в рефакторинге экрана экрана платежей
            let viewModel: PaymentTemplateData
        }
    }
    
    // Close view
    struct CloseAction: Action {}
}
