//
//  EstimateView.swift
//  QuickPersonalFinance
//
//  Created by Armando Brito on 9/3/23.
//

import SwiftUI

struct EstimateView: View {
    @EnvironmentObject private var mainData: AppData
    @StateObject private var viewModel = ViewModel()

    var body: some View {
        VStack {
            HStack {
                Text("Estimate: ")
                Text(String(format: "%.2f", viewModel.balance))
            }
        }
        .onAppear {
            viewModel.mainData = mainData
            viewModel.update()
        }
    }
}

struct EstimateView_Previews: PreviewProvider {
    static var previews: some View {
        EstimateView()
    }
}
