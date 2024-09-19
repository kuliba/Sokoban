//
//  BannerPickerSectionBinderWrapper.swift
//  ForaBank
//
//  Created by Andryusina Nataly on 19.09.2024.
//

import Foundation
import Banners

final class BannerPickerSectionBinderWrapper: MainSectionViewModel {
    override var type: MainSectionType { .promo }
    
    let binder: BannersBinder
    
    init(binder: BannersBinder) {
        self.binder = binder
    }
}
