//
//  ProfilePopupViewController.swift
//  Cypher
//
//  Created by Nkhorbaladze on 15.01.25.
//

import UIKit
import SwiftUI

final class ProfilePopupViewController: UIViewController {
    private let blurEffectService: BlurEffectService
    private let viewModel: ProfilePopupViewModel
    weak var delegate: ProfilePopupViewControllerDelegate?
    
    // MARK: - UI Elements
    private lazy var logoutButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setImage(UIImage(systemName: "iphone.and.arrow.right.outward"), for: .normal)
        button.tintColor = UIColor(named: AppColors.lightGrey.rawValue)
        button.heightAnchor.constraint(equalToConstant: 20).isActive = true
        button.widthAnchor.constraint(equalToConstant: 20).isActive = true
        button.addAction(UIAction(handler: { [weak self] _ in
            self?.logoutTapped()
        }), for: .touchUpInside)
        
        return button
    }()
    
    private lazy var closeButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setImage(UIImage(systemName: "xmark"), for: .normal)
        button.tintColor = UIColor(named: AppColors.lightGrey.rawValue)
        button.heightAnchor.constraint(equalToConstant: 20).isActive = true
        button.widthAnchor.constraint(equalToConstant: 20).isActive = true
        button.addAction(UIAction(handler: { [weak self] _ in
            self?.closeButtonTapped()
        }), for: .touchUpInside)
        
        return button
    }()
    
    private lazy var profileCicle: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = UIColor(named: AppColors.accent.rawValue)
        view.widthAnchor.constraint(equalToConstant: 95).isActive = true
        view.heightAnchor.constraint(equalToConstant: 95).isActive = true
        
        return view
    }()
    
    private lazy var userLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = Fonts.semiBold.uiFont(size: 24)
        label.text = "User"
        label.textColor = UIColor(named: AppColors.white.rawValue)
        
        return label
    }()
    
    private lazy var editProfileButton: UIHostingController<PrimaryButton> = {
        let hostingController = UIHostingController(
            rootView: PrimaryButton(
                title: "Edit Profile",
                isActive: true,
                action: { [weak self] in
                    self?.navigateToManageProfile()
                }
            )
        )
        hostingController.view.translatesAutoresizingMaskIntoConstraints = false
        hostingController.view.backgroundColor = .clear
        return hostingController
    }()
    
    // MARK: - Initializers
    init(blurEffectService: BlurEffectService = BlurEffectService(), viewModel: ProfilePopupViewModel) {
        self.blurEffectService = blurEffectService
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
        navigationController?.setNavigationBarHidden(true, animated: true)
        
        Task {
            await fetchUsername()
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        profileCicle.layer.cornerRadius = profileCicle.frame.width / 2
        profileCicle.clipsToBounds = true
    }
    
    // MARK: - UI Setup
    func setup() {
        view.backgroundColor = UIColor(named: AppColors.backgroundColor.rawValue)
        setupUI()
        setupConstraints()
    }
    
    func setupUI() {
        view.addSubview(closeButton)
        view.addSubview(logoutButton)
        view.addSubview(profileCicle)
        view.addSubview(userLabel)
        
        addChild(editProfileButton)
        view.addSubview(editProfileButton.view)
        editProfileButton.didMove(toParent: self)
    }
    
    func setupConstraints() {
        NSLayoutConstraint.activate([
            logoutButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            logoutButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            
            closeButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            closeButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            closeButton.centerYAnchor.constraint(equalTo: logoutButton.centerYAnchor)
        ])
        
        NSLayoutConstraint.activate([
            profileCicle.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 50),
            profileCicle.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            userLabel.topAnchor.constraint(equalTo: profileCicle.bottomAnchor, constant: 17),
            userLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            editProfileButton.view.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20),
            editProfileButton.view.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 24),
            editProfileButton.view.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -24),
            editProfileButton.view.heightAnchor.constraint(equalToConstant: 50)
        ])
    }
    
    // MARK: - Functions
    private func closeButtonTapped() {
        blurEffectService.removeBlurEffect()
        dismiss(animated: true)
    }
    
    private func logoutTapped() {
        blurEffectService.removeBlurEffect()
        viewModel.logout { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success:
                    self?.handleSuccessfulLogout()
                case .failure(_):
                    self?.showErrorAlert(message: "Logout Failed. Try again later.")
                }
            }
            
        }
    }
    
    private func handleSuccessfulLogout() {
        NavigationService.shared.switchToAuth()
    }
    
    private func navigateToManageProfile() {
        blurEffectService.removeBlurEffect()
        dismiss(animated: true) { [weak self] in
            self?.delegate?.didTapEditProfile() 
        }
    }
    
    private func fetchUsername() async {
        do {
            if let username = try await viewModel.getUsername() {
                DispatchQueue.main.async {
                    self.userLabel.text = username
                }
            }
        } catch {
            print("Failed to fetch username: \(error.localizedDescription)")
        }
    }
}

// MARK: - Extensions
extension ProfilePopupViewController: UISheetPresentationControllerDelegate {
    func presentationControllerDidDismiss(_ presentationController: UIPresentationController) {
        blurEffectService.removeBlurEffect()
    }
}
