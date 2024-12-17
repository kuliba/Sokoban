//
//  [Segment]+ext.swift
//  ForaBank
//
//  Created by Igor Malyarov on 22.07.2024.
//

import ForaTools

protocol Segmentable {
    
    var segmentTitle: String { get }
}

extension Array {
    
    init<Item: Segmentable, T: Comparable, Value: Comparable>(
        with providers: [Item],
        sortingSegmentsBy segmentKeyPath: KeyPath<Segment<Item>, T>,
        sortingItemsBy providerKeyPath: KeyPath<Item, Value>
    ) where Element == Segment<Item> {
        
        let groupedItems = Dictionary(grouping: providers, by: \.segmentTitle)
        
        self = groupedItems.map { (segment, providers) in
            
            return .init(
                title: segment,
                content: providers
                    .sorted(by: providerKeyPath)
            )
        }
        .sorted(by: segmentKeyPath)
    }
    
    init<Item: Segmentable, T: Comparable, Value: Comparable>(
        with providers: [Item],
        sortingSegmentsBy segmentKeyPath: KeyPath<Segment<Item>, T>,
        sortingItemsBy itemKeyPath: KeyPath<Item, Value?>
    ) where Element == Segment<Item> {
        
        let groupedItems = Dictionary(grouping: providers, by: \.segmentTitle)
        
        self = groupedItems.map { (segment, providers) in
            
            return .init(
                title: segment,
                content: providers
                    .sorted(by: itemKeyPath)
            )
        }
        .sorted(by: segmentKeyPath)
    }
}

extension SegmentedPaymentProvider: Segmentable {
    
    var segmentTitle: String { segment }
}

extension Array where Element == Segment<SegmentedOperatorProvider> {
    
    init<T: Comparable, Value: Comparable>(
        with providers: [SegmentedOperatorProvider],
        segmentKeyPath: KeyPath<Segment<SegmentedOperatorProvider>, T> = \.title,
        itemKeyPath: KeyPath<SegmentedOperatorProvider, Value> = \.title
    ) {
        self.init(with: providers, sortingSegmentsBy: segmentKeyPath, sortingItemsBy: itemKeyPath)
    }
    
    init<T: Comparable, Value: Comparable>(
        with providers: [SegmentedOperatorProvider],
        segmentKeyPath: KeyPath<Segment<SegmentedOperatorProvider>, T> = \.title,
        itemKeyPath: KeyPath<SegmentedOperatorProvider, Value?>
    ) {
        self.init(with: providers, sortingSegmentsBy: segmentKeyPath, sortingItemsBy: itemKeyPath)
    }
}

extension Array where Element == Segment<SegmentedPaymentProvider> {
    
    init<T: Comparable, Value: Comparable>(
        with providers: [SegmentedPaymentProvider],
        segmentKeyPath: KeyPath<Segment<SegmentedPaymentProvider>, T> = \.title,
        itemKeyPath: KeyPath<SegmentedPaymentProvider, Value> = \.title
    ) {
        self.init(with: providers, sortingSegmentsBy: segmentKeyPath, sortingItemsBy: itemKeyPath)
    }
    
    init<T: Comparable, Value: Comparable>(
        with providers: [SegmentedPaymentProvider],
        segmentKeyPath: KeyPath<Segment<SegmentedPaymentProvider>, T> = \.title,
        itemKeyPath: KeyPath<SegmentedPaymentProvider, Value?>
    ) {
        self.init(with: providers, sortingSegmentsBy: segmentKeyPath, sortingItemsBy: itemKeyPath)
    }
}
