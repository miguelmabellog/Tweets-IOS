//
//  WelcomeViewController.swift
//  PlatziTweets
//
//  Created by Luis Carlos Mejia Garcia on 21/01/20.
//  Copyright © 2020 Mejia Garcia. All rights reserved.
//

import UIKit

class WelcomeViewController: UIViewController {
    // MARK: - Outlets
    @IBOutlet weak var loginButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setupUI()
    }
    
    private func setupUI() {
        loginButton.layer.cornerRadius = 25
    }
}
