//
//  LoginViewController.swift
//  PlatziTweets
//
//  Created by Luis Carlos Mejia Garcia on 21/01/20.
//  Copyright © 2020 Mejia Garcia. All rights reserved.
//

import UIKit
import NotificationBannerSwift
import Simple_Networking
import SVProgressHUD

class LoginViewController: UIViewController {
    // MARK: - Outlets
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    
    // MARK: - IBActions
    @IBAction func loginButtonAction() {
        view.endEditing(true)
        performLogin()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setupUI()
    }
    
    // MARK: - Private Methods
    
    private func setupUI() {
        loginButton.layer.cornerRadius = 25
    }
    
    private func performLogin() {
        guard let email = emailTextField.text, !email.isEmpty else {
            NotificationBanner(title: "Error", subtitle: "Debes especificar un correo.", style: .warning).show()
            
            return
        }
        
        guard let password = passwordTextField.text, !password.isEmpty else {
            NotificationBanner(title: "Error", subtitle: "Debes especificar una contraseña.", style: .warning).show()
            
            return
        }
        
        // Crear request
        let request = LoginRequest(email: email, password: password)
        
        // Iniciamos la carga
        SVProgressHUD.show()
        
        // Llamar a librería de red
        SN.post(endpoint: Endpoints.login,
                model: request) { (response: SNResultWithEntity<LoginResponse, ErrorResponse>) in
                    
                    SVProgressHUD.dismiss()
                    
                    switch response {
                    case .success(let user):
                        self.performSegue(withIdentifier: "showHome", sender: nil)
                        SimpleNetworking.setAuthenticationHeader(prefix: "", token: user.token)
                    case .error(let error):
                        NotificationBanner(title: "Error", subtitle: "A ocurrido un error inesperado", style: .danger).show()
                        // todo lo malo :(
                        
                    case .errorResult(let entity):
                        NotificationBanner(title: "Error", subtitle: "A ocurrido un error en el servidor", style: .warning).show()
                        // error pero no tan malo :)
                    }
            
        }
        
        // performSegue(withIdentifier: "showHome", sender: nil)
        
        // Iniciar sesión aquí!
    }
}
