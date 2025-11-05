import UIKit

final class NewCategoryViewController: UIViewController {
    
    var onCategorySaved: (() -> Void)?
    
    private let model = NewCategoryViewModel()
    
    private var symbols: Int = 0
    
    private enum Constants {
        static let symbolsLimit: Int = 38
    }
    
    private var showWarningAnimationStarted = false
    private var hideWarningAnimationStarted = false
    
    private let topLabel: UILabel = {
        let l = UILabel()
        l.font = .systemFont(ofSize: 16, weight: .medium)
        l.textColor = .blackDay
        l.numberOfLines = 1
        l.text = NSLocalizedString("new_category", comment: "New category header label")
        l.textAlignment = .center
        l.translatesAutoresizingMaskIntoConstraints = false
        return l
    }()
    
    private let textField: UITextField = {
        let tf = UITextField()
        tf.backgroundColor = .backgroundDay
        tf.placeholder = NSLocalizedString("category_name_placeholder", comment: "Placeholder in category name text field")
        tf.layer.cornerRadius = 16
        tf.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 16, height: 0))
        tf.leftViewMode = .always
        tf.rightView = UIView(frame: CGRect(x: 0, y: 0, width: 16, height: 0))
        tf.rightViewMode = .always
        tf.clipsToBounds = true
        tf.translatesAutoresizingMaskIntoConstraints = false
        return tf
    }()
    
    private let symbolsLimitLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 17, weight: .regular)
        label.textColor = .ypRed
        label.text = String(format: NSLocalizedString("symbols_limit", comment: "Symbols limit warning label"), Constants.symbolsLimit)
        label.textAlignment = .center
        label.isHidden = true
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let button: UIButton = {
        let b = UIButton(type: .system)
        b.backgroundColor = .blackDay
        b.layer.cornerRadius = 16
        b.clipsToBounds = true
        b.setTitle(NSLocalizedString("done", comment: "Done Button Text"), for: .normal)
        b.setTitleColor(.whiteDay, for: .normal)
        b.translatesAutoresizingMaskIntoConstraints = false
        return b
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        addActions()
        setupModel()
        setupHideKeyboardGesture()
    }
    
    // MARK: - User Actions Handlers
    
    private func doneButtonTapped() {
        guard let categoryName = textField.text else { return }
        model.saveCategory(name: categoryName)
    }
    
    // MARK: - Private Methods
    private func setupModel() {
        model.onCategorySaved = { [weak self] in
            DispatchQueue.main.async {
                self?.onCategorySaved?()
                self?.dismiss(animated: true)
            }
        }
    }
    
    private func setupUI() {
        view.backgroundColor = .whiteDay
        
        view.addSubview(topLabel)
        view.addSubview(textField)
        view.addSubview(symbolsLimitLabel)
        view.addSubview(button)
        
        NSLayoutConstraint.activate([
            topLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            topLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 24),
            
            textField.topAnchor.constraint(equalTo: topLabel.bottomAnchor, constant: 38),
            textField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            textField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            textField.heightAnchor.constraint(equalToConstant: 75),
            
            symbolsLimitLabel.topAnchor.constraint(equalTo: textField.bottomAnchor, constant: 8),
            symbolsLimitLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            button.heightAnchor.constraint(equalToConstant: 60),
            button.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16),
            button.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            button.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20)
        ])
        checkButtonConditions()
    }
    
    private func addActions() {
        textField.addAction(UIAction { [weak self] _ in
            guard let self else { return }
            self.symbols = self.textField.text?.count ?? 0
            checkButtonConditions()
            decideShowOrHideSymbolsLimitLabel()
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) { [weak self] in
                self?.decideShowOrHideSymbolsLimitLabel()
            }
        }, for: .editingChanged)
        
        button.addAction(UIAction { [weak self] _ in
            self?.doneButtonTapped()
        }, for: .touchUpInside)
    }
    
    private func checkButtonConditions() {
        let isValid = (1...Constants.symbolsLimit).contains(symbols)
        button.isUserInteractionEnabled = isValid
        button.backgroundColor = isValid ? .blackDay : .ypGray
    }
    
    
    private func decideShowOrHideSymbolsLimitLabel() {
        symbols > Constants.symbolsLimit ? showSymbolsLimitLabel() : hideSymbolsLimitLabel()
    }
    
    private func showSymbolsLimitLabel() {
        guard !showWarningAnimationStarted && symbolsLimitLabel.isHidden && !hideWarningAnimationStarted else { return }
        showWarningAnimationStarted = true
        symbolsLimitLabel.transform = CGAffineTransform(translationX: 0, y: -10)
        symbolsLimitLabel.alpha = 0
        symbolsLimitLabel.isHidden = false
        UIView.animate(withDuration: 0.3, animations: { [weak self] in
            guard let self else { return }
            self.symbolsLimitLabel.transform = .identity
            self.symbolsLimitLabel.alpha = 1
        }, completion: { [weak self] _ in
            guard let self else { return }
            self.showWarningAnimationStarted = false
        })
    }
    
    private func hideSymbolsLimitLabel() {
        guard !hideWarningAnimationStarted && !symbolsLimitLabel.isHidden && !showWarningAnimationStarted else { return }
        hideWarningAnimationStarted = true
        UIView.animate(withDuration: 0.5, animations: { [weak self] in
            guard let self else { return }
            self.symbolsLimitLabel.alpha = 0
            self.symbolsLimitLabel.transform = CGAffineTransform(translationX: 0, y: -10)
        }) { [weak self] _ in
            guard let self else { return }
            self.symbolsLimitLabel.isHidden = true
            self.symbolsLimitLabel.transform = .identity
            self.hideWarningAnimationStarted = false
        }
    }


    private func setupHideKeyboardGesture() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(hideKeyboard))
        tapGesture.cancelsTouchesInView = false
        view.addGestureRecognizer(tapGesture)
    }

    @objc private func hideKeyboard() {
        view.endEditing(true)
    }
}
