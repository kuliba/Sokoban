//
//  AsunBasicAttributes.swift
//  ForaBank
//
//  Created by Дмитрий on 25.05.2021.
//  Copyright © 2021 (C) 2017-2019 OОО "Бриг Инвест". All rights reserved.
//

import Foundation
import UIKit

typealias AsunText = UITextField
typealias AsunFloct = CGFloat

protocol AsunCodeProtocol {
    var textFiled:AsunText {get}
    
    var codeNum:AsunFloct {get set}
    
    var lineColor:UIColor {get set}
    
    var lineInputColor:UIColor {get set}
    
    var errorlineViewColor:UIColor {get set}
    
    var cursorColor:UIColor {get set}
    
    var fontNum:UIFont {get set}
    
    var textColor:UIColor {get set}
    
    
    mutating func changeViewBasicAttributes(lineColor:UIColor,lineInputColor:UIColor,cursorColor:UIColor,errorColor:UIColor,fontNum:UIFont,textColor:UIColor)
    
    mutating func changeInputNum(num:AsunFloct)
}

//Значение свойства по умолчанию
struct AsunBasicAttributes:AsunCodeProtocol {
    var textFiled: AsunText = UITextField()
    
    /// длинна кода
    var codeNum: AsunFloct = 0
    
    /// цвет линии под полем не введеный
    var lineColor: UIColor = #colorLiteral(red: 0.5921568627, green: 0.5921568627, blue: 0.5921568627, alpha: 1)
    
    /// цвет линии под полем введеный
    var lineInputColor: UIColor = #colorLiteral(red: 0.5921568627, green: 0.5921568627, blue: 0.5921568627, alpha: 1)
    
    /// цвет линии под полем с ошибкой
    var errorlineViewColor: UIColor = UIColor.red
    
    /// цвет курсора
    var cursorColor: UIColor = UIColor.black
    
    /// шрифт
    var fontNum: UIFont = UIFont.systemFont(ofSize: 32)
    
    /// цвет шрифта
    var textColor: UIColor = #colorLiteral(red: 0.5921568627, green: 0.5921568627, blue: 0.5921568627, alpha: 1)
}

extension AsunBasicAttributes {
   mutating func changeViewBasicAttributes( lineColor: UIColor, lineInputColor: UIColor, cursorColor: UIColor, errorColor: UIColor, fontNum: UIFont, textColor: UIColor) {
        self.lineColor = lineColor
        self.lineInputColor = lineInputColor
        self.cursorColor = cursorColor
        self.fontNum = fontNum
        self.textColor = textColor
        self.errorlineViewColor = errorColor
    }
    mutating func changeInputNum(num: AsunFloct) {
        self.codeNum = num
    }
}

extension String {
    func subString(start:Int, length:Int = -1) -> String {
        var len = length
        if len == -1 {
            len = self.count - start
        }
        let st = self.index(startIndex, offsetBy:start)
        let en = self.index(st, offsetBy:len)
        return String(self[st ..< en])
    }
}
