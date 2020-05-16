//
//  ViewController.swift
//  PetClassifier
//
//  Created by Saul Rivera on 14/05/20.
//  Copyright © 2020 Saul Rivera. All rights reserved.
//

import UIKit
import CoreML
import Vision

class ViewController: UIViewController {
    
    private let imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.backgroundColor = .blue
        imageView.contentMode = .scaleAspectFill
        return imageView
    }()
    
    private let imagePicker = UIImagePickerController()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.addSubview(imageView)
        
        title = "What pet is it?"
        
        imagePicker.delegate = self
        imagePicker.sourceType = .camera
        imagePicker.allowsEditing = false
        
        imageView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        imageView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        imageView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        imageView.heightAnchor.constraint(equalTo: view.heightAnchor).isActive = true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .camera, target: self, action: #selector(cameraButtonPressed))
    }
    
    @objc private func cameraButtonPressed(_ sender: UIBarButtonItem) {
        present(imagePicker, animated: true, completion: nil)
    }
    
    private func predict(image: CIImage) {
        guard let model = try? VNCoreMLModel(for: PetImageClassifier().model) else {
            fatalError("Model is not loaded")
        }
        
        let request = VNCoreMLRequest(model: model) { (request, error) in
            if let error = error {
                print("Error while processing the request. Error: \(error)")
                return
            }
            
            if let results = request.results as? [VNClassificationObservation] {
                if let firstResult = results.first {
                    DispatchQueue.main.async {
                        self.navigationItem.title = firstResult.identifier.capitalized
                    }
                }
            }
        }
        
        let handler = VNImageRequestHandler(ciImage: image)
        
        do {
            try handler.perform([request])
        } catch {
            print(error)
        }
    }
}

extension ViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let imagePicked = info[.originalImage] as? UIImage {
            guard let ciImagePicked = CIImage(image: imagePicked) else {
                fatalError("No image picked by the user")
            }
            imageView.image = imagePicked
            predict(image: ciImagePicked)
        }
        
        imagePicker.dismiss(animated: true, completion: nil)
    }
}

