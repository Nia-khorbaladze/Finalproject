//
//  ManageProfileViewController.swift
//  Cypher
//
//  Created by Nkhorbaladze on 01.02.25.
//

import UIKit

final class ManageProfileViewController: UIViewController {
    // MARK: - UI Elements
    private lazy var headerView: HeaderView = {
        let header = HeaderView(title: "Manage Profile")
        header.translatesAutoresizingMaskIntoConstraints = false
        header.onBackButtonTapped = { [weak self] in
            self?.navigateBack()
        }
        return header
    }()
    
    private lazy var profileCicle: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = UIColor(named: AppColors.accent.rawValue)
        view.widthAnchor.constraint(equalToConstant: 95).isActive = true
        view.heightAnchor.constraint(equalToConstant: 95).isActive = true
        
        return view
    }()
    
    private lazy var usernameContainer: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = UIColor(named: AppColors.greyBlue.rawValue)
        view.layer.cornerRadius = 25
        
        return view
    }()
    
    private lazy var usernameLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = Fonts.medium.uiFont(size: 18)
        label.textColor = UIColor(named: AppColors.white.rawValue)
        label.text = "Username"
        
        return label
    }()
    
    private lazy var usernameButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setImage(UIImage(systemName: "chevron.right"), for: .normal)
        button.tintColor = UIColor(named: AppColors.white.rawValue)
        button.heightAnchor.constraint(equalToConstant: 20).isActive = true
        button.addAction(UIAction(handler: { [weak self] _ in
            self?.navigateToUsernameCreationPage()
        }), for: .touchUpInside)
        
        return button
    }()
    
    private lazy var aboutLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = Fonts.semiBold.uiFont(size: 18)
        label.textColor = UIColor(named: AppColors.lightGrey.rawValue)
        label.text = "About"
        
        return label
    }()
    
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        profileCicle.layer.cornerRadius = profileCicle.frame.width / 2
        profileCicle.clipsToBounds = true
    }
    
    // MARK: - UI Setup
    private func setup() {
        view.backgroundColor = UIColor(named: AppColors.backgroundColor.rawValue)
        setupUI()
        setupConstraints()
    }
    
    private func setupUI() {
        view.addSubview(headerView)
        view.addSubview(profileCicle)
        view.addSubview(usernameContainer)
        usernameContainer.addSubview(usernameLabel)
        usernameContainer.addSubview(usernameButton)
        view.addSubview(aboutLabel)
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            headerView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            headerView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            headerView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            headerView.heightAnchor.constraint(equalToConstant: 55)
        ])
        
        NSLayoutConstraint.activate([
            profileCicle.topAnchor.constraint(equalTo: headerView.bottomAnchor, constant: 35),
            profileCicle.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            usernameContainer.topAnchor.constraint(equalTo: profileCicle.bottomAnchor, constant: 80),
            usernameContainer.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 13),
            usernameContainer.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -13),
            usernameContainer.heightAnchor.constraint(equalToConstant: 60),
            
            usernameLabel.leadingAnchor.constraint(equalTo: usernameContainer.leadingAnchor, constant: 20),
            usernameLabel.centerYAnchor.constraint(equalTo: usernameContainer.centerYAnchor),
            
            usernameButton.centerYAnchor.constraint(equalTo: usernameLabel.centerYAnchor),
            usernameButton.trailingAnchor.constraint(equalTo: usernameContainer.trailingAnchor, constant: -20),
            
            aboutLabel.bottomAnchor.constraint(equalTo: usernameContainer.topAnchor, constant: -15),
            aboutLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 15)
        ])
    }
    
    // MARK: - Functions
    private func navigateBack() {
        navigationController?.popViewController(animated: true)
    }
    
    private func navigateToUsernameCreationPage() {
        let viewModel = Dependencies.shared.makeCreateUsernameViewModel()
        let viewController = CreateUsernameViewController(viewModel: viewModel)
        navigationController?.pushViewController(viewController, animated: true)
    }
}
