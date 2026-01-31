import UIKit

final class TaskTableViewCell: UITableViewCell {
    
    var onCompletionTask: (() -> Void)?
    
    static let reusedIdentifier = "TaskTableViewCell"
    
    private lazy var completionButton: UIButton = {
        let completionButton = UIButton(type: .system)
        completionButton.addTarget(self, action: #selector(completionButtonClicked), for: .touchUpInside)
        completionButton.translatesAutoresizingMaskIntoConstraints = false
        
        return completionButton
    }()
    private lazy var titleOfTaskLabel: UILabel = {
        let titleOfTaskLabel = UILabel()
        titleOfTaskLabel.font = .headline3
        titleOfTaskLabel.translatesAutoresizingMaskIntoConstraints = false
        
        return titleOfTaskLabel
    }()
    private lazy var descriptionOfTaskLabel: UILabel = {
        let descriptionOfTaskLabel = UILabel()
        descriptionOfTaskLabel.font = .headline5
        descriptionOfTaskLabel.numberOfLines = 2
        descriptionOfTaskLabel.translatesAutoresizingMaskIntoConstraints = false
        
        return descriptionOfTaskLabel
    }()
    private lazy var dateOfTaskLabel: UILabel = {
        let dateOfTaskLabel = UILabel()
        dateOfTaskLabel.font = .headline5
        dateOfTaskLabel.textColor = .semiLightWhiteForText
        dateOfTaskLabel.translatesAutoresizingMaskIntoConstraints = false
        
        return dateOfTaskLabel
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: .default, reuseIdentifier: reuseIdentifier)
        contentView.backgroundColor = .forViewBackground
        
        separatorInset = .zero
        layoutMargins = .zero
        preservesSuperviewLayoutMargins = false
        
        addSubviews()
    }
    
    required init?(coder: NSCoder) {
        nil
    }
    
    func configure(task: SingleTask) {
        descriptionOfTaskLabel.text = task.descriptionText
        dateOfTaskLabel.text = Constants.dayMonthYear.string(from: task.date)
        
        if task.status {
            completionButton.setImage(UIImage(resource: .taskCompleted), for: .normal)
            completionButton.tintColor = .yellowForButtons
            
            titleOfTaskLabel.attributedText = NSAttributedString(
                string: task.name,
                attributes: Constants.attributesWithStrikethrough)
            
            descriptionOfTaskLabel.textColor = .semiLightWhiteForText
        } else {
            completionButton.setImage(UIImage(resource: .taskUncompleted), for: .normal)
            completionButton.tintColor = .grayForUnselectedButtons
            
            titleOfTaskLabel.attributedText = NSAttributedString(
                string: task.name,
                attributes: Constants.attributesWithoutStrikethrough)
            
            descriptionOfTaskLabel.textColor = .whiteForText
        }
    }
    
    @objc private func completionButtonClicked() {
        onCompletionTask?()
    }
    
    private func addSubviews() {
        [completionButton, titleOfTaskLabel, descriptionOfTaskLabel, dateOfTaskLabel].forEach {
            contentView.addSubview($0)
        }
        
        setupConstraints()
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            completionButton.widthAnchor.constraint(equalToConstant: 24),
            completionButton.heightAnchor.constraint(equalToConstant: 48),
            completionButton.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            completionButton.topAnchor.constraint(equalTo: contentView.topAnchor),
            
            titleOfTaskLabel.leadingAnchor.constraint(equalTo: completionButton.trailingAnchor, constant: 8),
            titleOfTaskLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 12),
            titleOfTaskLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            titleOfTaskLabel.heightAnchor.constraint(equalToConstant: 22),
            
            descriptionOfTaskLabel.topAnchor.constraint(equalTo: titleOfTaskLabel.bottomAnchor, constant: 6),
            descriptionOfTaskLabel.leadingAnchor.constraint(equalTo: completionButton.trailingAnchor, constant: 8),
            descriptionOfTaskLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            
            dateOfTaskLabel.topAnchor.constraint(equalTo: descriptionOfTaskLabel.bottomAnchor, constant: 6),
            dateOfTaskLabel.leadingAnchor.constraint(equalTo: completionButton.trailingAnchor, constant: 8),
            dateOfTaskLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            dateOfTaskLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -12)
        ])
    }
}
