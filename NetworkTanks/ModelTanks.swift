//
//  ModelTanks.swift
//  NetworkTanks
//
//  Created by Aleksey on 27.12.2021.
//

import Foundation

struct ModelTanks: Codable {
    var data: [String: Datum]
}

struct Datum: Codable {
    var name: String
    let images: Images
    var description: String
}

struct Images: Codable {
    var smallIcon, contourIcon, bigIcon: String?
    enum CodingKeys: String, CodingKey {
        case smallIcon = "small_icon"
        case contourIcon = "contour_icon"
        case bigIcon = "big_icon"
    }
}

extension Images {
    var imageUrl: URL? {
        if let posterPath = self.bigIcon {
            return URL(string: posterPath)
        }
        return nil
    }
}
