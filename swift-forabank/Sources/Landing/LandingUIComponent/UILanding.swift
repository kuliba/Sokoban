//
//  UILanding.swift
//  
//
//  Created by Andryusina Nataly on 02.09.2023.
//

import Foundation

public struct UILanding: Equatable { 
    
    let header: [Component]
    let main: [Component]
    let footer: [Component]
    let details: [Detail]
    
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
    
   typealias CanOpenDetail = (DetailDestination) -> Bool
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

extension UILanding {

    func titleInMain() -> UILanding.PageTitle {
        let pageTitle: UILanding.PageTitle = .init(text: "", subTitle: "", transparency: false)
        
        let titlesInHeader = main.map {
            if case let .pageTitle(title) = $0 {
                return UILanding.PageTitle.init(text: title.text,
                                  subTitle: title.subTitle ?? "",
                                 transparency: title.transparency)
                
            } else { return pageTitle }
        }
       
        return titlesInHeader.first ?? pageTitle
    }
    
  func shouldShowNavigationTitle(offset: CGFloat, offsetForDisplayHeader: CGFloat) -> Bool {
      if headerTitleAlwaysFixed().isEmpty {
          if offset > offsetForDisplayHeader {
              return true
          }
      }
      return false
  }

}
