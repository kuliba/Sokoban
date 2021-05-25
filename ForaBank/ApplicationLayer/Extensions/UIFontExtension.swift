//
//  UIFontExtension.swift
//  ForaBank
//
//  Created by Дмитрий Савушкин on 09.09.2020.
//  Copyright © 2020 (C) 2017-2019 OОО "Бриг Инвест". All rights reserved.
//

import Foundation


extension UIFont {
  
  var bold: UIFont {
    return with(traits: .traitBold)
  }
  
  var regular: UIFont {
    var fontAtrAry = fontDescriptor.symbolicTraits
    fontAtrAry.remove([.traitBold])
    let fontAtrDetails = fontDescriptor.withSymbolicTraits(fontAtrAry)
    return UIFont(descriptor: fontAtrDetails!, size: pointSize)
  }
  
  func with(traits: UIFontDescriptor.SymbolicTraits) -> UIFont {
    guard let descriptor = fontDescriptor.withSymbolicTraits(traits) else {
      return self
    }
    return UIFont(descriptor: descriptor, size: 0)
  }
}

