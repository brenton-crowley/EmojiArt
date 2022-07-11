//
//  UtilityViews.swift
//  EmojiArt
//
//  Created by Brent on 11/7/2022.
//

import SwiftUI

struct OptionalImage: View {
    var uiImage: UIImage?
    
    var body: some View {
        if uiImage != nil {
            Image(uiImage: uiImage!)
        }
    }
}
