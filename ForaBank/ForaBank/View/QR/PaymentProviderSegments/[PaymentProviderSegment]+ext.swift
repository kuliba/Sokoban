//
//  [PaymentProviderSegment]+ext.swift
//  ForaBank
//
//  Created by Igor Malyarov on 22.07.2024.
//

import ForaTools

protocol Segmentable {
    
    var segmentTitle: String { get }
}

extension Array {
    
    init<Provider: Segmentable, T: Comparable, Value: Comparable>(
        with providers: [Provider],
        sortingSegmentsBy segmentKeyPath: KeyPath<PaymentProviderSegment<Provider>, T>,
        sortingProvidersByKeyPath providerKeyPath: KeyPath<Provider, Value>
    ) where Element == PaymentProviderSegment<Provider> {
        
        let groupedProviders = Dictionary(grouping: providers, by: \.segmentTitle)
        
        self = groupedProviders.map { (segment, providers) in
            
            return .init(
                title: segment,
                providers: providers
                    .sorted(by: providerKeyPath)
            )
        }
        .sorted(by: segmentKeyPath)
    }
    
    init<Provider: Segmentable, T: Comparable, Value: Comparable>(
        with providers: [Provider],
        sortingSegmentsBy segmentKeyPath: KeyPath<PaymentProviderSegment<Provider>, T>,
        sortingProvidersByKeyPath providerKeyPath: KeyPath<Provider, Value?>
    ) where Element == PaymentProviderSegment<Provider> {
        
        let groupedProviders = Dictionary(grouping: providers, by: \.segmentTitle)
        
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

extension SegmentedPaymentProvider: Segmentable {
    
    var segmentTitle: String { segment }
}

extension Array where Element == PaymentProviderSegment<SegmentedPaymentProvider> {
    
    init<T: Comparable, Value: Comparable>(
        with providers: [SegmentedPaymentProvider],
        segmentKeyPath: KeyPath<PaymentProviderSegment<SegmentedPaymentProvider>, T> = \.title,
        providerKeyPath: KeyPath<SegmentedPaymentProvider, Value> = \.title
    ) {
        self.init(with: providers, sortingSegmentsBy: segmentKeyPath, sortingProvidersByKeyPath: providerKeyPath)
    }
    
    init<T: Comparable, Value: Comparable>(
        with providers: [SegmentedPaymentProvider],
        segmentKeyPath: KeyPath<PaymentProviderSegment<SegmentedPaymentProvider>, T> = \.title,
        providerKeyPath: KeyPath<SegmentedPaymentProvider, Value?>
    ) {
        self.init(with: providers, sortingSegmentsBy: segmentKeyPath, sortingProvidersByKeyPath: providerKeyPath)
    }
}
