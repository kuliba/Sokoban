//
//  ExtensionGKHMainQR.swift
//  ForaBank
//
//  Created by Константин Савялов on 03.09.2021.
//

import Foundation

extension GKHMainViewController: QRProtocol {
    
    ///  Метод делегата. При сакинировании QR возвращает данные по оператору
    func setResultOfBusinessLogic(_ qr: [String : String], _ model: GKHOperatorsModel) {
        self.qrData = qr
        self.operators = model
        defineOperatorType() { [weak self] value in
            self?.operatorType = value
            DispatchQueue.main.async {
            self?.performSegue(withIdentifier: "input", sender: self)
            }
        }
    }
    
    /// Метод, возвращающий из запроса /rest/transfer/isSingleService значение false/true, в зависимости от того,
    /// одношаговый оператор или нет. False - многощаговый оператор, true - одношаговый
    final func defineOperatorType(_ complition: @escaping (Bool) -> Void) {
        
        let puref = self.operators?.puref ?? ""
        let body = ["puref" : puref] as [String: AnyObject]
        NetworkManager<IsSingleServiceDecodableModel>.addRequest(.isSingleService, [:], body) { model, error in
            
            if error != nil {
                print(#function, "Error")
            }
            guard let model = model else { return }
            if model.statusCode == 0 {
                guard let data = model.data else { return }
                complition(data)
            } else {
                print(#function, model.errorMessage ?? "")
                complition(true)
            }
        }
    }
}
