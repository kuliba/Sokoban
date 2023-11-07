//
//  UILanding.swift
//  
//
//  Created by Andryusina Nataly on 02.09.2023.
//

import Foundation

public struct UILanding: Equatable {
    
    public let header: [Component]
    public let main: [Component]
    public let footer: [Component]
    public let details: [Detail]
    
    public init(
        header: [Component],
        main: [Component],
        footer: [Component],
        details: [Detail]
    ) {
        self.header = header
        self.main = main
        self.footer = footer
        self.details = details
    }
}

public extension UILanding {
    
    struct List{}
    struct Multi{}
}

extension UILanding {
    
    func components(
        g: String,
        v: String
    ) -> [Component] {
        guard
            let group = self.details.first(where: { $0.groupID.rawValue == g }),
            let view = group.dataGroup.first(where: { $0.viewID.rawValue == v })
        else { return [] }
        
        return view.dataView
    }
}

extension UILanding {
    
    func headerTitle() -> String {
        
        let titles = header.map {
            if case let .pageTitle(title) = $0 {
                return title.text + " " + (title.subTitle ?? "")
            } else { return "" }
        }
        return titles.first ?? ""
    }
    
    func headerTitleAlwaysFixed() -> String {
        
        let titles = main.map {
            if case let .pageTitle(title) = $0 {
                return title.text + " " + (title.subTitle ?? "")
            } else { return "" }
        }
        return titles.first ?? ""
    }
    
    func navigationTitle(
        offset: CGFloat,
        offsetForDisplayHeader: CGFloat
    ) -> String {
        
        if headerTitleAlwaysFixed().isEmpty {
            return offset > offsetForDisplayHeader ? headerTitle() : ""
        }
        return headerTitleAlwaysFixed()
    }
}
