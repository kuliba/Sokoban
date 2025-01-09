//
//  ProviderServicePickerView.swift
//  Vortex
//
//  Created by Igor Malyarov on 29.12.2024.
//

import RxViewModel
import SwiftUI

struct ProviderServicePickerView<AnywayFlowView: View>: View {
    
    let binder: Domain.Binder
    @ViewBuilder
    let makeAnywayFlowView: (AnywayFlowModel) -> AnywayFlowView
    let makeIconView: MakeIconView
    
    var body: some View {
        
        RxWrapperView(model: binder.flow) { state, event in
            
            contentView(binder.content)
                .navigationDestination(
                    destination: state.destination,
                    dismiss: { event(.dismiss) },
                    content: destinationView
                )
                .alert(
                    item: state.alert,
                    content: alert(failure:)
                )
        }
    }
}

extension ProviderServicePickerView {
    
    typealias Domain = ProviderServicePickerDomain
}

private extension ProviderServicePickerView {
    
    func contentView(
        _ content: Domain.Content
    ) -> some View {
        
        ScrollView(showsIndicators: false) {
            
            VStack(spacing: 16) {
                
                ForEach(content.items, content: itemView)
            }
            .padding()
        }
    }
    
    func itemView(
        item: ProviderServicePickerDomain.Content.UIItem
    ) -> some View {
        
        Button {
            
            binder.flow.event(.select(
                .service(.init(
                    item: item.item,
                    operator: binder.content.provider
                ))
            ))
            
        } label: {
            
            NamedServiceLabel(
                name: item.label.title,
                iconView: iconView(icon: item.label.icon)
            )
        }
    }
    
    func iconView(
        icon: String?
    ) -> some View {
        
        makeIconView(icon.map { .md5Hash(.init($0)) })
    }
    
    func destinationView(
        destination: Domain.Navigation.Destination
    ) -> some View {
        
        switch destination {
        case let .payment(anywayFlowModel):
            makeAnywayFlowView(anywayFlowModel)
        }
    }
    
    private func alert(
        failure: ServiceFailureAlert.ServiceFailure
    ) -> Alert {
        
        return failure.alert(
            connectivityErrorTitle: "Ошибка",
            connectivityErrorMessage: "Во время проведения платежа произошла ошибка.\nПопробуйте повторить операцию позже.",
            serverErrorTitle: "Ошибка",
            event: { binder.flow.event(.select(.outside($0))) },
            map: {
                switch $0 {
                case .dismissAlert: return .payments
                }
            }
        )
    }
}

extension ProviderServicePickerDomain.Content.UIItem: Identifiable {
    
    var id: String { item.service.puref }
}

private extension ProviderServicePickerDomain.FlowDomain.State {
    
    var alert: ServiceFailureAlert.ServiceFailure? {
        
        switch navigation {
        case let .failure(failure):
            return failure
            
        default:
            return nil
        }
    }
    
    var destination: ProviderServicePickerDomain.Navigation.Destination? {
        
        switch navigation {
        case let .payment(node):
            return .payment(node.model)
            
        default:
            return nil
        }
    }
}

private extension ProviderServicePickerDomain.Navigation {
    
    enum Destination {
        
        case payment(AnywayFlowModel)
    }
}

extension ProviderServicePickerDomain.Navigation.Destination: Identifiable {
    
    var id: ID {
        
        switch self {
        case let .payment(model):
            return .payment(.init(model))
        }
    }
    
    enum ID: Hashable {
        
        case payment(ObjectIdentifier)
    }
}

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
