//
//  Sound.swift
//  sounds_tab
//
//  Created by geu on 27/01/26.
//

import UIKit

struct Sound {
    let title: String
    let category: SoundCategory
    let duration: Int
    let fileName: String
    let imageName: String 
}


enum SoundCategory: String {
    case nature = "Nature"
    case weather = "Weather"
    case ambient = "Ambient"
}
