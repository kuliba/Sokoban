//
//  RequisitesViewController.swift
//  ForaBank
//
//  Created by Дмитрий on 16.09.2021.
//

import UIKit
import PDFKit


class RequisitesViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    var tableView = UITableView()
    var cardUnMask = false
    var mockItem: [PaymentsModel] = []
    var product: UserAllCardsModel? = nil {
        didSet{
            if product?.productType == "ACCOUNT"{
                mockItem.removeLast(3)
            }
        }
    }
    var model: GetProductDetailsDataClass?
    var modelDeposit: DepositInfoData?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        setupUI()
        tableView.delegate = self
        tableView.dataSource = self
        view.addSubview(tableView)
        tableView.anchor(top: view.topAnchor, left: view.leftAnchor, bottom: view.bottomAnchor, right: view.rightAnchor, paddingTop: 20, paddingLeft: 20, paddingRight: 20)
        tableView.separatorStyle = UITableViewCell.SeparatorStyle.none

        tableView.register(UINib(nibName: "RequisitsTableViewCell", bundle: nil), forCellReuseIdentifier: "RequisitsTableViewCell")
        mockItem = mockItem.filter({$0.description != nil})
        self.tableView.rowHeight = 56
        self.tableView.showsVerticalScrollIndicator = false

        // Do any additional setup after loading the view.
    }
    
    
    func setupUI(){
        
        if modelDeposit != nil{
            title = "Информация по вкладу"

        } else{
            switch product?.productType {
            case ProductType.loan.rawValue:
                title = "Рекзвизиты счета"
            case "DEPOSIT":
                title = "Рекзвизиты счета вклада"
            default:
                title = "Рекзвизиты счета карты"

            }
            
            let button: UIButton = UIButton(type: .custom)
                  //set image for button
            button.setImage(UIImage(named: "share"), for: .normal)
                  //add function for button
            button.addTarget(self, action: #selector(share), for: .touchUpInside)
                //set frame
            button.frame = CGRect(x: 0, y: 0, width: 53, height: 31)

            let barButton = UIBarButtonItem(customView: button)
                  //assign button to navigationbar
            self.navigationItem.rightBarButtonItem = barButton

        }
        navigationController?.view.backgroundColor =  .white
        let close = UIBarButtonItem(title: "", style: .plain, target: self, action: #selector(backButton))
        close.tintColor = .black
        
        self.navigationItem.rightBarButtonItem?.setTitleTextAttributes([.foregroundColor: UIColor.black], for: .normal)
        self.navigationItem.rightBarButtonItem?.setTitleTextAttributes([.foregroundColor: UIColor.black], for: .highlighted)
    }

    @objc func backButton(){
        dismiss(animated: true, completion: nil)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch product?.productType {
        case "DEPOSIT":
            return mockItem.count

        default:
            return mockItem.count

        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "RequisitsTableViewCell", for: indexPath) as? RequisitsTableViewCell
        
        cell?.nameCellLabel.text = mockItem[indexPath.row].name
        cell?.titleLabel.text = mockItem[indexPath.row].description
        cell?.product = self.product
        cell?.rightButton.imageView?.image = UIImage(named: mockItem[indexPath.row].iconName ?? "")
        if cell?.nameCellLabel.text == "Номер карты"{
            cell?.rightButton.isHidden = false
            cell?.rightButton.addTarget(self,
                action: #selector(self.unmaskNumber),
                for: .touchUpInside)
            
        } else {
            cell?.rightButton.isHidden = true
        }
        cell?.selectionStyle = .none
        return cell ?? UITableViewCell()
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        UIPasteboard.general.string = mockItem[indexPath.row].description
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
       return 100
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
       let footerView = UIView()
        if modelDeposit == nil{
            footerView.backgroundColor = .clear
            footerView.frame = CGRect(x: 0, y: 0, width: self.view.frame.width, height:
                                        50)
            let button = UIButton()
            button.setTitle("Поделиться", for: .normal)
            button.backgroundColor = UIColor(hexString: "EAEBEB")
            button.setTitleColor(.black, for: .normal)
            footerView.addSubview(button)
            button.center(inView: footerView)
            button.anchor(left: footerView.leftAnchor, right: footerView.rightAnchor, height: 48)
            button.layer.cornerRadius = 8
            button.addTarget(self,
                             action: #selector(self.share),
                             for: .touchUpInside)
        }
        return footerView
    }
    
    @objc func unmaskNumber() {
        mockItem[7].description = product?.number
        mockItem[7].iconName = "eye-off"
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 3.0) {
            self.mockItem[7].description = self.model?.maskCardNumber
            self.mockItem[7].iconName = "eye"
            self.tableView.reloadData()
        }
        tableView.reloadData()
    }
    
    
    
    @objc func sharedButton() {
        UIPasteboard.general.string = product?.number
    }
    
    @objc func copyValuePressed() {
        UIPasteboard.general.string = product?.number
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
    
    @objc private func share(){
       
        var textToShare = [String]()
        textToShare.append("")
        for i in mockItem {
            guard let description = i.description else {
                return
            }
            textToShare[0].append(String(i.name + " " + description + "\n"))
        }
            
        let activityViewController = UIActivityViewController(activityItems: textToShare, applicationActivities: nil)
            activityViewController.popoverPresentationController?.sourceView = self.view // so that iPads won't crash
            
            // exclude some activity types from the list (optional)
        activityViewController.excludedActivityTypes = [ UIActivity.ActivityType.mail, UIActivity.ActivityType.message,  UIActivity.ActivityType.airDrop, UIActivity.ActivityType.postToFacebook ]
            
            // present the view controller
            self.present(activityViewController, animated: true, completion: nil)
    }

}
extension UITableView{
    // Export pdf from UITableView and save pdf in drectory and return pdf file path
    func exportAsPdfFromTable(pdfName:String) -> String {
        let originalBounds = self.bounds
        self.bounds = CGRect(x:originalBounds.origin.x, y: originalBounds.origin.y, width: self.contentSize.width, height: self.contentSize.height)
        let pdfPageFrame = CGRect(x: 0, y: 0, width: self.bounds.size.width, height: self.contentSize.height)
        self.backgroundView?.backgroundColor = .red
        let pdfData = NSMutableData()
        UIGraphicsBeginPDFContextToData(pdfData, pdfPageFrame, nil)
        UIGraphicsBeginPDFPageWithInfo(pdfPageFrame, nil)
        guard let pdfContext = UIGraphicsGetCurrentContext() else { return "" }
        self.layer.render(in: pdfContext)
        UIGraphicsEndPDFContext()
        self.bounds = originalBounds
        // Save pdf data
        return self.saveTablePdf(data: pdfData,name:pdfName)

    }

    // Save pdf file in document directory
    func saveTablePdf(data: NSMutableData,name:String) -> String {

        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        let docDirectoryPath = paths[0]
        let pdfPath = docDirectoryPath.appendingPathComponent("\(name).pdf")
        if data.write(to: pdfPath, atomically: true) {
            return pdfPath.path
        } else {
            return ""
        }
    }
}
