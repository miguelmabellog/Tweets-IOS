//
//  RegisterViewController.swift
//  PlatziTweets
//
//  Created by Luis Carlos Mejia Garcia on 21/01/20.
//  Copyright © 2020 Mejia Garcia. All rights reserved.
//

import UIKit
import NotificationBannerSwift
import Simple_Networking
import SVProgressHUD

class RegisterViewController: UIViewController {
    // MARK: - Outlets
    @IBOutlet weak var registerButton: UIButton!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var namesTextField: UITextField!
    
    // MARK: - IBActions
    @IBAction func registerButtonAction() {
        view.endEditing(true)
        performRegister()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setupUI()
    }
    
    private func setupUI() {
        registerButton.layer.cornerRadius = 25
    }
    
    private func performRegister() {
        guard let email = emailTextField.text, !email.isEmpty else {
            NotificationBanner(title: "Error", subtitle: "Debes especificar un correo.", style: .warning).show()
            
            return
        }
        
        guard let password = passwordTextField.text, !password.isEmpty else {
            NotificationBanner(title: "Error", subtitle: "Debes especificar una contraseña.", style: .warning).show()
            
            return
        }
        
        guard let names = namesTextField.text, !names.isEmpty else {
            NotificationBanner(title: "Error", subtitle: "Debes especificar tu nombre y apellido.", style: .warning).show()
            
            return
        }
        //Crear request
        let request = RegisterRequest(email: email, password: password, names: names)
        
        //Indicamos la carga
        SVProgressHUD.show()
        
        //Llamar al servicio
        SN.post(endpoint: Endpoints.register,
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
        //performSegue(withIdentifier: "showHome", sender: nil)
        
        // Registranos aquí!
    }
}
