import UIKit

protocol LoadingPresentable: AnyObject {
    func showLoader()
    func hideLoader()
    func showError(retryAction: @escaping () -> Void)
}

final class TasksListViewController: UIViewController, LoadingPresentable, UISearchResultsUpdating {
    
    private let viewModel: TaskListViewModel
    
    private lazy var loader = UIActivityIndicatorView(style: .large)
    private lazy var searchField: UISearchController = {
        let placeholderOfSearchField = NSLocalizedString("tasks.searchField.placeholder", comment: "")
        
        let searchController = UISearchController(searchResultsController: nil)
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchResultsUpdater = self
        searchController.searchBar.tintColor = .semiLightWhiteForText
        
        let textField = searchController.searchBar.searchTextField
        textField.backgroundColor = .forSearchFieldBackground
        
        textField.attributedPlaceholder = NSAttributedString(
            string: placeholderOfSearchField,
            attributes: [.foregroundColor: UIColor.semiLightWhiteForText])
        
        searchController.searchBar.layoutIfNeeded()
        if let icon = textField.leftView as? UIImageView {
            icon.image = icon.image?.withRenderingMode(.alwaysTemplate)
            icon.tintColor = UIColor.semiLightWhiteForText
        }
        
        let microImage = UIImage(systemName: "microphone.fill")
        let microButton = UIButton(type: .system)
            
        microButton.setImage(microImage, for: .normal)
        microButton.addTarget(self, action: #selector(microphoneTapped), for: .touchUpInside)
        microButton.translatesAutoresizingMaskIntoConstraints = false
            
        textField.addSubview(microButton)
        
        NSLayoutConstraint.activate([
            microButton.heightAnchor.constraint(equalToConstant: 24),
            microButton.widthAnchor.constraint(equalToConstant: 24),
            microButton.centerYAnchor.constraint(equalTo: textField.centerYAnchor),
            microButton.trailingAnchor.constraint(equalTo: textField.trailingAnchor, constant: -8)
        ])
        
        return searchController
    }()
    private lazy var tableViewWithTasks: UITableView = {
        let tableViewWithTasks = UITableView()
        tableViewWithTasks.delegate = self
        tableViewWithTasks.dataSource = self
        tableViewWithTasks.backgroundColor = .forViewBackground
        tableViewWithTasks.register(TaskTableViewCell.self, forCellReuseIdentifier: TaskTableViewCell.reusedIdentifier)
        tableViewWithTasks.separatorStyle = .singleLine
        tableViewWithTasks.separatorColor = .grayForUnselectedButtons
        tableViewWithTasks.rowHeight = UITableView.automaticDimension
        tableViewWithTasks.estimatedRowHeight = 90
        tableViewWithTasks.translatesAutoresizingMaskIntoConstraints = false
        
        return tableViewWithTasks
    }()
    private lazy var countOfTasksLabel: UILabel = UILabel()
    private lazy var footerView: UIView = {
        let footerView = UIView()
        
        footerView.backgroundColor = .forSearchFieldBackground
        footerView.translatesAutoresizingMaskIntoConstraints = false
        
        countOfTasksLabel.font = .headline6
        countOfTasksLabel.textColor = .whiteForText
        countOfTasksLabel.textAlignment = .center
        countOfTasksLabel.numberOfLines = 1
        countOfTasksLabel.text = ""
        countOfTasksLabel.translatesAutoresizingMaskIntoConstraints = false
        
        footerView.addSubview(countOfTasksLabel)
        
        let addNewTaskButton = UIButton(type: .system)
        let imageForAddNewTaskButton = UIImage(resource: .createTaskButton)
        
        addNewTaskButton.setImage(imageForAddNewTaskButton, for: .normal)
        addNewTaskButton.addTarget(self, action: #selector(addNewTaskButtonTapped), for: .touchUpInside)
        addNewTaskButton.tintColor = .yellowForButtons
        addNewTaskButton.translatesAutoresizingMaskIntoConstraints = false
        
        footerView.addSubview(addNewTaskButton)
        
        NSLayoutConstraint.activate([
            countOfTasksLabel.centerXAnchor.constraint(equalTo: footerView.centerXAnchor),
            countOfTasksLabel.widthAnchor.constraint(equalToConstant: 50),
            countOfTasksLabel.topAnchor.constraint(equalTo: footerView.topAnchor, constant: 20),
            
            addNewTaskButton.heightAnchor.constraint(equalToConstant: 28),
            addNewTaskButton.widthAnchor.constraint(equalToConstant: 68),
            addNewTaskButton.trailingAnchor.constraint(equalTo: footerView.trailingAnchor),
            addNewTaskButton.centerYAnchor.constraint(equalTo: countOfTasksLabel.centerYAnchor)
        ])
        
        return footerView
    }()
    
    init(viewModel: TaskListViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .forViewBackground
        
        viewModel.loadDataFromCoreDate()
        
        addSubviewsAndSetupAllViews()
        updateCountOfTasks()
    }
    
    func updateSearchResults(for searchController: UISearchController) {
        //TODO: Make search logic
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
    
    @objc private func microphoneTapped() {
        print("Микрофон нажат")
    }
    
    @objc private func addNewTaskButtonTapped() {
        //TODO: Make add new task logic
    }
    
    private func addSubviewsAndSetupAllViews() {
        [loader, tableViewWithTasks, footerView].forEach {
            view.addSubview($0)
        }
        
        setupConstraints()
        setupLoader()
        setupNavBar()
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            
            tableViewWithTasks.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableViewWithTasks.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            tableViewWithTasks.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            tableViewWithTasks.bottomAnchor.constraint(equalTo: footerView.topAnchor),
            
            footerView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            footerView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            footerView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            footerView.heightAnchor.constraint(equalToConstant: 83)
            
        ])
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
    
    private func setupNavBar() {
        let titleText = NSLocalizedString("tasks.header.title", comment: "")
        let appearance = UINavigationBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = .forViewBackground

        appearance.largeTitleTextAttributes = [
            .foregroundColor: UIColor.whiteForText
        ]

        navigationController?.navigationBar.standardAppearance = appearance
        navigationController?.navigationBar.scrollEdgeAppearance = appearance
        navigationController?.navigationBar.compactAppearance = appearance
        
        navigationController?.navigationBar.prefersLargeTitles = true
        
        navigationItem.searchController = searchField
        navigationItem.hidesSearchBarWhenScrolling = true
        navigationItem.largeTitleDisplayMode = .always
        
        navigationItem.title = titleText
    }
    
    private func reloadDataInTableAfterChangingsInCoreData() {
        viewModel.loadDataFromCoreDate()
        updateCountOfTasks()
        tableViewWithTasks.reloadData()
    }
    
    private func updateCountOfTasks() {
        countOfTasksLabel.text = "\(viewModel.listOfTasks.count) Задач"
    }
    
}

extension TasksListViewController: TaskStoreDelegate {
    func store(_ store: TaskStore, didUpdate: StoreUpdate) {
        reloadDataInTableAfterChangingsInCoreData()
    }
}

extension TasksListViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        self.viewModel.listOfTasks.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        guard let cell = tableView.dequeueReusableCell(withIdentifier: TaskTableViewCell.reusedIdentifier, for: indexPath) as? TaskTableViewCell else { return UITableViewCell() }
        
        let task = self.viewModel.listOfTasks[indexPath.row]
        
        cell.configure(task: task)
        cell.onCompletionTask = { [weak self] in
            
        }
        
        return cell
    }
}
