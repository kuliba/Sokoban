//
//  [PaymentProviderSegment]+ext.swift
//  ForaBank
//
//  Created by Igor Malyarov on 22.07.2024.
//

import ForaTools

extension Array where Element == PaymentProviderSegment {
    
    init<T: Comparable, Value: Comparable>(
        with providers: [SegmentedPaymentProvider],
        sortingSegmentsBy segmentKeyPath: KeyPath<PaymentProviderSegment, T> = \.title,
        sortingProvidersByKeyPath providerKeyPath: KeyPath<PaymentProviderSegment.Provider, Value> = \.title
    ) {
        let groupedProviders = Dictionary(grouping: providers, by: \.segment)
        
        self = groupedProviders.map { (segment, providers) in
            
            return .init(
                title: segment,
                providers: providers
                    .map { .init($0) }
                    .sorted(by: providerKeyPath)
            )
        }
        .sorted(by: segmentKeyPath)
    }
    
    init<T: Comparable, Value: Comparable>(
        with providers: [SegmentedPaymentProvider],
        sortingSegmentsBy segmentKeyPath: KeyPath<PaymentProviderSegment, T> = \.title,
        sortingProvidersByKeyPath providerKeyPath: KeyPath<PaymentProviderSegment.Provider, Value?>
    ) {
        let groupedProviders = Dictionary(grouping: providers, by: \.segment)
        
        self = groupedProviders.map { (segment, providers) in
            
            return .init(
                title: segment,
                providers: providers
                    .map { .init($0) }
                    .sorted(by: providerKeyPath)
            )
        }
        .sorted(by: segmentKeyPath)
    }
}

private extension PaymentProviderSegment.Provider {
    
    init(_ provider: SegmentedPaymentProvider) {
        
        self.init(
            id: provider.id,
            icon: provider.icon,
            inn: provider.inn,
            title: provider.title
        )
    }
}
