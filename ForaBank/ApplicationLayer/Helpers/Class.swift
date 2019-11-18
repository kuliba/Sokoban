//
//  Class.swift
//  ForaBank
//
//  Created by Бойко Владимир on 13.11.2019.
//  Copyright © 2019 (C) 2017-2019 OОО "Бриг Инвест". All rights reserved.
//

import Foundation

public func swizzle(targetClass: AnyObject, implementerClass: AnyObject, currentMethod: Selector, preferredMethod: Selector) {

    guard let fromType: AnyClass = object_getClass(targetClass.self),
        let toType: AnyClass = object_getClass(implementerClass.self),
        let originalMethod = class_getInstanceMethod(fromType, currentMethod),
        let swizzledMethod = class_getInstanceMethod(toType, preferredMethod) else {
            return
    }

    method_exchangeImplementations(originalMethod, swizzledMethod)
}
