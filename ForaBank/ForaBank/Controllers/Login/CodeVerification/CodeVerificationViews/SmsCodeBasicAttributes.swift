//
//  .swift
//  ForaBank
//
//  Created by Дмитрий on 25.05.2021.
//  Copyright © 2021 (C) 2017-2019 OОО "Бриг Инвест". All rights reserved.
//

import Foundation
import UIKit

typealias SmsCodeText = UITextField
typealias SmsCodeFloct = CGFloat

protocol SmsCodeProtocol {
    var textFiled:SmsCodeText {get}
    
    var codeNum:SmsCodeFloct {get set}
    
    var lineColor:UIColor {get set}
    
    var lineInputColor:UIColor {get set}
    
    var errorlineViewColor:UIColor {get set}
    
    var cursorColor:UIColor {get set}
    
    var fontNum:UIFont {get set}
    
    var textColor:UIColor {get set}
    
    
    mutating func changeViewBasicAttributes(lineColor:UIColor,lineInputColor:UIColor,cursorColor:UIColor,errorColor:UIColor,fontNum:UIFont,textColor:UIColor)
    
    mutating func changeInputNum(num:SmsCodeFloct)
}

//Значение свойства по умолчанию
struct SmsCodeBasicAttributes: SmsCodeProtocol {
    var textFiled: SmsCodeText = UITextField()
    
    /// длинна кода
    var codeNum: SmsCodeFloct = 0
    
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

extension SmsCodeBasicAttributes {
   mutating func changeViewBasicAttributes( lineColor: UIColor, lineInputColor: UIColor, cursorColor: UIColor, errorColor: UIColor, fontNum: UIFont, textColor: UIColor) {
        self.lineColor = lineColor
        self.lineInputColor = lineInputColor
        self.cursorColor = cursorColor
        self.fontNum = fontNum
        self.textColor = textColor
        self.errorlineViewColor = errorColor
    }
    mutating func changeInputNum(num: SmsCodeFloct) {
        self.codeNum = num
    }
}

