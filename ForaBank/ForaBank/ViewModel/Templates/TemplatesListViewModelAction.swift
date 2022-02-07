//
//  TemplatesListViewModelAction.swift
//  ForaBank
//
//  Created by Mikhail on 19.01.2022.
//

import Foundation

enum TemplatesListViewModelAction {

    // Toggle view style (list, tiles)
    struct ToggleStyle: Action {}
    
    // Item tapped
    struct ItemTapped: Action {
        
        let itemId: TemplatesListViewModel.ItemViewModel.ID
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
            
            // Delete selected items
            struct Accept: Action {}
            
            // Exit selection mode
            struct Exit: Action {}
        }
        
        // Delete single item
        struct Item: Action {
            
            let itemId: TemplatesListViewModel.ItemViewModel.ID
        }
        
        // Cancel button tapped for item in deletion state
        struct CancelItemDeletion: Action {
            
            let itemId: TemplatesListViewModel.ItemViewModel.ID
        }
    }
    
    // Add new template action
    struct AddTemplate: Action {}
    
    // Action to present payment screen
    enum Present {
        
        struct PaymentSFP: Action {
            let viewModel: PaymentByPhoneViewModel
        }
        
        struct PaymentInsideBankByPhone: Action {
            let viewModel: PaymentByPhoneViewModel
        }
        
        struct PaymentInsideBankByCard: Action {
            //TODO: Сделать модель для перевода по карте в рефакторинге экрана по карте
            let viewModel: PaymentTemplateData
        }
        
        struct PaymentToMyCard: Action {
            //TODO: Сделать модель для перевода по карте в рефакторинге экрана по карте
            let viewModel: PaymentTemplateData
        }
        
    }
}
