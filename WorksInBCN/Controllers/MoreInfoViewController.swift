//
//  MoreInfoViewController.swift
//  WorksInBCN
//
//  Created by Victor Gabriel on 15/7/15.
//  Copyright (c) 2015 Digital Dosis. All rights reserved.
//

import UIKit

class MoreInfoViewController: UIViewController, UIGestureRecognizerDelegate {
    
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var image: UIImageView!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var typeLabel: UILabel!
    @IBOutlet weak var periodLabel: UILabel!
    @IBOutlet weak var statusLabel: UILabel!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var contentView: UIView!
    
    var obraInfo: NSDictionary!;

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let closeButton : UIBarButtonItem = UIBarButtonItem(barButtonSystemItem: .Stop, target: self, action: "closeView")
        closeButton.tintColor = UIColor.blackColor()
        let actionButton : UIBarButtonItem = UIBarButtonItem(barButtonSystemItem: .Action, target: self, action: "shareAction")
        actionButton.tintColor = UIColor.blackColor()
        
        self.navigationItem.setLeftBarButtonItems([closeButton], animated: true)
        self.navigationItem.setRightBarButtonItems([actionButton], animated: true)
        
        self.navigationController?.interactivePopGestureRecognizer!.delegate = self;
        
        self.title = "Informació Detallada"
        
        let leftConstraint = NSLayoutConstraint(item: self.contentView,
                                                attribute: NSLayoutAttribute.Left,
                                                relatedBy: .Equal,
                                                toItem: self.view,
                                                attribute: NSLayoutAttribute.Left,
                                                multiplier: 1.0,
                                                constant: 0.0);
        
        self.view.addConstraint(leftConstraint)
        
        let rightConstraint = NSLayoutConstraint(item: self.contentView,
            attribute: NSLayoutAttribute.Right,
            relatedBy: .Equal,
            toItem: self.view,
            attribute: NSLayoutAttribute.Right,
            multiplier: 1.0,
            constant: 0.0);
        
        self.view.addConstraint(rightConstraint)
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        loadObra()
    }
    
    func loadObra() {
        nameLabel.text = obraInfo.valueForKeyPath("card.title") as? String
        descriptionLabel.text = obraInfo.valueForKeyPath("card.description") as? String
//        typeLabel.text = obraInfo.valueForKeyPath("card.worktype") as? String
//        if ( typeLabel.text == nil) {
//            typeLabel.text = "No hi ha informació";
//        }
        periodLabel.text = obraInfo.valueForKeyPath("card.period") as? String
        statusLabel.text = obraInfo.valueForKeyPath("card.status") as? String
        
        let imgSrc = (((obraInfo.valueForKeyPath("card.address.object") as! NSDictionary)["@attributes"] as! NSDictionary)["src"] as! String)
        loadImage(imgSrc)
    }
    
    func loadImage(urlString:String) {
        
        let imgURL: NSURL = NSURL(string: urlString)!
        let request: NSURLRequest = NSURLRequest(URL: imgURL)
        NSURLConnection.sendAsynchronousRequest(
            request, queue: NSOperationQueue.mainQueue(),
            completionHandler: {(response: NSURLResponse?,data: NSData?,error: NSError?) -> Void in
                if error == nil {
                    self.image.image = UIImage(data: data!)
                }
        })
        
    }
    
    @IBAction func closeView() {
        self.navigationController?.popViewControllerAnimated(true)
    }
    
    @IBAction func shareAction() {
        let sharingText = nameLabel.text as NSString!
        let sharingStuff = [sharingText, image.image as UIImage!]
        
        let activity = UIActivityViewController(activityItems: sharingStuff, applicationActivities: nil)
        
        presentViewController(activity, animated: true, completion: nil)
    }
    
    @IBAction func showImage(sender: AnyObject) {
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let imageView = storyboard.instantiateViewControllerWithIdentifier("ImageView") as! ImageViewController
        
        let imgSrc = (((obraInfo.valueForKeyPath("card.address.object") as! NSDictionary)["@attributes"] as! NSDictionary)["src"] as! String)
        let imgURL: NSURL = NSURL(string: imgSrc)!
        let request: NSURLRequest = NSURLRequest(URL: imgURL)
        NSURLConnection.sendAsynchronousRequest(
            request, queue: NSOperationQueue.mainQueue(),
            completionHandler: {(response: NSURLResponse?,data: NSData?,error: NSError?) -> Void in
                if error == nil {
                    imageView.image.image = UIImage(data: data!)
                }
        })
        
        self.navigationController?.pushViewController(imageView, animated: true)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
