//
//  CardViewController.swift
//  PullUpView
//
//  Created by Mihai A Ruber on 4/4/19.
//  Copyright © 2019 Mihai A Ruber. All rights reserved.
//

import UIKit

class CardViewController: UIViewController {

    //MARK: - Properties
    
    @IBOutlet weak var handleArea: UIView! {
        didSet {
            self.handleArea.backgroundColor = UIColor.lightGray
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

  

}
