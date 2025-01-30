//
//  EnterSendAmountViewController.swift
//  Cypher
//
//  Created by Nkhorbaladze on 30.01.25.
//

import UIKit

final class EnterSendAmountViewController: UIViewController {
    private let coinSymbol: String
    private let walletAddress: String
    private let viewModel: EnterSendAmountViewModel
    private var availableContainerBottomConstraint: NSLayoutConstraint!
    
    // MARK: - UI Elements
    private lazy var headerView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = UIColor(named: AppColors.darkGrey.rawValue)
        
        return view
    }()
    
    private lazy var backButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setImage(UIImage(systemName: "chevron.left"), for: .normal)
        button.tintColor = UIColor(named: AppColors.white.rawValue)
        button.addAction(UIAction(handler: { [weak self] _ in
            self?.navigateBack()
        }), for: .touchUpInside)
        
        return button
    }()
    
    private lazy var headerTitle: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = UIColor(named: AppColors.white.rawValue)
        label.font = Fonts.medium.uiFont(size: 18)
        label.text = "Enter Amount"
        
        return label
    }()
    
    private lazy var nextButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("Next", for: .normal)
        button.setTitleColor(UIColor(named: AppColors.lightGrey.rawValue), for: .normal)
        button.isEnabled = false
        button.titleLabel?.font = Fonts.semiBold.uiFont(size: 18)
        
        return button
    }()
    
    private lazy var amountField: UITextField = {
        let textfield = UITextField()
        textfield.translatesAutoresizingMaskIntoConstraints = false
        textfield.font = Fonts.bold.uiFont(size: 48)
        textfield.textColor = UIColor(named: AppColors.white.rawValue)
        textfield.keyboardType = .decimalPad
        textfield.textAlignment = .center
        textfield.tintColor = .clear
        textfield.delegate = self
        textfield.text = "0"
        
        return textfield
    }()
    
    private lazy var availableContainer: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        
        return view
    }()
    
    private lazy var availableToSendLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "Available to send"
        label.font = Fonts.medium.uiFont(size: 14)
        label.textColor = UIColor(named: AppColors.lightGrey.rawValue)
        
        return label
    }()
    
    private lazy var availableCoins: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = Fonts.medium.uiFont(size: 18)
        label.textColor = UIColor(named: AppColors.white.rawValue)
        label.text = "0 \(coinSymbol)"
        
        return label
    }()
    
    private lazy var maxButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("Max", for: .normal)
        button.backgroundColor = UIColor(named: AppColors.darkGrey.rawValue)
        button.layer.cornerRadius = 20
        button.layer.masksToBounds = true
        
        return button
    }()
    
    private lazy var bottomLine: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = UIColor(named: AppColors.lightGrey.rawValue)
        view.heightAnchor.constraint(equalToConstant: 1).isActive = true
        
        return view
    }()
    
    // MARK: - Initializers
    init(coinSymbol: String, walletAddress: String, viewModel: EnterSendAmountViewModel) {
        self.coinSymbol = coinSymbol
        self.walletAddress = walletAddress
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
        updateUI()
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    // MARK: - UI Setup
    private func setup() {
        view.backgroundColor = UIColor(named: AppColors.backgroundColor.rawValue)
        setupUI()
        setupConstraints()
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        view.addGestureRecognizer(tapGesture)
    }
    
    private func setupUI() {
        view.addSubview(headerView)
        headerView.addSubview(backButton)
        headerView.addSubview(headerTitle)
        headerView.addSubview(nextButton)
        view.addSubview(amountField)
        view.addSubview(availableContainer)
        availableContainer.addSubview(availableToSendLabel)
        availableContainer.addSubview(availableCoins)
        view.addSubview(maxButton)
        view.addSubview(bottomLine)
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            headerView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            headerView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            headerView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            
            backButton.leadingAnchor.constraint(equalTo: headerView.leadingAnchor, constant: 13),
            backButton.topAnchor.constraint(equalTo: headerView.topAnchor, constant: 13),
            backButton.bottomAnchor.constraint(equalTo: headerView.bottomAnchor, constant: -13),
            
            headerTitle.centerXAnchor.constraint(equalTo: headerView.centerXAnchor),
            headerTitle.centerYAnchor.constraint(equalTo: headerView.centerYAnchor),
            
            nextButton.centerYAnchor.constraint(equalTo: headerTitle.centerYAnchor),
            nextButton.trailingAnchor.constraint(equalTo: headerView.trailingAnchor, constant: -13)
        ])
        
        NSLayoutConstraint.activate([
            amountField.topAnchor.constraint(equalTo: headerView.bottomAnchor, constant: 40),
            amountField.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            amountField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            amountField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20)
        ])
        
        availableContainerBottomConstraint = availableContainer.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -5)
            
            NSLayoutConstraint.activate([
                availableContainer.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
                availableContainer.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
                availableContainerBottomConstraint,
                availableContainer.heightAnchor.constraint(equalToConstant: 60),
                
                availableToSendLabel.topAnchor.constraint(equalTo: availableContainer.topAnchor),
                availableToSendLabel.leadingAnchor.constraint(equalTo: availableContainer.leadingAnchor),
                
                availableCoins.topAnchor.constraint(equalTo: availableToSendLabel.bottomAnchor, constant: 5),
                availableCoins.leadingAnchor.constraint(equalTo: availableContainer.leadingAnchor),
                
                maxButton.trailingAnchor.constraint(equalTo: availableContainer.trailingAnchor),
                maxButton.topAnchor.constraint(equalTo: availableToSendLabel.topAnchor),
                maxButton.widthAnchor.constraint(equalToConstant: 60),
                maxButton.heightAnchor.constraint(equalToConstant: 40),
                
                bottomLine.leadingAnchor.constraint(equalTo: view.leadingAnchor),
                bottomLine.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            bottomLine.bottomAnchor.constraint(equalTo: availableContainer.topAnchor, constant: -10),
            bottomLine.heightAnchor.constraint(equalToConstant: 1)
        ])

    }
    
    // MARK: - Functions
    private func navigateBack() {
        navigationController?.popViewController(animated: true)
    }
    
    private func updateUI() {

    }
    
    @objc private func keyboardWillShow(notification: NSNotification) {
        guard let userInfo = notification.userInfo,
              let keyboardFrame = userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect else {
            return
        }
        
        let keyboardFrameInView = view.convert(keyboardFrame, from: nil)
        let keyboardTop = keyboardFrameInView.minY
        let safeAreaBottom = view.safeAreaLayoutGuide.layoutFrame.maxY
        let offset = safeAreaBottom - keyboardTop
        
        availableContainerBottomConstraint.constant = -offset
        UIView.animate(withDuration: 0.3) {
            self.view.layoutIfNeeded()
        }
    }
    @objc private func keyboardWillHide(notification: NSNotification) {
        availableContainerBottomConstraint.constant = -5
        UIView.animate(withDuration: 0.3) {
            self.view.layoutIfNeeded()
        }
    }
    
    @objc private func dismissKeyboard() {
        view.endEditing(true)
    }
    
}

// MARK: - Extensions
extension EnterSendAmountViewController: UITextFieldDelegate {

}


