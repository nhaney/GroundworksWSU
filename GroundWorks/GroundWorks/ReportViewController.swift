//
//  ViewController.swift
//  mapKitTest
//
//  Created by Nigel Haney :-) on 3/8/18.
//  Copyright © 2018 Nigel Haney :-). All rights reserved.
//

import UIKit
import MapKit
import CoreMotion
import CoreLocation
import MessageUI
import AWSAuthCore
import AWSCore
import AWSAPIGateway
import AWSMobileClient
import AWSLambda


class ReportViewController: UIViewController, UITextFieldDelegate, UIGestureRecognizerDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, MFMailComposeViewControllerDelegate{
    
    var selectedLocation = ""
    var dangerLevel = 0
    var imagePicker = UIImagePickerController()
    var hasPicture = false
    
    @IBOutlet weak var locationLabel: UILabel!
    @IBOutlet weak var star1: UIImageView!
    @IBOutlet weak var star2: UIImageView!
    @IBOutlet weak var star3: UIImageView!
    @IBOutlet weak var star4: UIImageView!
    @IBOutlet weak var star5: UIImageView!
    @IBOutlet weak internal var dangerDescription: UILabel!
    
    @IBOutlet weak var descriptionField: UITextField!
    
    @IBOutlet weak var takePhotoButton: UIButton!
    @IBAction func takePhoto(_ sender: Any) {
        imagePicker.sourceType = .camera
        
        present(imagePicker, animated: true, completion: nil)
    }

    @IBAction func sendEmailPressed(_ sender: UIBarButtonItem) {
        //old style
        //sendEmail()
        //new style
        sendEmailHTTPRequest()
    }
    
    //Json struct for sending an email
    struct email: Codable {
        var subject: String
        var htmlBody: String
    }
    
    //Send an email with AWS Lambda
    func sendEmailHTTPRequest() {
        let lambdaInvoker = AWSLambdaInvoker.default()
        
        let jsonObject: [String: Any] = ["subject" : "test subject from Swift",
                                         "html" : "test body from swift"]
        
        lambdaInvoker.invokeFunction("GroundworksWSU-dev-sendEmail", jsonObject: jsonObject).continueWith(block: {(task:AWSTask<AnyObject>) -> Any? in
            
            //something is wrong here, commented out for now. Will need this later
            /*if let error = task.error as NSError? {
                if (error.domain == AWSLambdaInvokerErrorDomain) && (AWSLambdaInvokerErrorType.functionError == AWSLambdaInvokerErrorType(rawValue: error.code) {
                        print("Function error: \(error.userInfo[AWSLambdaInvokerFunctionErrorKey])")
                    } else {
                        print("Error: \(error)")
                    }
                    return nil
            }*/
            
            // Handle response in task.result
            if let JSONDictionary = task.result as? NSDictionary {
                print("Result: \(JSONDictionary)")
                print("resultKey: \(String(describing: JSONDictionary["resultKey"]))")
            }
            return nil
        })
        
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        imagePicker.dismiss(animated: true, completion: nil)
        pictureTaken.image = info["UIImagePickerControllerOriginalImage"] as? UIImage
        hasPicture = true
    }
    
    @IBOutlet weak var pictureTaken: UIImageView!
    
    //text field delegate functions
    func textFieldDidEndEditing(_ textField: UITextField) {
        //checks if user can send email yet
        updateToolBar()
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return false
    }
    
