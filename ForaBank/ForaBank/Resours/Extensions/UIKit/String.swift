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
        let imageData = Data(self.utf8)
        let imageSVG = SVGKImage(data: imageData)
        let image = imageSVG?.uiImage ?? UIImage()
        return image
    }
    
    func getSymbol() -> String? {
        let locale = NSLocale(localeIdentifier: self)
        if locale.displayName(forKey: .currencySymbol, value: self) == self {
            let newlocale = NSLocale(localeIdentifier: self.dropLast() + "_en")
            return newlocale.displayName(forKey: .currencySymbol, value: self)
        }
        
        return locale.displayName(forKey: .currencySymbol, value: self)
    }
    
}
