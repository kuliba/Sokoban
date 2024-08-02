//
//  [PaymentProviderSegment]+ext.swift
//  ForaBank
//
//  Created by Igor Malyarov on 22.07.2024.
//

import ForaTools

extension Array where Element == PaymentProviderSegment<SegmentedPaymentProvider> {
    
    init<T: Comparable, Value: Comparable>(
        with providers: [SegmentedPaymentProvider],
        sortingSegmentsBy segmentKeyPath: KeyPath<PaymentProviderSegment<SegmentedPaymentProvider>, T> = \.title,
        sortingProvidersByKeyPath providerKeyPath: KeyPath<SegmentedPaymentProvider, Value> = \.title
    ) {
        let groupedProviders = Dictionary(grouping: providers, by: \.segment)
        
        self = groupedProviders.map { (segment, providers) in
            
            return .init(
                title: segment,
                providers: providers
                    .sorted(by: providerKeyPath)
            )
        }
        .sorted(by: segmentKeyPath)
    }
    
    init<T: Comparable, Value: Comparable>(
        with providers: [SegmentedPaymentProvider],
        sortingSegmentsBy segmentKeyPath: KeyPath<PaymentProviderSegment<SegmentedPaymentProvider>, T> = \.title,
        sortingProvidersByKeyPath providerKeyPath: KeyPath<SegmentedPaymentProvider, Value?>
    ) {
        let groupedProviders = Dictionary(grouping: providers, by: \.segment)
        
        self = groupedProviders.map { (segment, providers) in
            
            return .init(
                title: segment,
                providers: providers
                    .sorted(by: providerKeyPath)
            )
        }
        .sorted(by: segmentKeyPath)
    }
}
