//
//  ViewController.swift
//  MediaCaptureDemo
//
//  Created by Rasmus Nielsen on 27/03/2020.
//  Copyright © 2020 Rasmus Nielsen. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UINavigationControllerDelegate, UIImagePickerControllerDelegate {

    @IBOutlet weak var imageView: UIImageView!
    
    @IBOutlet weak var addTextField: UITextField!
    
    // imagePicker helps with the fetching of images from the OS.
    var imagePicker = UIImagePickerController()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        imagePicker.delegate = self
    }
    
    @IBAction func photosButtonPressed(_ sender: UIButton) {
        imagePicker.sourceType = .photoLibrary  // Open the photolibrary
        imagePicker.allowsEditing = true    // Enabling zoom in, when user is picking the image
        present(imagePicker, animated: true, completion:  nil)
    }

    @IBAction func videoButtonPressed(_ sender: UIButton) {
        imagePicker.mediaTypes = ["public.movie"]   // Launch video in camera app
        imagePicker.videoQuality = .typeMedium  // Set the quality of the video
        launchCamera()
    }
    
    fileprivate func launchCamera() {
        imagePicker.sourceType = .camera    // Open up the camera
        imagePicker.showsCameraControls = true  // Enable camera controls
        imagePicker.allowsEditing = true    // Allow editing of the image, resizing.
        present(imagePicker, animated: true, completion: nil)
    }
    
    @IBAction func cameraButtonPressed(_ sender: UIButton) {
        launchCamera()
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        // When done picking image or video, do the following
        if let url = info[.mediaURL] as? URL {  // If video
            if UIVideoAtPathIsCompatibleWithSavedPhotosAlbum(url.path) {
                UISaveVideoAtPathToSavedPhotosAlbum(url.path, nil, nil, nil)    // Save the image
            }
            
        } else {    // If image
            let image = info[UIImagePickerController.InfoKey.editedImage] as? UIImage
            imageView.image = image
        }
        picker.dismiss(animated: true, completion: nil)
    }
    
    var startPoint = CGFloat(0) // will be set, when the touch begins
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let p = touches.first?.location(in: view){
            startPoint = p.x  // register the x-position of finger
            print(startPoint)
        }
    }
    
    // Function that enables the picture to move from side to side when user drags it
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        if let p = touches.first?.location(in: view){
            let diff = p.x - startPoint // calculate the difference between the first touch, and current finger position
            // get the difference of your finger movement
            imageView.transform = CGAffineTransform(translationX: diff, y: 0)
        }
    }
    
    // Function that takes care of what has to be done when the user lets go of the image
    // Either, delete it, save it or reset it to the starting position
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        // when the user lets go of the screen
        if let p = touches.first?.location(in: view){
            let diff = p.x - startPoint // calculate the difference between the first touch, and current finger position
            // get the difference of your finger movement
            imageView.transform = CGAffineTransform(translationX: diff, y: 0)
            // check how far the image has been moved
            if diff < -200 {    // Swiping left to delete
                print("Delete pic")
                // Remove the image from the imageView
                imageView.image = nil
                // Reset image to starting position
                imageView.transform = CGAffineTransform(translationX: 0, y: 0)
            }
            else if diff > 200 {    // Swiping right to save
                print("Save pic")
                // Save the image
                UIImageWriteToSavedPhotosAlbum(imageView.image!, self, #selector(image(_:didFinishSavingWithError:contextInfo:)), nil)
                // Reset image to starting position
                imageView.transform = CGAffineTransform(translationX: 0, y: 0)
            }
            
            // Reset image to starting position if user lets go.
            imageView.transform = CGAffineTransform(translationX: 0, y: 0)
        }
    }
    
    // Helper function to save images to OS
    @objc func image(_ image: UIImage, didFinishSavingWithError error: Error?, contextInfo: UnsafeRawPointer) {
        if let error = error {
            // we got back an error!
            let ac = UIAlertController(title: "Save error", message: error.localizedDescription, preferredStyle: .alert)
            ac.addAction(UIAlertAction(title: "OK", style: .default))
            present(ac, animated: true)
        } else {
            let ac = UIAlertController(title: "Saved!", message: "Your altered image has been saved to your photos.", preferredStyle: .alert)
            ac.addAction(UIAlertAction(title: "OK", style: .default))
            present(ac, animated: true)
        }
    }
    
    @IBAction func addTextButtonPressed(_ sender: UIButton) {
        setTextOnImage(txt: addTextField.text ?? "")
    }
    
    // Function that declares what has to be done, when the user wants to put text on the image
    func setTextOnImage(txt:String) {
        
        // Set color, font and size
        let textColor = UIColor.red
        let textFont = UIFont(name: "Helvetica Bold", size: 36)!

        let scale = UIScreen.main.scale
        UIGraphicsBeginImageContextWithOptions(imageView.image!.size, false, scale)

        let textFontAttributes = [
            NSAttributedString.Key.font: textFont,
            NSAttributedString.Key.foregroundColor: textColor,
            ] as [NSAttributedString.Key : Any]
        imageView.image!.draw(in: CGRect(origin: CGPoint.zero, size: imageView.image!.size))
        
        // Create a space where the text is going to be placed
        let rect = CGRect(origin: CGPoint(x: 20,y: 20), size: imageView.image!.size)
        // put the text inside this space
        txt.draw(in: rect, withAttributes: textFontAttributes)
        
        // Create the new image
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        // Update the imageview with the new image
        imageView.image = newImage
    }
    
}

