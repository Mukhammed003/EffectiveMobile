import UIKit

enum TreckerCreationError: Error {
    case duplicate
}

protocol LoadingPresentable: AnyObject {
    func showLoader()
    func hideLoader()
    func showError(retryAction: @escaping () -> Void)
}

final class TaskListViewController: UIViewController, LoadingPresentable {
    
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
        textField.textColor = .semiLightWhiteForText
        textField.clearButtonMode = .never
        
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
        nil
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .forViewBackground
        
        viewModel.taskStore.delegate = self
        
        addSubviewsAndSetupAllViews()
        updateCountOfTasks()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        navigationController?.navigationBar.prefersLargeTitles = true
        searchField.searchBar.searchTextField.textColor = .semiLightWhiteForText
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
        let viewModel = TaskViewModel(taskMode: .add)
        viewModel.newTaskId = self.viewModel.calculateIdForNewTask()
        let viewController = TaskViewController(viewModel: viewModel)
        let backButtonTitle = NSLocalizedString("navigationItem.backButton.title", comment: "")
        
        self.navigationItem.backButtonTitle = backButtonTitle
        
        viewController.onCreate = { [weak self] task, completion in
            guard let self else { return }
            
            if self.viewModel.isExistsSuchTask(name: task.name) {
                completion(.failure(.duplicate))
                return
            }
            
            self.viewModel.addNewTaskToCoreData(task: task)
            completion(.success(()))
        }
        
        navigationController?.pushViewController(viewController, animated: true)
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
        updateCountOfTasks() 
        tableViewWithTasks.reloadData()
    }
    
    private func updateCountOfTasks() {
        countOfTasksLabel.text = "\(viewModel.listOfTasks.count) Задач"
    }
    
    private func shareTask(task: SingleTask) {
        let activity = UIActivityViewController(activityItems: [task.name], applicationActivities: nil)
        present(activity, animated: true, completion: nil)
    }
    
    private func showDeleteAlert(for taskId: Int16) {
        let titleOfDeleteAlert = NSLocalizedString("tasks.deleteAlert.title", comment: "")
        let textOfDeleteButton = NSLocalizedString("deleteAlert.deleteButton.text", comment: "")
        let textOfCancelButton = NSLocalizedString("deleteAlert.cancelButton.text", comment: "")
        
        let alert = UIAlertController(
            title: titleOfDeleteAlert,
            message: nil,
            preferredStyle: .actionSheet
        )
        
        let deleteAction = UIAlertAction(title: textOfDeleteButton, style: .destructive) { [weak self] _ in
            self?.viewModel.deleteTask(taskId: taskId)
        }
        
        let cancelAction = UIAlertAction(title: textOfCancelButton, style: .cancel)
        
        alert.addAction(deleteAction)
        alert.addAction(cancelAction)
        
        if let popover = alert.popoverPresentationController {
            popover.sourceView = self.view
            popover.sourceRect = CGRect(
                x: self.view.bounds.midX,
                y: self.view.bounds.midY,
                width: 0,
                height: 0
            )
            popover.permittedArrowDirections = []
        }
        
        present(alert, animated: true)
    }
}

extension TaskListViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        guard let searchText = searchController.searchBar.text else { return }
        
        if searchText.isEmpty {
            viewModel.isSearching = false
            viewModel.needTasksForSelector = []
        } else {
            viewModel.isSearching = true
            viewModel.needTasksForSelector = viewModel.listOfTasks.filter {
                $0.name.lowercased().contains(searchText.lowercased())
            }
        }
        
        tableViewWithTasks.reloadData()
    }
}

extension TaskListViewController: TaskStoreDelegate {
    func store(_ store: TaskStore, didUpdate: StoreUpdate) {
        reloadDataInTableAfterChangingsInCoreData()
    }
}

extension TaskListViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        self.viewModel.isSearching
        ? self.viewModel.needTasksForSelector.count
        : self.viewModel.listOfTasks.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        guard let cell = tableView.dequeueReusableCell(withIdentifier: TaskTableViewCell.reusedIdentifier, for: indexPath) as? TaskTableViewCell else { return UITableViewCell() }
        
        let task = self.viewModel.isSearching
        ? self.viewModel.needTasksForSelector[indexPath.row]
        : self.viewModel.listOfTasks[indexPath.row]
        
        cell.configure(task: task)
        
        cell.menuHandler = { [weak self] contextMenuAction in
            guard let self else { return }
            
            switch contextMenuAction {
            case .edit:
                let viewModel = TaskViewModel(taskMode: .edit(task: task))
                viewModel.newTaskId = self.viewModel.calculateIdForNewTask()
            
                let viewController = TaskViewController(viewModel: viewModel)
                
                let backButtonTitle = NSLocalizedString("navigationItem.backButton.title", comment: "")
                self.navigationItem.backButtonTitle = backButtonTitle
                
                viewController.onEdit = { [weak self] task, completion in
                    guard let self else { return }
                    
                    if self.viewModel.isExistsSuchTask(name: task.name) {
                        completion(.failure(.duplicate))
                    }
                    
                    self.viewModel.updateTask(task: task)
                    completion(.success(()))
                }
                
                navigationController?.pushViewController(viewController, animated: true)
            case .share:
                shareTask(task: task)
            case .delete:
                showDeleteAlert(for: task.id)
            }
        }
        
        cell.onCompletionTask = { [weak self] in
            guard let self else { return }
            
            self.viewModel.changeStatusOfTask(taskId: task.id)
        }
        
        return cell
    }
}
