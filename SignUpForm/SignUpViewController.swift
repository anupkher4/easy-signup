//
//  SignUpViewController.swift
//  SignUpForm
//
//  Created by Anup Kher on 7/24/17.
//  Copyright © 2017 amprojects. All rights reserved.
//

import UIKit
import CoreLocation

internal struct AlertMessages {
    static let success: String = "Thanks!"
    static let failure: String = "Error"
}

class SignUpViewController: UIViewController {
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var firstNameTextField: UITextField!
    @IBOutlet weak var lastNameTextField: UITextField!
    @IBOutlet weak var streetTextField: UITextField!
    @IBOutlet weak var cityTextField: UITextField!
    @IBOutlet weak var stateTextField: UITextField!
    @IBOutlet weak var zipTextField: UITextField!
    @IBOutlet weak var signUpButton: UIButton!
    
    var activeTextField: UITextField?
    var initialInsets: UIEdgeInsets!
    
    let locationManager = CLLocationManager()
    let geocoder = CLGeocoder()
    var userLocation: CLLocation?
    
    var userInfo: UserInfo!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.title = "Easy SignUp"
        
        initialInsets = scrollView.contentInset
        
        firstNameTextField.delegate = self
        lastNameTextField.delegate = self
        streetTextField.delegate = self
        cityTextField.delegate = self
        stateTextField.delegate = self
        zipTextField.delegate = self
        
        signUpButton.layer.cornerRadius = 4.0
        
        registerForKeyboardNotifications()
        
        startStandardUpdates()
        locationManager.requestWhenInUseAuthorization()
        
        userInfo = UserInfo()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
//        let fgColor = UIColor(red:0.98, green:0.95, blue:0.75, alpha:1.0)
        let fgColor = UIColor(red:0.97, green:0.98, blue:0.98, alpha:1.0)
        // Background
        navigationController?.navigationBar.barTintColor = UIColor(red:0.75, green:0.43, blue:0.32, alpha:1.0)
        // Tint
        navigationController?.navigationBar.tintColor = fgColor
        navigationController?.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: fgColor]
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func signUpClicked(_ sender: UIButton) {
        if firstNameTextField.text != "" {
            userInfo.firstName = firstNameTextField.text
        }
        if lastNameTextField.text != "" {
            userInfo.lastName = lastNameTextField.text
        }
        if streetTextField.text != "" {
            userInfo.street = streetTextField.text
        }
        
        // Send info to server
        do {
            try userInfo.sendToServer { (result: Any) in
                print("JSON: \(result)")
                showAlert(withTitle: AlertMessages.success, message: "Your information has been saved. Please check the console for details.")
            }
        } catch let error as JSONError {
            switch error {
            case .incompleteInputData:
                showAlert(withTitle: AlertMessages.failure, message: "All fields are required")
            case .serializationError:
                showAlert(withTitle: AlertMessages.failure, message: "Invalid data")
            }
        } catch {
            print("Error")
        }
    }
    
    @IBAction func emptyAreaTapped(_ sender: UITapGestureRecognizer) {
        self.view.endEditing(true)
    }
    
    private func showAlert(withTitle title: String, message: String) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
        alertController.addAction(okAction)
        present(alertController, animated: true) {
            if title == AlertMessages.success {
                self.firstNameTextField.text = ""
                self.lastNameTextField.text = ""
                self.streetTextField.text = ""
            }
        }
    }

}

extension SignUpViewController: UITextFieldDelegate {
    
    // MARK: - UITextFieldDelegate methods
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        activeTextField = textField
    }
    
    func textFieldDidEndEditing(_ textField: UITextField, reason: UITextFieldDidEndEditingReason) {
        activeTextField = nil
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        
        return true
    }
    
    // MARK: - Keyboard Notifications
    
    func registerForKeyboardNotifications() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWasShown(notification:)), name: .UIKeyboardDidShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillBeHidden(notification:)), name: .UIKeyboardWillHide, object: nil)
        
    }
    // Called when the UIKeyboardDidShowNotification is sent
    func keyboardWasShown(notification: Notification) {
        let userInfo = notification.userInfo!
        
        let kbSize: CGSize = (userInfo[UIKeyboardFrameBeginUserInfoKey] as! NSValue).cgRectValue.size
        
        let contentInsets: UIEdgeInsets = UIEdgeInsetsMake(65.0, 0.0, kbSize.height, 0.0)
        scrollView.contentInset = contentInsets
        scrollView.scrollIndicatorInsets = contentInsets
    }
    // Called when the UIKeyboardWillHideNotification is sent
    func keyboardWillBeHidden(notification: Notification) {
        let contentInsets: UIEdgeInsets = UIEdgeInsetsMake(65.0, 0.0, 0.0, 0.0)
        scrollView.contentInset = contentInsets
        scrollView.scrollIndicatorInsets = contentInsets
    }
    
}

extension SignUpViewController: CLLocationManagerDelegate {
    
    func startStandardUpdates() {
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyKilometer
        locationManager.distanceFilter = 500
        locationManager.startUpdatingLocation()
    }
    
    func getAddressInfo(fromLocation location: CLLocation) {
        geocoder.reverseGeocodeLocation(location) { [unowned self] (placemarks: [CLPlacemark]?, error: Error?) in
            if let error = error {
                print("Reverse geocoder error: \(error.localizedDescription)")
            } else if let placemarks = placemarks {
                if placemarks.count > 0 {
                    if let placemark = placemarks.first {
                        self.userInfo.city = placemark.locality
                        self.userInfo.state = placemark.administrativeArea
                        self.userInfo.zip = placemark.postalCode
                        
                        self.updateLabels(info: self.userInfo)
                    }
                }
            }
        }
    }
    
    func updateLabels(info: UserInfo) {
        if let fname = userInfo.firstName {
            firstNameTextField.text = fname
        }
        
        if let lname = userInfo.lastName {
            lastNameTextField.text = lname
        }
        
        if let street = userInfo.street {
            streetTextField.text = street
        }
        
        if let city = userInfo.city {
            cityTextField.text = city
        }
        
        if let state = userInfo.state {
            stateTextField.text = state
        }
        
        if let zip = userInfo.zip {
            zipTextField.text = zip
        }
    }
    
    // MARK: - CLLocationManagerDelegate methods
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let location = locations.last
        let eventDate = location?.timestamp
        let howRecent = (Double)((eventDate?.timeIntervalSinceNow)!)
        
        if howRecent < 15.0 {
            userLocation = location
            getAddressInfo(fromLocation: userLocation!)
        }
    }
    
}
