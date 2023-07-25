//
//  ViewController.swift
//  TheArcXPtv
//
//  Created by Cassandra Balbuena on 8/25/22.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }

    override func viewWillAppear(_ animated: Bool) {
        let label = UILabel(frame: CGRect(x: 0, y: 0, width: 1000, height: 200))
        label.center = CGPoint(x: view.center.x, y: view.center.y)
        label.text = "Hello World!"
        label.numberOfLines = 0
        label.textAlignment = .center
        view.addSubview(label)
    }
}
