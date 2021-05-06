//
//  ViewController.swift
//  VK
//
//  Created by Ilyas Tyumenev on 15/06/2020.
//  Copyright © 2020 Ilyas Tyumenev. All rights reserved.
//

import UIKit

class LoginController: UIViewController {
    
    // MARK: - Outlets
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var loginTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    
    // MARK: - Life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillShow),
            name: UIResponder.keyboardWillShowNotification,
            object: nil
        )
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillHide),
            name: UIResponder.keyboardWillHideNotification,
            object: nil
        )
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        NotificationCenter.default.removeObserver(LoginController.self)
    }
    
    @objc func keyboardWillShow(notification: Notification) {
        guard let kbSize = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect else { return }
        
        scrollView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: kbSize.height, right: 0)
    }
    
    @objc func keyboardWillHide(notification: Notification) {
        scrollView.contentInset = .zero
    }
    
    @IBAction func scrollTapped(_ gesture: UIGestureRecognizer) {
        scrollView.endEditing(true)
    }
    
    // MARK: - Segue to Tab Bar Controller
    @IBAction func segueToTabBarController(_ sender: Any) {
        let backgroundView = UIView()
        backgroundView.backgroundColor = UIColor.black.withAlphaComponent(0.3)
        view.addSubview(backgroundView)
        backgroundView.frame = view.bounds
        
        let loadingView = LoadingView()
        backgroundView.addSubview(loadingView)
        loadingView.center = view.center
        loadingView.startAnimation()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) { [weak self] in            
            backgroundView.removeFromSuperview()
            let isValid = self?.checkUserData() ?? false
            
            if isValid {
                let storyboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
                let tabBarController = storyboard.instantiateViewController(identifier: "tabBarController")
                self!.present(tabBarController, animated: true, completion: nil)
            } else {
                self?.showErrorAlert()
            }
        }
    }
    
    // MARK: - Check user data    
    func checkUserData() -> Bool {
        return loginTextField.text == "user" &&
            passwordTextField.text == "qwer"
    }
    
    func showErrorAlert() {
        let alert = UIAlertController(
            title: "Ошибка",
            message: "Неправильный логин или пароль",
            preferredStyle: .alert
        )
        let action = UIAlertAction(title: "OK", style: .cancel, handler: nil)
        alert.addAction(action)
        
        present(alert, animated: true, completion: nil)
    }
}
