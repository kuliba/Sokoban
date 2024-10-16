//
//  CollateralLoanLandingShowCaseConfig.swift
//
//
//  Created by Valentin Ozerov on 14.10.2024.
//

import SwiftUI

struct CollateralLoanLandingShowCaseViewConfig {
    
    let fonts: Fonts
    let paddings: Paddings

    let headerView: HeaderView
    let termsView: TermsView
    let bulletsView: BulletsView
    let imageView: ImageView
    let footerView: FooterView
    
    struct Fonts {
        
        let header: Font
        let body: Font
    }
    
    struct Paddings {

        let outer: Outer
        let top: CGFloat

        struct Outer {
            
            let vertical: CGFloat
            let leading: CGFloat
            let trailing: CGFloat
        }
    }

    struct HeaderView {

        let height: CGFloat
    }

    struct TermsView {

        let height: CGFloat
    }

    struct BulletsView {

        let itemSpacing: CGFloat
        let height: CGFloat
    }
    
    struct ImageView {

        let height: CGFloat
        let сornerRadius: CGFloat
    }

    struct FooterView {

        let height: CGFloat
    }
}

extension CollateralLoanLandingShowCaseViewConfig {

    static let base = Self(

        fonts: .init(

            header: Font.system(size: 32).bold(),
            body: Font.system(size: 14)
        ),
        paddings: .init(

            outer: .init(

                vertical: 32,
                leading: 19,
                trailing: 20
            ),
            top: 24
        ),
        headerView: .init(
            
            height: 80
        ),
        termsView: .init(
            
            height: 24
        ),
        bulletsView: .init(
            
            itemSpacing: 4,
            height: 84
        ),
        imageView: .init(
            
            height: 236,
            сornerRadius: 12
        ),
        footerView: .init(
            
            height: 48
        )
    )
}
