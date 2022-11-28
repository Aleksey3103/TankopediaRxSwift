//
//  DetailedViewController.swift
//  NetworkTanks
//
//  Created by Aleksey on 29.12.2021.
//

import UIKit
import Nuke

class DetailedViewController: UIViewController {
    
    @IBOutlet weak var imageDetail: UIImageView!
    var apiClient = RequestManager()
    @IBOutlet weak var descriptionLabel: UILabel!
    
    var imageTank = Images()
    var dataViewModel = TanksViewModel()
    var detailTank = Datum(name: String.init(), images: Images(smallIcon: String.init()), description: String.init())
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        detailInfo()
        imageDetail.layer.cornerRadius = 8
        descriptionLabel.layer.cornerRadius = 8
        self.navigationController?.navigationBar.prefersLargeTitles = true
        self.navigationItem.largeTitleDisplayMode = .automatic
        navigationItem.title = detailTank.name
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        self.view.endEditing(true)
    }
    
    func detailInfo() {
        if let imageUrl = imageTank.imageUrl {
            Nuke.loadImage(with: imageUrl, into: imageDetail.self)
        }
        descriptionLabel.text = detailTank.description
    }
}

