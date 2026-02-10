import UIKit

// MARK: - TaskViewController

final class TaskViewController: UIViewController {
    
    // MARK: - Callbacks
    
    var onCreate: ((SingleTask, @escaping (Result<Void, TreckerCreationError>) -> Void) -> Void)?
    var onEdit: ((SingleTask) -> Void)?
    
    // MARK: - Dependencies
    
    private let viewModel: TaskViewModel
    
    // MARK: - UI Elements
    
    private let titleOfTaskTextField: UITextField = {
        let titleOfTaskTextField = UITextField()
        let placeholder = NSLocalizedString("task.titleOfTask.placeholder", comment: "")
        
        titleOfTaskTextField.attributedPlaceholder = NSAttributedString(
            string: placeholder,
            attributes: [
                .foregroundColor: UIColor.semiLightWhiteForText,
                .font: UIFont.giantText
            ])
        
        titleOfTaskTextField.tintColor = .semiLightWhiteForText
        titleOfTaskTextField.font = .giantText
        titleOfTaskTextField.textColor = .whiteForText
        titleOfTaskTextField.backgroundColor = .forViewBackground
        titleOfTaskTextField.translatesAutoresizingMaskIntoConstraints = false
        
        return titleOfTaskTextField
    }()
    
    private let dateOfTaskLabel: UILabel = {
        let dateOfTaskLabel = UILabel()
        dateOfTaskLabel.font = .headline5
        dateOfTaskLabel.textColor = .semiLightWhiteForText
        dateOfTaskLabel.textAlignment = .left
        dateOfTaskLabel.translatesAutoresizingMaskIntoConstraints = false
        
        return dateOfTaskLabel
    }()
    
    private let placeholderOfDescriptionField = UILabel()
    
    private lazy var descriptionOfTaskTextView: UITextView = {
        let descriptionOfTaskTextView = UITextView()
        let placeholder = NSLocalizedString("task.descriptionOfTask.placeholder", comment: "")
        descriptionOfTaskTextView.font = .headline4
        descriptionOfTaskTextView.textColor = .whiteForText
        descriptionOfTaskTextView.delegate = self
        descriptionOfTaskTextView.backgroundColor = .forViewBackground
    
        placeholderOfDescriptionField.text = placeholder
        placeholderOfDescriptionField.textColor = .semiLightWhiteForText
        placeholderOfDescriptionField.font = .headline4
        placeholderOfDescriptionField.translatesAutoresizingMaskIntoConstraints = false
        
        descriptionOfTaskTextView.addSubview(placeholderOfDescriptionField)
        
        NSLayoutConstraint.activate([
            placeholderOfDescriptionField.topAnchor.constraint(equalTo: descriptionOfTaskTextView.topAnchor, constant: 8),
            placeholderOfDescriptionField.leadingAnchor.constraint(equalTo: descriptionOfTaskTextView.leadingAnchor),
            placeholderOfDescriptionField.trailingAnchor.constraint(equalTo: descriptionOfTaskTextView.trailingAnchor, constant: -5)
        ])
        
        descriptionOfTaskTextView.translatesAutoresizingMaskIntoConstraints = false
        
        return descriptionOfTaskTextView
    }()
    
    private let createButton: UIButton = {
        let createButton = UIButton(type: .system)
        let textOfCreateButton = NSLocalizedString("task.createButton.title", comment: "")
        
        createButton.setTitle(textOfCreateButton, for: .normal)
        createButton.setTitleColor(.whiteForText, for: .normal)
        createButton.titleLabel?.font = .headline3
        createButton.contentHorizontalAlignment = .center
        createButton.backgroundColor = .grayForCreateButton
        createButton.layer.cornerRadius = 16
        createButton.isEnabled = false
        createButton.isHidden = true
        createButton.translatesAutoresizingMaskIntoConstraints = false
        
        return createButton
    }()
    
    // MARK: - Initialization
    
    init(viewModel: TaskViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        nil
    }
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .forViewBackground
        
