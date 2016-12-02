//
//  DetailViewController.swift
//  IU Campus Map
//
//  Created by Liam Bolling on 11/27/16.
//
//

import UIKit

class DetailViewController: UIViewController, UIScrollViewDelegate {

    var data: NSDictionary = [:]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = UIColor.clear
        
        let backgroundScrollView = UIScrollView(frame: CGRect(x: 0, y: 0, width: deviceSize.width, height: deviceSize.height))
        backgroundScrollView.delegate = self
        backgroundScrollView.contentSize = CGSize(width: deviceSize.width, height: deviceSize.height + 1)
        self.view.addSubview(backgroundScrollView)
        
        
        let backgroundExitButton = UIButton()
        backgroundExitButton.addTarget(self, action:#selector(DetailViewController.unwindView(sender:)), for:.touchUpInside)
        backgroundExitButton.frame = CGRect(x: 0, y: 0, width: deviceSize.width, height: deviceSize.height)
        backgroundScrollView.addSubview(backgroundExitButton)
        
        
        var whiteBackground = UIView(frame: CGRect(x: 0, y: deviceSize.height - 175, width: deviceSize.width, height: 175))
        whiteBackground.backgroundColor = UIColor.white
        whiteBackground.layer.cornerRadius = 6.0
        backgroundScrollView.addSubview(whiteBackground)
        

        var nameTextField = UILabel()
        nameTextField.text = self.data.value(forKey: "name") as! String?
        nameTextField.frame = CGRect(x: 15, y: 15, width: deviceSize.width - 30, height: 26)
        nameTextField.font = nameTextField.font.withSize(24)
        nameTextField.textColor = IUColors.crimson
        whiteBackground.addSubview(nameTextField)
        
        var codeText = self.data.value(forKey: "code") as! String
        var metaText = ""
        
        if codeText == "" {
            metaText = (self.data.value(forKey: "category") as! String).uppercased()
        }else{
            metaText = codeText
            metaText += " • "+(self.data.value(forKey: "category") as! String).uppercased()
        }
        
        var metaTextField = UILabel()
        metaTextField.text = metaText
        metaTextField.frame = CGRect(x: 15, y: 47, width: deviceSize.width - 30, height: 18)
        metaTextField.font = metaTextField.font.withSize(14)
        metaTextField.textColor = IUColors.grey
        whiteBackground.addSubview(metaTextField)
        
        var lineSplit = UIView()
        lineSplit.frame = CGRect(x: 15, y: 85, width: deviceSize.width - 30, height: 1)
        lineSplit.backgroundColor = IUColors.lightGrey
        whiteBackground.addSubview(lineSplit)
        
    
        createTransportOptions(whiteBackground: whiteBackground)

    }
    
    
    
    
    func createTransportOptions(whiteBackground: UIView){
        

        var walking_container = UIView()
        walking_container.frame = CGRect(x: 15, y: 110, width: 50, height: 50)
        whiteBackground.addSubview(walking_container)
        
        var walking_icon = UIImageView(image: UIImage(named: "walking_icon"))
        walking_icon.contentMode = .scaleAspectFit
        walking_icon.frame = CGRect(x: 0, y: 0, width: 50, height: 30)
        walking_container.addSubview(walking_icon)
        
        var walking_eta = UILabel()
        walking_eta.frame = CGRect(x: 0, y: 30, width: 50, height: 18)
        walking_eta.textAlignment = .center
        walking_eta.text = "17 MIN"
        walking_eta.textColor = IUColors.grey
        walking_eta.font = walking_eta.font.withSize(11)
        walking_container.addSubview(walking_eta)

        
        
        var running_container = UIView()
        running_container.frame = CGRect(x: 90, y: 110, width: 50, height: 50)
        whiteBackground.addSubview(running_container)
        
        var running_icon = UIImageView(image: UIImage(named: "running_icon"))
        running_icon.contentMode = .scaleAspectFit
        running_icon.frame = CGRect(x: 0, y: 0, width: 50, height: 30)
        running_container.addSubview(running_icon)
        
        var running_eta = UILabel()
        running_eta.frame = CGRect(x: 0, y: 30, width: 50, height: 18)
        running_eta.textAlignment = .center
        running_eta.text = "9 MIN"
        running_eta.textColor = IUColors.grey
        running_eta.font = running_eta.font.withSize(11)
        running_container.addSubview(running_eta)
        
        
        
        var driving_container = UIView()
        driving_container.frame = CGRect(x: 165, y: 110, width: 50, height: 50)
        whiteBackground.addSubview(driving_container)
        
        var driving_icon = UIImageView(image: UIImage(named: "car_icon"))
        driving_icon.contentMode = .scaleAspectFit
        driving_icon.frame = CGRect(x: 8, y: 0, width: 36, height: 30)
        driving_container.addSubview(driving_icon)
        
        var driving_eta = UILabel()
        driving_eta.frame = CGRect(x: 0, y: 30, width: 50, height: 18)
        driving_eta.textAlignment = .center
        driving_eta.text = "45 MIN"
        driving_eta.textColor = IUColors.grey
        driving_eta.font = driving_eta.font.withSize(11)
        driving_container.addSubview(driving_eta)
    }
    
    
    


    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    func unwindView(sender: AnyObject){
        self.performSegue(withIdentifier: "DetailToMapUnwind", sender: self)
    }
    
    func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        let someOffset: CGFloat = 10
        if (targetContentOffset.pointee.y == 0 && scrollView.contentOffset.y < someOffset) {
            self.performSegue(withIdentifier: "DetailToMapUnwind", sender: self)
        }
    }

    /*
    // MARK: - Navigation

     
     let springAnimation = POPSpringAnimation(propertyNamed: kPOPViewFrame)
     springAnimation.toValue =  NSValue(CGRect: CGRect(x: 0, y: sectionContainerYPosition, width: deviceSize.width, height: self.sectionsContainerHeight))
     springAnimation.springBounciness = 1.0
     self.sectionsContainer.pop_addAnimation(springAnimation, forKey: "springAnimation")
     
     let springAnimation2 = POPSpringAnimation(propertyNamed: kPOPViewFrame)
     springAnimation2.toValue = NSValue(CGRect: CGRect(x:20, y: self.descriptionHeight, width: deviceSize.width - 40, height: 90))
     springAnimation2.springBounciness = 1.0
     self.descriptionSection.pop_addAnimation(springAnimation2, forKey: "springAnimation2")
     
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
