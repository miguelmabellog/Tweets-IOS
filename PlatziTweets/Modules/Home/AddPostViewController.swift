//
//  AddPostViewController.swift
//  PlatziTweets
//
//  Created by Brian Baragar on 15/04/20.
//  Copyright © 2020 Mejia Garcia. All rights reserved.
//

import UIKit
import Simple_Networking
import SVProgressHUD
import NotificationBannerSwift
import FirebaseStorage
import AVFoundation
import AVKit
import MobileCoreServices
import CoreLocation

class AddPostViewController: UIViewController {
    @IBOutlet weak var postTextView: UITextView!
    @IBOutlet weak var previewImageView: UIImageView!
    @IBOutlet weak var VideoButton: UIButton!
    
    //MARK: - Propierties
    private var imagePicker : UIImagePickerController?
    private var currentVideoUrl: URL?
    private var locationManager: CLLocationManager?
    private var userLocation: CLLocation?
    
    @IBAction func addPostAction(){
        //l
        //uploadPhotoToFirebase()
        uploadvideoToFirebase()
        //openvideocamera()
    }
    
    @IBAction func openPreviewAction() {
        guard let currentVideoURL = currentVideoUrl else {
            return
        }
        let avplayer = AVPlayer(url: currentVideoURL)
        let avPlayerController = AVPlayerViewController()
        avPlayerController.player = avplayer
        present(avPlayerController, animated: true){
            avPlayerController.player?.play()
        }
    }
    @IBAction func dismissAction(){
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func openCameraAction(_ sender: UIButton) {
        let alert = UIAlertController(
            title: "Camara", message:
            "Selecciona una opcion",
            preferredStyle: .actionSheet)
        alert.addAction(UIAlertAction(title: "Foto", style: .default, handler: { (_) in
            self.opencamera()
        }))
        alert.addAction(UIAlertAction(title: "Video", style: .default, handler: { (_) in
            self.openvideocamera()
        }))
        alert.addAction(UIAlertAction(title: "Cancelar", style: .destructive, handler:nil))
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        VideoButton.isHidden = true
        requestLocation()
        // Do any additional setup after loading the view.
    }
    
    private func requestLocation(){
        guard CLLocationManager.locationServicesEnabled() else {
            return
        }
        locationManager = CLLocationManager()
        locationManager?.delegate = self
        locationManager?.desiredAccuracy = kCLLocationAccuracyBest
        locationManager?.requestAlwaysAuthorization()
        locationManager?.startUpdatingLocation()
    }

    private func openvideocamera(){
        imagePicker = UIImagePickerController()
        imagePicker?.sourceType = .camera
        imagePicker?.mediaTypes = [kUTTypeMovie as String]
        imagePicker?.cameraFlashMode = .off
        imagePicker?.cameraCaptureMode = .video
        imagePicker?.videoQuality = .typeMedium
        imagePicker?.videoMaximumDuration = TimeInterval(5)
        imagePicker?.allowsEditing = true
        imagePicker?.delegate = self
        
        guard let imagePicker = imagePicker else {
            return
        }
        present(imagePicker, animated: true, completion: nil)
    }
    
    private func opencamera(){
        imagePicker = UIImagePickerController()
        imagePicker?.sourceType = .camera
        imagePicker?.cameraFlashMode = .off
        imagePicker?.cameraCaptureMode = .photo
        imagePicker?.allowsEditing = true
        imagePicker?.delegate = self
        
        guard let imagePicker = imagePicker else {
            return
        }
        present(imagePicker, animated: true, completion: nil)
    }
    private func uploadvideoToFirebase(){
        //1. Asegurarnos que la foto exista
        guard
            let currentVideoSaveUrl = currentVideoUrl,
            let videoData: Data = try? Data(contentsOf: currentVideoSaveUrl)else{
            //2. Comprimir la imagen y convertirla en Data
            return
        }
        SVProgressHUD.show()
        //Guardar la foto en firebase
        let metadataConfig = StorageMetadata()
        metadataConfig.contentType = "video/mp4"
        //Crear una referencia al storage de firebase
        let storage = Storage.storage()
        //Nombre de la imagen a subir
        let videoName = Int.random(in: 100...1000)
        //Referencia a la carpeta donde se va a guardar la foto
        let folderReference = storage.reference(withPath:"video-tweets/\(videoName).mp4")
        //Subir video a firebase
        DispatchQueue.global(qos: .background).async {
            folderReference.putData(videoData, metadata: metadataConfig) { (metadata: StorageMetadata?, error: Error?) in
                DispatchQueue.main.async {
                    //detener la carga
                    SVProgressHUD.dismiss()
                    if let error = error{
                        NotificationBanner(title: "Error", subtitle: error.localizedDescription, style: .warning).show()
                        return
                    }
                    folderReference.downloadURL { (url: URL?, error:Error?) in
                        let dowloadUrl = url?.absoluteString ?? ""
                        self.savePost(imageurl: nil, videoUrl: dowloadUrl)
                    }
                }
            }
        }
    }
    private func uploadPhotoToFirebase(){
        //1. Asegurarnos que la foto exista
        guard
            let imageSaved = previewImageView.image,
            //2. Comprimir la imagen y convertirla en Data
            let imageSavedData:Data = imageSaved.jpegData(compressionQuality: 0.1) else {
            return
        }
        SVProgressHUD.show()
        //Guardar la foto en firebase
        let metadataConfig = StorageMetadata()
        metadataConfig.contentType = "image/jpg"
        //Crear una referencia al storage de firebase
        let storage = Storage.storage()
        //Nombre de la imagen a subir
        let imageName = Int.random(in: 100...1000)
        //Referencia a la carpeta donde se va a guardar la foto
        let folderReference = storage.reference(withPath:"fotos-tweets/\(imageName).jpg")
        //Subir foto a firebase
        DispatchQueue.global(qos: .background).async {
            folderReference.putData(imageSavedData, metadata: metadataConfig) { (metadata: StorageMetadata?, error: Error?) in
                DispatchQueue.main.async {
                    //detener la carga
                    SVProgressHUD.dismiss()
                    if let error = error{
                        NotificationBanner(title: "Error", subtitle: error.localizedDescription, style: .warning).show()
                        return
                    }
                    folderReference.downloadURL { (url: URL?, error:Error?) in
                        let dowloadUrl = url?.absoluteString ?? ""
                        self.savePost(imageurl: dowloadUrl, videoUrl: nil)
                    }
                }
            }
        }
    }
    
    private func savePost(imageurl: String?, videoUrl: String?){
        guard let post = postTextView.text ,  !post.isEmpty else {
            return
        }
        let request = PostRequest(text: post, imageUrl: imageurl, videoUrl: videoUrl, location: nil)
        
        SVProgressHUD.show()
        SN.post(endpoint: Endpoints.post, model: request) { (response: SNResultWithEntity<Post, ErrorResponse>) in
            SVProgressHUD.dismiss()
            switch response {
            case .success:
                self.dismiss(animated: true, completion: nil)
            case .error(let error):
                NotificationBanner(title: "Error", subtitle: "A ocurrido un error inesperado", style: .danger).show()
                // todo lo malo :(
            case .errorResult(let entity):
                NotificationBanner(title: "Error", subtitle: "A ocurrido un error en el servidor", style: .warning).show()
                // error pero no tan malo :)
            }
        }
    }
}
extension AddPostViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate{
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        //Cerrar Camara
        imagePicker?.dismiss(animated: true, completion: nil)
        //Capturar Imagen
        if info.keys.contains(.originalImage){
            previewImageView.isHidden = false
            //Obtener la imagen tomada
            previewImageView.image = info[.originalImage] as? UIImage
        }
        if info.keys.contains(.mediaURL), let recordedVideoUrl = (info[.mediaURL] as? URL)?.absoluteURL{
            VideoButton.isHidden = false
            currentVideoUrl = recordedVideoUrl
        }
    }
}
extension AddPostViewController: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let bestLocation = locations.last else {
            return
        }
        //La ubicacion ya la tenemos en este punto
        userLocation = bestLocation
    }
}
