import UIKit

protocol LoadingPresentable: AnyObject {
    func showLoader()
    func hideLoader()
    func showError(retryAction: @escaping () -> Void)
}

class TasksListViewController: UIViewController, LoadingPresentable {
    
    private let viewModel: TaskListViewModel
    
    private let loader = UIActivityIndicatorView(style: .large)
    
    init(viewModel: TaskListViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        addSubviews()
        setupLoader()
    }
    
    func showLoader() {
        view.isUserInteractionEnabled = false
        loader.startAnimating()
    }
    
    func hideLoader() {
        loader.stopAnimating()
        view.isUserInteractionEnabled = true
    }
    
    func showError(retryAction: @escaping () -> Void) {
        let repeatAction = UIAlertAction(title: "Повторить", style: .default) { _ in
            retryAction()
        }
        let cancelAction = UIAlertAction(title: "Отменить", style: .cancel)
        
        let alert = UIAlertController(
            title: "Ошибка во время загрузки данных",
            message: nil,
            preferredStyle: .alert
        )
        
        alert.addAction(repeatAction)
        alert.addAction(cancelAction)
        
        present(alert, animated: true)
    }
    
    private func addSubviews() {
        view.addSubview(loader)
    }
    
    private func setupLoader() {
        loader.translatesAutoresizingMaskIntoConstraints = false
        loader.hidesWhenStopped = true
        loader.color = .whiteForText
        
        NSLayoutConstraint.activate([
            loader.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            loader.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }
    
    private func reloadDataInTableAfterChangingsInCoreData() {
        
    }
    
}
