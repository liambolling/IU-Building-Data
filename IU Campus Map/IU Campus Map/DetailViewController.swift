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
        
        var backgroundScrollView = UIScrollView(frame: CGRect(x: 0, y: 0, width: deviceSize.width, height: deviceSize.height))
        backgroundScrollView.delegate = self
        backgroundScrollView.contentSize = CGSize(width: deviceSize.width, height: deviceSize.height + 20)
        self.view.addSubview(backgroundScrollView)
        
        var whiteBackground = UIView(frame: CGRect(x: 0, y: deviceSize.height - 300, width: deviceSize.width, height: 300))
        whiteBackground.backgroundColor = UIColor.white
        backgroundScrollView.addSubview(whiteBackground)
        
        print(self.data)

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func unwindToDetail(segue: UIStoryboardSegue) {
        
    }
    
    func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        let someOffset: CGFloat = 10
        if (targetContentOffset.pointee.y == 0 && scrollView.contentOffset.y < someOffset) {
            self.performSegue(withIdentifier: "leaveDetail1", sender: self)
        }
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
