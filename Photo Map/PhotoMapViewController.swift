//
//  PhotoMapViewController.swift
//  Photo Map
//
//  Created by Nicholas Aiwazian on 10/15/15.
//  Copyright © 2015 Timothy Lee. All rights reserved.
//

import UIKit
import MapKit

class PhotoMapViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, LocationsViewControllerDelegate, MKMapViewDelegate{
    
    var photo: UIImage?
    var annotations: [PhotoAnnotation] = []

    
    func locationsPickedLocation(controller: LocationsViewController, latitude: NSNumber, longitude: NSNumber) {
        let locationCoordinate = CLLocationCoordinate2D(latitude: CLLocationDegrees(truncating: latitude), longitude: CLLocationDegrees(truncating: longitude))
        
        //let annotation = MKPointAnnotation()
        let annotation = PhotoAnnotation()
        annotation.coordinate = locationCoordinate
        //annotation.title = "Picture!"
        mapView.addAnnotation(annotation)
        
        self.navigationController?.popToViewController(self, animated: true)
    }
    
    func resize(image: UIImage?, newSize: CGSize) -> UIImage? {
        if let image = image{
            let resizeImageView = UIImageView(frame: CGRect(x: 0, y:0, width: newSize.width, height: newSize.height))
            resizeImageView.contentMode = .scaleAspectFill
            resizeImageView.image = image
            
            UIGraphicsBeginImageContext(resizeImageView.frame.size)
            resizeImageView.layer.render(in: UIGraphicsGetCurrentContext()!)
            let newImage = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()
            return newImage
        }
        return nil
    }
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        let reuseID = "myAnnotationView"
        
        var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: reuseID)
        
        if annotationView == nil {
            annotationView = MKAnnotationView(annotation: annotation, reuseIdentifier: reuseID)
            /// show the callout "bubble" when annotation view is selected
            annotationView?.canShowCallout = true
            
            let detailsButton = UIButton(type: UIButtonType.detailDisclosure)
            annotationView?.rightCalloutAccessoryView = detailsButton
        }
        
        let thumbnail = self.resize(image: self.photo, newSize: CGSize(width: 45, height: 45))
        
        annotationView?.image = thumbnail
        
        let imageLeftView = UIImageView(frame: CGRect(x:0, y:0, width:45, height:45))
        imageLeftView.layer.borderColor = UIColor.white.cgColor
        imageLeftView.contentMode = .scaleAspectFill
        imageLeftView.image = (annotation as? PhotoAnnotation)?.photo
        imageLeftView.image = thumbnail
        annotationView?.leftCalloutAccessoryView = imageLeftView

        return annotationView
    }
    

    @IBOutlet weak var mapView: MKMapView! {
        didSet{
            //one degree of latitude is approximately 111 kilometers (69 miles) at all times.
            let sfRegion = MKCoordinateRegionMake(CLLocationCoordinate2DMake(37.783333, -122.416667),
                                                  MKCoordinateSpanMake(0.1, 0.1))
            mapView.setRegion(sfRegion, animated: false)
            mapView.delegate = self
        }
    }
    
    @IBAction func cameraButton(_ sender: Any) {
        let vc = UIImagePickerController()
        vc.delegate = self
        vc.allowsEditing = true
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            print("Camera is available 📸")
            vc.sourceType = .camera
            self.present(vc, animated: true, completion: nil)
        } else {
            print("Camera 🚫 available so we will use photo library instead")
            vc.sourceType = .photoLibrary
            self.present(vc, animated: true, completion: nil)
        }
    }
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func imagePickerController(_ picker: UIImagePickerController,
                               didFinishPickingMediaWithInfo info: [String : Any]) {
        // Get the image captured by the UIImagePickerController
        let originalImage = info[UIImagePickerControllerOriginalImage] as! UIImage
        let editedImage = info[UIImagePickerControllerEditedImage] as! UIImage
        
        // Do something with the images (based on your use case)
        photo = editedImage
        
        // Dismiss UIImagePickerController to go back to your original view controller
        dismiss(animated: true, completion: nil)
        performSegue(withIdentifier: "tagSegue", sender: self)

    }
    
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        performSegue(withIdentifier: "fullImageSegue", sender: self)
    }

    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        if segue.identifier == "tagSegue" {
            let vc: LocationsViewController = segue.destination as! LocationsViewController
            vc.delegate = self
        } else if segue.identifier == "fullImageSegue" {
            let vc: FullImageViewController = segue.destination as! FullImageViewController
            vc.fullImage = photo
        }
    }
    

}
