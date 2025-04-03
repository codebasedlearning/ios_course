//
//  CommonViews.swift
//  A_Sensors
//
//  Created by Alexander Voss on 22.05.24.
//

import SwiftUI

struct HeaderText: View {
    let text: String
    var opacity = 0.8
    var body: some View {
        Text(text).font(.title2).frame(maxWidth: .infinity).background(.orange.opacity(opacity))
    }
}
