//
//  ProviderServicePickerDomain.Content+ext.swift
//  Vortex
//
//  Created by Igor Malyarov on 29.12.2024.
//

#warning("move to UI")
extension ProviderServicePickerDomain.Content {
    
    var navBar: Navbar { return provider.navBar }
    
    var items: [UIItem] { services.elements.map(\.item) }
    
    struct Navbar: Equatable {
        
        let icon: String?
        let title: String
        let subtitle: String
    }
    
    struct UIItem: Equatable {
        
        let label: Label
        let item: ServicePickerItem
        
        struct Label: Equatable {
            
            let icon: String?
            let title: String
        }
    }
}

private extension UtilityPaymentOperator {
    
    var navBar: ProviderServicePickerDomain.Content.Navbar {
        
        return .init(icon: icon, title: title, subtitle: subtitle)
    }
}

private extension UtilityService {
    
    var item: ProviderServicePickerDomain.Content.UIItem {
        
        return .init(
            label: .init(icon: icon, title: name),
            item: .init(service: self, isOneOf: true)
        )
    }
}