    //gesture delegate functions
    func addGesturesToImageView(_ imageView: UIImageView)
    {
        let TapGestureRecognizer =
            UITapGestureRecognizer(target: self,
                                   action: #selector(handleTap))
        TapGestureRecognizer.delegate = self
        imageView.addGestureRecognizer(TapGestureRecognizer)
        imageView.isUserInteractionEnabled = true
    }
    @objc func handleTap(_ sender: UITapGestureRecognizer)
    {
        if sender.state == .ended
        {
            let point = sender.location(in: self.view)
            let x = Int(point.x)
            let y = Int(point.y)
            print("tap detected at (\(x),\(y))")
            
            if let imageView = sender.view as? UIImageView {
                print("Image Tapped")
                starPower(imageView)
            }
        }
    }
    
    @IBOutlet weak internal var emailStatusLabel: UILabel!
    
    
    //star tapped functionality
    func starPower(_ imageView: UIImageView?)
    {
        let greyName = "snowflakegrey.png"
        let goldName = "snowflakecolor.png"
        if(imageView == star1)
        {
            dangerLevel = 1
            star1.image = UIImage(named: goldName)
            star2.image = UIImage(named: greyName)
            star3.image = UIImage(named: greyName)
            star4.image = UIImage(named: greyName)
            star5.image = UIImage(named: greyName)
            
            updateDangerDescription()
        }
        else if(imageView == star2)
        {
            dangerLevel = 2
            star1.image = UIImage(named: goldName)
            star2.image = UIImage(named: goldName)
            star3.image = UIImage(named: greyName)
            star4.image = UIImage(named: greyName)
            star5.image = UIImage(named: greyName)
            updateDangerDescription()
        }
        else if(imageView == star3)
        {
            dangerLevel = 3
            star1.image = UIImage(named: goldName)
            star2.image = UIImage(named: goldName)
            star3.image = UIImage(named: goldName)
            star4.image = UIImage(named: greyName)
            star5.image = UIImage(named: greyName)
            updateDangerDescription()
        }
        else if(imageView == star4)
        {
            dangerLevel = 4
            star1.image = UIImage(named: goldName)
            star2.image = UIImage(named: goldName)
            star3.image = UIImage(named: goldName)
            star4.image = UIImage(named: goldName)
            star5.image = UIImage(named: greyName)
            updateDangerDescription()
        }
        else if(imageView == star5)
        {
            dangerLevel = 5
            star1.image = UIImage(named: goldName)
            star2.image = UIImage(named: goldName)
            star3.image = UIImage(named: goldName)
            star4.image = UIImage(named: goldName)
            star5.image = UIImage(named: goldName)
            updateDangerDescription()
        }
        else
        {
            dangerLevel = 0
            star1.image = UIImage(named: greyName)
            star2.image = UIImage(named: greyName)
            star3.image = UIImage(named: greyName)
            star4.image = UIImage(named: greyName)
            star5.image = UIImage(named: greyName)
            updateDangerDescription()
        }
    }
    //updates danger Label
    func updateDangerDescription()
    {
        switch dangerLevel {
        case 1:
            dangerDescription.text = "1"
            break
        case 2:
            dangerDescription.text = "2"
            break
        case 3:
            dangerDescription.text = "3"
            break
        case 4:
            dangerDescription.text = "4"
            break
        case 5:
            dangerDescription.text = "5"
            break
        default:
            dangerDescription.text = "Danger Level Not Specified"
        }
        //checks if user can send email yet
        updateToolBar()
    }
    
    //for hiding email button until we are ready
    
    func updateToolBar()
    {
        if(dangerLevel != 0 && descriptionField.text != "" && selectedLocation != "")
        {
            showToolBar()
        }
        else
        {
            hideToolBar()
        }
    }
    
    func hideToolBar()
    {
        if let navigationController = UIApplication.shared.keyWindow?.rootViewController as? UINavigationController {
            navigationController.setToolbarHidden(false, animated: true)
        }
    }
    func showToolBar()
    {
        if(selectedLocation != "")
        {
            if let navigationController = UIApplication.shared.keyWindow?.rootViewController as? UINavigationController {
                navigationController.setToolbarHidden(true, animated: true)
            }
        }
    }
    
    //email stuff
    func sendEmail() {
        var tempMessageBody:String
        if MFMailComposeViewController.canSendMail() {
            let mail = MFMailComposeViewController()
            mail.mailComposeDelegate = self
            mail.setToRecipients(["nigel.haney@wsu.edu"])
            mail.setSubject("\(selectedLocation) - \(Date().description(with: .current))")
            tempMessageBody = "<h1>Location:</h1><p>\(selectedLocation)</p><h1>Danger Level:</h1><p>\(dangerLevel)</p><h1>Description:</h1><p>\(descriptionField.text!)</p>"
            if(hasPicture)
            {
                tempMessageBody = tempMessageBody + "<h1>Photo:<h1>"
                mail.addAttachmentData(UIImageJPEGRepresentation(pictureTaken.image!, CGFloat(1.0))!, mimeType: "image/jpeg", fileName:  "test.jpeg")
            }
            mail.setMessageBody(tempMessageBody, isHTML: true)
            present(mail, animated: true)
        } else {
            // show failure alert
        }
    }
    
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        switch result.rawValue {
        case MFMailComposeResult.cancelled.rawValue :
            self.dismiss(animated: true, completion: nil)
            displayAlertPrompt(error: 2)
            break
        case MFMailComposeResult.failed.rawValue :
            self.dismiss(animated: true, completion: nil)
            displayAlertPrompt(error: 1)
            break
        case MFMailComposeResult.saved.rawValue :
            self.dismiss(animated: true, completion: nil)
            displayAlertPrompt(error: 3)
            break
        case MFMailComposeResult.sent.rawValue :
            self.dismiss(animated: true, completion: nil)
            displayAlertPrompt(error: 0)
        default:
            break
        }
    }
    //notification if email failed
    func displayAlertPrompt(error: Int)
    {
        switch error {
        //not sent
        case 1:
            let alert = UIAlertController(title: "Email Status:",
                                          message: "Email Failed", preferredStyle: .alert)
            
            let cancelAction = UIAlertAction(title: "Continue", style: .cancel, handler: { (action) in
                
            })
            
            alert.addAction(cancelAction)
            alert.preferredAction = cancelAction
            present(alert, animated: true, completion: nil)
            break
        //cancelled
        case 2:
            let alert = UIAlertController(title: "Email Status:",
                                          message: "Email Cancelled", preferredStyle: .alert)
            
            let cancelAction = UIAlertAction(title: "Continue", style: .cancel, handler: { (action) in
                
            })
            
            alert.addAction(cancelAction)
            alert.preferredAction = cancelAction
            present(alert, animated: true, completion: nil)
            break
        //saved
        case 3:
            let alert = UIAlertController(title: "Email Status:",
                                          message: "Email Saved", preferredStyle: .alert)
            
            let cancelAction = UIAlertAction(title: "Continue", style: .cancel, handler: { (action) in
                
            })
            
            alert.addAction(cancelAction)
            alert.preferredAction = cancelAction
            present(alert, animated: true, completion: nil)
            break
        default:
            let alert = UIAlertController(title: "Email Status:",
                                          message: "Email Sent", preferredStyle: .alert)
            
            let cancelAction = UIAlertAction(title: "Continue", style: .cancel, handler: {
                (action) in
                self.toMain()
            })
            alert.addAction(cancelAction)
            alert.preferredAction = cancelAction
            present(alert, animated: true, completion: nil)
            break
        }
    }
    
    func toMain()
    {
        performSegue(withIdentifier: "unwindSegue", sender: nil)
    }
    
    @objc func back(sender: UIBarButtonItem) {
        navigationController?.viewControllers[0].viewDidLoad()
        _ = navigationController?.popViewController(animated: true)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        //navigation bar stuff
        self.navigationController?.presentTransparentNavigationBar()
        navigationItem.title = "Details"
        navigationItem.prompt = ""
        //delegates
        descriptionField.delegate = self
        imagePicker.delegate = self
        hideKeyboardWhenTappedAround()
        
        //star rating
        addGesturesToImageView(star1)
        addGesturesToImageView(star2)
        addGesturesToImageView(star3)
        addGesturesToImageView(star4)
        addGesturesToImageView(star5)
        
        //make custom button for navigation bar
        self.navigationItem.hidesBackButton = true
        let newBackButton = UIBarButtonItem(title: "Back", style: UIBarButtonItemStyle.plain, target: self, action: #selector(self.back(sender:)))
        self.navigationItem.leftBarButtonItem = newBackButton
        
        starPower(nil)
        locationLabel.text = "Location: \(selectedLocation)"
        updateToolBar()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
            //hideToolBar()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}


