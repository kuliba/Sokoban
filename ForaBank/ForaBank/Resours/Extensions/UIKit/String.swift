import Foundation
import UIKit
import SVGKit

extension String {

    /// конвертирует имя контролева из String значения в UIViewController
    func getViewController() -> UIViewController? {
        if let appName = Bundle.main.infoDictionary?["CFBundleName"] as? String {
            print("CFBundleName - \(appName)")
            if let viewControllerType = NSClassFromString("\(appName).\(self)") as? UIViewController.Type {
                return viewControllerType.init()
            }
        }
        return nil
    }
    
    func capitalizingFirstLetter() -> String {
        return prefix(1).uppercased() + self.lowercased().dropFirst()
    }

    func convertSVGStringToImage() -> UIImage {
        let imageData = Data(self.data)
        let imageSVG = SVGKImage(data: imageData)
        let image = imageSVG?.uiImage ?? UIImage()
        return image
    }
    
    func getSymbol() -> String? {
        
        var resultString = ""
        let currArr = Dict.shared.currencyList
        currArr?.forEach({ currency in
            if currency.code == self {
                
                var symbolArr = currency.cssCode?.components(separatedBy: "\\")
                symbolArr?.removeFirst()
                
                symbolArr?.forEach { qqqq in
                    if let charCode = UInt32(qqqq, radix: 16), let unicode = UnicodeScalar(charCode) {
                        let str = String(unicode)
                        resultString.append(str)
                    } else {
                        print("invalid input")
                    }
                }
            }
        })
        return resultString
    }
    
    func toDouble() -> Double? {
        return NumberFormatter().number(from: self)?.doubleValue
    }
    
    var isNumeric: Bool {
        guard self.count > 0 else { return false }
        let nums: Set<Character> = ["0", "1", "2", "3", "4", "5", "6", "7", "8", "9"]
        return Set(self).isSubset(of: nums)
    }
    
    
    func numberFormatter() -> String{
        let mask = StringMask(mask: "+7 (000) 000-00-00")
        return mask.mask(string: self) ?? ""
    }

    func filterred() -> String {
        filter { ("0"..."9").contains($0) }
    }
}
