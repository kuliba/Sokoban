import UIKit

class C2BSuccessViewController: UIViewController {

    var id: Int?
    var printFormType: String?
    let mainView = C2BSuccessView()
    let button = UIButton(title: "На главную")
    var getUImage: (Md5hash) -> UIImage? = { _ in UIImage() }
//    var confirmModel: C2BDetailsFormViewModel? {
//        didSet {
//            guard let model = confirmModel else { return }
//            mainView.confirmModel = model
//        }
//    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()

        button.addTarget(self, action:#selector(doneButtonTapped), for: .touchUpInside)
        mainView.detailTapped = { () in
            self.openDetailVC()
        }

        mainView.saveTapped = { [weak self] () in
            let vc = PDFViewerViewController()
            vc.id = self?.id
            vc.printFormType = self?.printFormType
            let navVC = UINavigationController(rootViewController: vc)
            navVC.modalPresentationStyle = .fullScreen
            self?.present(navVC, animated: true, completion: nil)
        }
    }

    fileprivate func setupUI() {
        navigationController?.navigationBar.isHidden = true
        view.backgroundColor = .white

        view.addSubview(button)
        button.anchor(left: view.leftAnchor, bottom: view.safeAreaLayoutGuide.bottomAnchor,
                right: view.rightAnchor, paddingLeft: 20, paddingBottom: 20,
                paddingRight: 20, height: 48)

        view.addSubview(mainView)
        mainView.anchor(
                top: view.safeAreaLayoutGuide.topAnchor, left: view.leftAnchor,
                bottom: button.topAnchor, right: view.rightAnchor,
                paddingTop: 90,  paddingLeft: 20, paddingBottom: 20, paddingRight: 20)

    }

    @objc func doneButtonTapped() {
        
        dismissViewControllers()
    }

    func openDetailVC() {
        let vc = C2BDetailsFormViewController()
//        vc.doneButton.isHidden = true
        vc.addCloseButton()
        vc.getUImage = getUImage
        vc.title = "Детали операции"
        let navVC = UINavigationController(rootViewController: vc)
        present(navVC, animated: true)
    }

    func dismissViewControllers() {
        view.window?.rootViewController?.dismiss(animated: true)
    }
}
