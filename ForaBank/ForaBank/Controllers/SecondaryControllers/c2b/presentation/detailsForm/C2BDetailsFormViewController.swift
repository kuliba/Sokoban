import UIKit
import RealmSwift


class C2BDetailsFormViewController: UIViewController {
    
    //
    //        when (answer.operationStatus) {
    //"IN_PROGRESS" -> detailsArr.add(DetailsDO(R.drawable.ic_waiting2,"Статус операции", "в обработке"))
    //"REJECTED" -> detailsArr.add(DetailsDO(R.drawable.ic_transfer_reject2,"Статус операции", "отказ"))
    //"COMPLETE" -> detailsArr.add(DetailsDO(R.drawable.ic_success2,"Статус операции", "успешно"))
    //"FAILED" -> detailsArr.add(DetailsDO(-1,"Статус операции", answer.operationStatus))
    //}
    //detailsArr.add(DetailsDO(-1, "source", ""))
    
    var amountField = C2BDetailsInputView(
        viewModel: C2BDetailsInputViewModel(
            title: "Сумма перевода",
            text: C2BDetailsViewModel.operationDetail?.amount?.currencyFormatter() ?? "",
            image: #imageLiteral(resourceName: "coins"),
            isEditable: false))
    
    var nameOfRecipientField = C2BDetailsInputView(
        viewModel: C2BDetailsInputViewModel(
            title: "Наименование ТСП",
            text: C2BDetailsViewModel.operationDetail?.merchantSubName ?? "",
            image: #imageLiteral(resourceName: "BankIcon"),
            isEditable: false))
    
    var dateOperation = C2BDetailsInputView(
        viewModel: C2BDetailsInputViewModel(
            title: "Дата и время операции (МСК)",
            text: C2BDetailsViewModel.operationDetail?.dateForDetail ?? "",
            image: #imageLiteral(resourceName: "date"),
            isEditable: false))
    
    var stateOfOperation = C2BDetailsInputView(
        viewModel: C2BDetailsInputViewModel(
            title: "Статус операции",
            text: C2BSuccessView.statusText,
            image: C2BSuccessView.statusImg!,
            isEditable: false))
    
    var cardFromField = CardChooseView()
    
    var nameOfRecipient2Field = C2BDetailsInputView(
        viewModel: C2BDetailsInputViewModel(
            title: "Получатель",
            text: C2BDetailsViewModel.operationDetail?.payeeFullName ?? "",
            image: UIImage(named: "fio")!,
            isEditable: false))
    
    var bankField = C2BDetailsInputView(
        viewModel: C2BDetailsInputViewModel(
            title: "Банк",
            image: UIImage(named: "hash")!,
            isEditable: false))
    
    var commentField = C2BDetailsInputView(
        viewModel: C2BDetailsInputViewModel(
            title: "Сообщение получателю",
            text: C2BDetailsViewModel.operationDetail?.comment ?? "",
            image: UIImage(named: "message")!,
            isEditable: false))
    
    var numberTransactionField = C2BDetailsInputView(
        viewModel: C2BDetailsInputViewModel(
            title: "Идентификатор операции",
            text: C2BDetailsViewModel.operationDetail?.transferNumber ?? "",
            image: UIImage(named: "hash")!,
            isEditable: false))
    
//    let doneButton = UIButton(title: "Оплатить")
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupData()
        setupUI()
        hideKeyboardWhenTappedAround()
    }
    
    func setupData() {
        dismissActivity()
        cardFromField.model = C2BDetailsViewModel.sourceModel
        cardFromField.isHidden = false
        cardFromField.choseButton.isHidden = true
        cardFromField.balanceLabel.isHidden = true
        cardFromField.titleLabel.text = "Счет списания"
        cardFromField.leftTitleAncor.constant = 64
    }
    
    fileprivate func setupUI() {
        view.backgroundColor = .white
        cardFromField.model = C2BDetailsViewModel.sourceModel
        
        let image = UIImage(named: "sbptext")
        let imageViewSBP = UIImageView(image: image!)
        //imageViewSBP.frame = CGRect(x: 0, y: 0, width: 100, height: 50)
        
        let viewImg = UIView()
        viewImg.addSubview(imageViewSBP)
        
        let scrollView = UIScrollView()
        scrollView.isScrollEnabled = true
        let stackView = UIStackView(
            arrangedSubviews: [amountField,
                               nameOfRecipientField,
                               dateOperation,
                               stateOfOperation,
                               cardFromField,
                               nameOfRecipient2Field,
                               bankField,
                               commentField,
                               numberTransactionField,
                               viewImg])
        stackView.axis = .vertical
        stackView.alignment = .fill
        stackView.distribution = .fill
        stackView.spacing = 10
        view.addSubview(scrollView)
        scrollView.addSubview(stackView)
        scrollView.anchor(top: view.topAnchor,
                          left: view.leftAnchor,
                          bottom: view.bottomAnchor,
                          right: view.rightAnchor)
        stackView.anchor(top: stackView.topAnchor,
                         left: stackView.leftAnchor,
                         right: stackView.rightAnchor,
                         height: 750)
        scrollView.contentSize.width = UIScreen.main.bounds.width
        scrollView.contentSize.height = 750
        viewImg.anchor(left: view.leftAnchor,
                            right: view.rightAnchor,
                            paddingBottom: 100)
        imageViewSBP.centerX(inView: viewImg)
        imageViewSBP.anchor(top: viewImg.topAnchor, paddingTop: 10)
    }
}
