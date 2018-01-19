//
//  DiscoverViewController.swift
//  Traily3
//
//  Created by Andy Kwong on 1/18/18.
//  Copyright © 2018 Andy Kwong. All rights reserved.
//

import UIKit

class DiscoverViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationController?.navigationBar.barStyle = UIBarStyle.black // I then set the color using:
        
        self.navigationController?.navigationBar.barTintColor = UIColor(red: 65/255, green: 187/255, blue: 2/255, alpha: 0.5) // a lovely red
        
        self.navigationController?.navigationBar.tintColor = .white // for titles, buttons, etc.
        
        let navigationTitleFont = UIFont(name: "Avenir", size: 20)!
        
        self.navigationController?.navigationBar.titleTextAttributes = [NSAttributedStringKey.font: navigationTitleFont]

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