        addTargetsToUIViews()
        addSubviews()
        showNeedViewsByMode()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.tintColor = .yellowForButtons
        navigationController?.navigationBar.prefersLargeTitles = false
    }
    
    // MARK: - Actions
    
    @objc private func createButtonClicked() {
        let textOfButtonOnErrorAlert = NSLocalizedString("task.errorAlert.buttonText", comment: "")
        let titleOfErrorAlert = NSLocalizedString("task.errorAlert.title", comment: "")
        
        switch viewModel.taskMode {
        case .add:
            let task = SingleTask(
                id: viewModel.newTaskId,
                name: titleOfTaskTextField.text ?? "",
                descriptionText: descriptionOfTaskTextView.text ?? "",
                status: false,
                date: Date())
            
            onCreate?(task) { [weak self] result in
                switch result {
                case .success(_):
                    self?.navigationController?.popViewController(animated: true)
                case .failure(_):
                    let messageOfErrorAlert = NSLocalizedString("task.errorAlert.message.onCreate", comment: "")
                    
                    self?.showDuplicateAlert(
                        titleOfErrorAlert: titleOfErrorAlert,
                        messageOfErrorAlert: messageOfErrorAlert,
                        textOfButtonOnErrorAlert: textOfButtonOnErrorAlert)
                }
            }
            
        case .edit(let task):
            let updatedTask = SingleTask(
                id: task.id,
                name: titleOfTaskTextField.text ?? "",
                descriptionText: descriptionOfTaskTextView.text ?? "",
                status: task.status,
                date: task.date)
            
            onEdit?(updatedTask)
            self.navigationController?.popViewController(animated: true)
        }
    }
    
    // MARK: - UI State
    
    private func showNeedViewsByMode() {
        switch viewModel.taskMode {
        case .add:
            titleOfTaskTextField.text = ""
            descriptionOfTaskTextView.text = ""
            dateOfTaskLabel.text = Constants.dayMonthYear.string(from: Date())
            
            createButton.isHidden = false
            updateCreateButtonState()
            
        case .edit(let task):
            let textForSaveButton = NSLocalizedString("task.saveButton.title", comment: "")
            
            titleOfTaskTextField.text = task.name
            descriptionOfTaskTextView.text = task.descriptionText
            dateOfTaskLabel.text = Constants.dayMonthYear.string(from: task.date)
            
            createButton.isHidden = false
            createButton.setTitle(textForSaveButton, for: .normal)
            
            viewModel.isDescriptionFieldFilled = !task.descriptionText.isEmpty
            placeholderOfDescriptionField.isHidden = !task.descriptionText.isEmpty
            viewModel.isTitleFieldFilled = true
            
            updateCreateButtonState()
        }
    }
    
    // MARK: - Layout
    
    private func addTargetsToUIViews() {
        titleOfTaskTextField.addTarget(self, action: #selector(textFieldDidChange), for: .editingChanged)
        createButton.addTarget(self, action: #selector(createButtonClicked), for: .touchUpInside)
    }
    
    private func addSubviews() {
        [titleOfTaskTextField, dateOfTaskLabel, descriptionOfTaskTextView, createButton].forEach {
            view.addSubview($0)
        }
        
        setupConstraints()
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            titleOfTaskTextField.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 8),
            titleOfTaskTextField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            titleOfTaskTextField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            titleOfTaskTextField.heightAnchor.constraint(equalToConstant: 41),
            
            dateOfTaskLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            dateOfTaskLabel.widthAnchor.constraint(equalToConstant: 160),
            dateOfTaskLabel.heightAnchor.constraint(equalToConstant: 16),
            dateOfTaskLabel.topAnchor.constraint(equalTo: titleOfTaskTextField.bottomAnchor, constant: 8),
            
            descriptionOfTaskTextView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            descriptionOfTaskTextView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            descriptionOfTaskTextView.topAnchor.constraint(equalTo: dateOfTaskLabel.bottomAnchor, constant: 16),
            descriptionOfTaskTextView.heightAnchor.constraint(equalToConstant: 66),
            
            createButton.topAnchor.constraint(equalTo: descriptionOfTaskTextView.bottomAnchor, constant: 40),
            createButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            createButton.heightAnchor.constraint(equalToConstant: 40),
            createButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20)
        ])
    }
    
    // MARK: - Button State
    
    private func updateCreateButtonState() {
        let shouldBeActive = viewModel.isTitleFieldFilled && viewModel.isDescriptionFieldFilled
        
        createButton.isEnabled = shouldBeActive
        UIView.animate(withDuration: 0.3) {
            if shouldBeActive {
                self.createButton.backgroundColor = .yellowForButtons.withAlphaComponent(0.8)
                self.createButton.isEnabled = true
            } else {
                self.createButton.backgroundColor = .grayForCreateButton
            }
        }
    }
    
    // MARK: - Alerts
    
    private func showDuplicateAlert(
        titleOfErrorAlert: String,
        messageOfErrorAlert: String,
        textOfButtonOnErrorAlert: String
    ) {
        let alert = UIAlertController(
            title: titleOfErrorAlert,
            message: messageOfErrorAlert,
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: textOfButtonOnErrorAlert, style: .default))
        present(alert, animated: true)
    }
}

// MARK: - UITextFieldDelegate

extension TaskViewController: UITextFieldDelegate {
    
    @objc private func textFieldDidChange(_ textField: UITextField) {
        viewModel.isTitleFieldFilled =
        !(textField.text?
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .isEmpty ?? true)
        
        updateCreateButtonState()
    }
}

// MARK: - UITextViewDelegate

extension TaskViewController: UITextViewDelegate {
    
    func textViewDidChange(_ textView: UITextView) {
        let trimmedText = textView.text
            .trimmingCharacters(in: .whitespacesAndNewlines)
        
        viewModel.isDescriptionFieldFilled = !trimmedText.isEmpty
        placeholderOfDescriptionField.isHidden = !trimmedText.isEmpty
        
        updateCreateButtonState()
    }
}
