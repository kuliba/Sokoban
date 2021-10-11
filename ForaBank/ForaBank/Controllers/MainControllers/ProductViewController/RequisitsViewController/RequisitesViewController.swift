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
    var product: GetProductListDatum? 
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        setupUI()
        tableView.delegate = self
        tableView.dataSource = self
        view.addSubview(tableView)
        tableView.anchor(top: view.topAnchor, left: view.leftAnchor, bottom: view.bottomAnchor, right: view.rightAnchor, paddingTop: 20, paddingLeft: 20, paddingRight: 20)
//        tableView.contentInset = UIEdgeInsets(top: 20, left: 20, bottom: 20, right: 20)
        tableView.separatorStyle = UITableViewCell.SeparatorStyle.none

        tableView.register(UINib(nibName: "RequisitsTableViewCell", bundle: nil), forCellReuseIdentifier: "RequisitsTableViewCell")
        
        self.tableView.rowHeight = 56

        // Do any additional setup after loading the view.
    }
    
    
    func setupUI(){
//        let label = UILabel()
//        label.textColor = UIColor.black
//        label.font = UIFont.boldSystemFont(ofSize: 16)
//        label.text = "Реквизиты счета карты"
//        self.navigationItem.leftBarButtonItem = UIBarButtonItem.init(customView: label)
//        self.navigationItem.leftItemsSupplementBackButton = true
        title = "Рекзвизиты счета карты"
        navigationController?.view.backgroundColor =  .white
        let close = UIBarButtonItem(title: "", style: .plain, target: self, action: #selector(backButton))
        close.tintColor = .black
        
        let button: UIButton = UIButton(type: .custom)
              //set image for button
        button.setImage(UIImage(named: "share"), for: .normal)
              //add function for button
        button.addTarget(self, action: "createPdfFromTableView", for: .touchUpInside)
            //set frame
        button.frame = CGRect(x: 0, y: 0, width: 53, height: 31)

        let barButton = UIBarButtonItem(customView: button)
              //assign button to navigationbar
        self.navigationItem.rightBarButtonItem = barButton
        //        self.navigationItem.setRightBarButton(close, animated: true)
        
        //        self.navigationItem.rightBarButtonItem?.action = #selector(backButton)
//        self.navigationItem.rightBarButtonItem = close
        self.navigationItem.rightBarButtonItem?.setTitleTextAttributes([.foregroundColor: UIColor.black], for: .normal)
        self.navigationItem.rightBarButtonItem?.setTitleTextAttributes([.foregroundColor: UIColor.black], for: .highlighted)
    }

    @objc func backButton(){
        dismiss(animated: true, completion: nil)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return mockItem.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "RequisitsTableViewCell", for: indexPath) as? RequisitsTableViewCell
        cell?.nameCellLabel.text = mockItem[indexPath.row].name
        cell?.titleLabel.text = mockItem[indexPath.row].description
        cell?.product = self.product
        if cell?.nameCellLabel.text == "Номер карты"{
            cell?.rightButton.isHidden = false
            cell?.rightButton.addTarget(self,
                action: #selector(self.unmaskNumber),
                for: .touchUpInside)
        } else if cell?.nameCellLabel.text == "Кореспондентский счет"{
            cell?.rightButton.setImage(UIImage(named: "copy"), for: .normal)
            cell?.rightButton.isHidden = true
            cell?.rightButton.addTarget(self,
                action: #selector(self.copyValuePressed),
                for: .touchUpInside)

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
                         action: #selector(self.sharePDF),
                         for: .touchUpInside)
        return footerView
    }
    
    @objc func unmaskNumber() {
        mockItem[2].description = product?.number
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
    @objc func createPdfFromTableView(){
        let priorBounds: CGRect = self.tableView.bounds
        let fittedSize: CGSize = self.tableView.sizeThatFits(CGSize(width: priorBounds.size.width, height: self.tableView.contentSize.height))
        self.tableView.bounds = CGRect(x: 0, y: 0, width: fittedSize.width, height: fittedSize.height)
        self.tableView.reloadData()
        let pdfPageBounds: CGRect = CGRect(x: 0, y: 0, width: fittedSize.width, height: (fittedSize.height))
        let pdfData: NSMutableData = NSMutableData()
        UIGraphicsBeginPDFContextToData(pdfData, pdfPageBounds, nil)
        UIGraphicsBeginPDFPageWithInfo(pdfPageBounds, nil)
        self.tableView.layer.render(in: UIGraphicsGetCurrentContext()!)
        UIGraphicsEndPDFContext()
        let documentDirectories = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first
        let documentsFileName = documentDirectories! + "/" + "pdfName"
        pdfData.write(toFile: documentsFileName, atomically: true)
        print(documentsFileName)
    }
    
    @objc   func sharePDF() {
       
        let path = Bundle.main.path(forResource:  tableView.exportAsPdfFromTable(pdfName: "Requisites"),  ofType:"pdf") ?? ""
        
        let namePath = tableView.exportAsPdfFromTable(pdfName: "Requisites")
        let fileURL = URL(fileURLWithPath: namePath)

               // Create the Array which includes the files you want to share
               var filesToShare = [Any]()

               // Add the path of the file to the Array
               filesToShare.append(fileURL)

               // Make the activityViewContoller which shows the share-view
               let activityViewController = UIActivityViewController(activityItems: filesToShare, applicationActivities: nil)

               // Show the share-view
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
