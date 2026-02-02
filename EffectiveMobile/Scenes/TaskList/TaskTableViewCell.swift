import UIKit

enum ContextMenuAction {
    case edit
    case share
    case delete
}

final class TaskTableViewCell: UITableViewCell, UIContextMenuInteractionDelegate {
    
    var onCompletionTask: (() -> Void)?
    var menuHandler: ((ContextMenuAction) -> Void)?
    
    static let reusedIdentifier = "TaskTableViewCell"
    
    private lazy var completionButton: UIButton = {
        let completionButton = UIButton(type: .system)
        completionButton.addTarget(self, action: #selector(completionButtonClicked), for: .touchUpInside)
        completionButton.translatesAutoresizingMaskIntoConstraints = false
        
        return completionButton
    }()
    private lazy var viewForContextMenu: UIView = {
        let viewForContextMenu = UIView()
        viewForContextMenu.backgroundColor = .forViewBackground
        
        let interaction = UIContextMenuInteraction(delegate: self)
        viewForContextMenu.addInteraction(interaction)
        
        viewForContextMenu.translatesAutoresizingMaskIntoConstraints = false
        
        return viewForContextMenu
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
    
    func contextMenuInteraction(_ interaction: UIContextMenuInteraction, configurationForMenuAtLocation location: CGPoint) -> UIContextMenuConfiguration? {
        
        let textOfEditSection = NSLocalizedString("contextMenu.editSection.text", comment: "")
        let textOfEditDeleteSection = NSLocalizedString("contextMenu.deleteSection.text", comment: "")
        let textOfShareSection = NSLocalizedString("contextMenu.shareSection.text", comment: "")
        
        return UIContextMenuConfiguration(identifier: nil, previewProvider: nil) { [weak self] _ in
            guard let self else { return nil }
            return UIMenu(children: [
                UIAction(title: textOfEditSection,
                         image: UIImage(resource: .editInContextMenu)) { _ in
                    self.menuHandler?(.edit)
                },
                UIAction(title: textOfShareSection,
                         image: UIImage(resource: .shareInContextMenu)) { _ in
                    self.menuHandler?(.share)
                },
                UIAction(title: textOfEditDeleteSection,
                         image: UIImage(resource: .deleteInContextMenu),
                         attributes: [.destructive]) { _ in
                    self.menuHandler?(.delete)
                }
            ])
        }
    }
    
    @objc private func completionButtonClicked() {
        onCompletionTask?()
    }
    
    private func addSubviews() {
        [completionButton, viewForContextMenu].forEach {
            contentView.addSubview($0)
        }
        
        [titleOfTaskLabel, descriptionOfTaskLabel, dateOfTaskLabel].forEach {
            viewForContextMenu.addSubview($0)
        }
        
        setupConstraints()
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            completionButton.widthAnchor.constraint(equalToConstant: 24),
            completionButton.heightAnchor.constraint(equalToConstant: 48),
            completionButton.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            completionButton.topAnchor.constraint(equalTo: contentView.topAnchor),
            
            viewForContextMenu.topAnchor.constraint(equalTo: contentView.topAnchor),
            viewForContextMenu.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            viewForContextMenu.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            viewForContextMenu.leadingAnchor.constraint(equalTo: completionButton.trailingAnchor, constant: 8),
            
            titleOfTaskLabel.leadingAnchor.constraint(equalTo: viewForContextMenu.leadingAnchor),
            titleOfTaskLabel.topAnchor.constraint(equalTo: viewForContextMenu.topAnchor, constant: 12),
            titleOfTaskLabel.trailingAnchor.constraint(equalTo: viewForContextMenu.trailingAnchor),
            titleOfTaskLabel.heightAnchor.constraint(equalToConstant: 22),
            
            descriptionOfTaskLabel.topAnchor.constraint(equalTo: titleOfTaskLabel.bottomAnchor, constant: 6),
            descriptionOfTaskLabel.leadingAnchor.constraint(equalTo: viewForContextMenu.leadingAnchor),
            descriptionOfTaskLabel.trailingAnchor.constraint(equalTo: viewForContextMenu.trailingAnchor),
            
            dateOfTaskLabel.topAnchor.constraint(equalTo: descriptionOfTaskLabel.bottomAnchor, constant: 6),
            dateOfTaskLabel.leadingAnchor.constraint(equalTo: viewForContextMenu.leadingAnchor),
            dateOfTaskLabel.trailingAnchor.constraint(equalTo: viewForContextMenu.trailingAnchor),
            dateOfTaskLabel.bottomAnchor.constraint(equalTo: viewForContextMenu.bottomAnchor, constant: -12)
        ])
    }
}
