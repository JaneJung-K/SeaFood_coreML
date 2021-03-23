//
//  ViewController.swift
//  SeaFood
//
//  Created by mac on 2021/03/23.
//

import UIKit
import CoreML
import Vision

class ViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    @IBOutlet weak var imageView: UIImageView!
    
    let imagePicker = UIImagePickerController()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        imagePicker.delegate = self
        imagePicker.sourceType = .camera //카메라 기능을 구현할 수 있는 가장 쉬운 방법
        //imagePicker.sourceType = .photoLibrary
        imagePicker.allowsEditing = false // 앱 기능을 확장하고자 할 때 사용
        
    }
    //델리게이트에게 알려주는 델리게이트 메소드 이미지를 고른 시점
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        if let userPickedImage = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
            
            imageView.image = userPickedImage
            
            guard let ciimage = CIImage(image: userPickedImage) else {
                fatalError("Could not convert to CIImage")
            }
            
            detect(image: ciimage)
            
        }
        
        imagePicker.dismiss(animated: true, completion: nil)
        
    }
    
    func detect(image: CIImage) {
        //model은 이미지를 분류하는 데 사용
        guard let model = try? VNCoreMLModel(for: Inceptionv3().model) else {
            fatalError("Loading CoreML Model Failed.")
        }
        
        let request = VNCoreMLRequest(model: model) { (request, error) in
            guard let results = request as? [VNClassificationObservation] else {
                fatalError("Model failed to precess image.")
            }
            
            if let firstResult = results.first {
                if firstResult.identifier.contains("hotdog") {// 만약 첫번째 결과가 hotdog를 포함하고 있다면
                    self.navigationItem.title = "Hotdogs!"
                } else {
                    self.navigationItem.title = "Not Hotdog!"
                }
                }
        }
        
        let handler = VNImageRequestHandler(ciImage: image)
        
        do {
        try handler.perform([request])
        }
        catch {
            print(error)
        }
    }

    @IBAction func cameraTapped(_ sender: UIBarButtonItem) {
        
        present(imagePicker, animated: true, completion: nil)
        
    }
    
}

