//
//  ActivityIndicator.swift
//  NetworkTanks
//
//  Created by Aleksey on 12.12.2022.
//

import MBProgressHUD

extension UIViewController {
   func showIndicator(withTitle title: String, and Description:String) {
      let indicator = MBProgressHUD.showAdded(to: self.view, animated: true)
       indicator.bezelView.color = .clear
       indicator.bezelView.layer.cornerRadius = 5
       indicator.label.text = title
       indicator.isUserInteractionEnabled = false
       indicator.detailsLabel.text = Description
       indicator.show(animated: true)
      self.view.isUserInteractionEnabled = false
   }
   func hideIndicator() {
      MBProgressHUD.hide(for: self.view, animated: true)
      self.view.isUserInteractionEnabled = true
   }
}
