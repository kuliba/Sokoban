import Foundation
import AVFoundation
import UIKit

class PermissionHelper {
    static func checkCameraAccess(isAllowed: @escaping (Bool, UIAlertController?) -> Void) {
        func getAlert() -> UIAlertController {
            let alertController = UIAlertController(title: "Внимание", message: "Для сканирования QR кода, необходим доступ к камере", preferredStyle: .alert)
            alertController.addAction(UIAlertAction(title: "Понятно", style: .default, handler: { (action) in}))
            return alertController
        }

        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .denied:
            isAllowed(false, getAlert())
        case .restricted:
            isAllowed(false, getAlert())
        case .authorized:
            isAllowed(true, nil)
        case .notDetermined:
            AVCaptureDevice.requestAccess(for: .video) {
                isAllowed($0, nil)
            }
        @unknown default:
            print()
        }
    }
}