//
//  HomeViewController.swift
//  PlatziTweets
//
//  Created by Brian Baragar on 14/04/20.
//  Copyright © 2020 Mejia Garcia. All rights reserved.
//

import UIKit
import Simple_Networking
import SVProgressHUD
import NotificationBannerSwift
import AVKit

class HomeViewController: UIViewController {

    private let cellid = "TweetTableViewCell"
    private var dataSource = [Post]()
    //MARK: -IBOutlets
    @IBOutlet weak var tableView:UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        getPost()
        setupUI()
    }
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        getPost()
    }
    private func setupUI(){
        tableView.dataSource = self
        tableView.register(UINib(nibName: cellid, bundle: nil), forCellReuseIdentifier: cellid)
        tableView.delegate = self
    }
    private func getPost(){
        SVProgressHUD.show()
        
        SN.get(endpoint: Endpoints.getPosts){ (result: SNResultWithEntity<[Post], ErrorResponse>) in
            SVProgressHUD.dismiss()
            switch result {
            case .success(let post):
                self.dataSource = post
                self.tableView.reloadData()
            case .error(let error):
                NotificationBanner(title: "Error", subtitle: "A ocurrido un error inesperado", style: .danger).show()
                // todo lo malo :(
                
            case .errorResult(let entity):
                NotificationBanner(title: "Error", subtitle: "A ocurrido un error en el servidor", style: .warning).show()
                // error pero no tan malo :)
            }
        }
    }
    
    private func deletePostAt(indexPath: IndexPath){
        SVProgressHUD.show()
        
        let postId = dataSource[indexPath.row].id
        
        //Preparamos el endpoint para consumir
        let endpoint  = Endpoints.delete + postId
        
        SN.delete(endpoint: endpoint) { (result:SNResultWithEntity<GeneralResponse, ErrorResponse>) in
            switch result {
            case .success:
                self.dataSource.remove(at: indexPath.row)
                self.tableView.deleteRows(at: [indexPath], with: UITableView.RowAnimation.left)
            case .error(let error):
                NotificationBanner(title: "Error", subtitle: "A ocurrido un error inesperado", style: .danger).show()
                           
            case .errorResult(let entity):
                NotificationBanner(title: "Error", subtitle: "A ocurrido un error en el servidor", style: .warning).show()
                       }
        }
    }
    
}
//MARK: - UITableViewDataSource
extension HomeViewController: UITableViewDelegate{
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        let deleteAction = UITableViewRowAction(style: .destructive, title: "Borrar") { (_, _) in
            //Aquí borramos el tweet
            self.deletePostAt(indexPath: indexPath)
        }
    return[deleteAction]
    }
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return dataSource[indexPath.row].author.email != "test1@test.com"
    }
}

extension HomeViewController: UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataSource.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellid, for: indexPath)
        if let cell = cell as? TweetTableViewCell {
            cell.setupCellWhit(post: dataSource[indexPath.row])
            cell.needsToShowVideo = { url in
                //Aquí si abriria el viewcontroller JAMAS EN UN CONTROLADOR DE CELDA
                let avplayer = AVPlayer(url: url)
                let avPlayerController = AVPlayerViewController()
                avPlayerController.player = avplayer
                self.present(avPlayerController, animated: true){
                    avPlayerController.player?.play()
                }
            }
        }
        return cell
    }
}
