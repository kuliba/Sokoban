//
//  QRErrorViewController.swift
//  ForaBank
//
//  Created by Константин Савялов on 09.11.2021.
//

import UIKit

class QRErrorViewController: UIViewController , UITableViewDelegate, UITableViewDataSource {
    static var operators = [GKHOperatorsModel]()

    @IBOutlet weak var qrErrImg: UIImageView!
    
    @IBOutlet weak var qrErrText1: UILabel!
    
    @IBOutlet weak var qrErrText2: UILabel!
    
    @IBOutlet weak var tableView: UITableView!
    
    weak var delegate: QRErrorDelegate?

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.isNavigationBarHidden = false
        navigationItem.title = "Сканировать QR-код"
        navigationItem.setHidesBackButton(true, animated:true)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if QRErrorViewController.operators.count > 0 {
            qrErrImg.isHidden = true
            qrErrText1.isHidden = true
            qrErrText2.isHidden  = true
        }
    }

    @IBAction func goToTransfer(_ sender: UIButton) {
        dismiss(animated: true)
    }
    
    @IBAction func goToGKH(_ sender: UIButton) {
        let vc = TransferByRequisitesViewController()
        let navController = UINavigationController.init(rootViewController: vc)
        navController.modalPresentationStyle = .fullScreen
        present(navController, animated: true)
    }
}

extension QRErrorViewController {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        QRErrorViewController.operators.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: QRFoundOrgCell.reuseId, for: indexPath) as! QRFoundOrgCell
        let item = QRErrorViewController.operators[indexPath.row]
        cell.label.text = item.name
        cell.icon.image = item.logotypeList.first?.svgImage?.convertSVGStringToImage()
        return cell
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        64
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        GlobalModule.qrOperator = QRErrorViewController.operators[indexPath.row]
        //performSegue(withIdentifier: "input", sender: self)
        dismiss(animated: true)
    }
}
