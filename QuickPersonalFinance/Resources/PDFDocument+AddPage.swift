//
//  PDFDocument+AddPage.swift
//  QuickPersonalFinance
//
//  Created by Armando Brito on 12/5/23.
//

import PDFKit

/// Reference: https://stackoverflow.com/a/63174853/5691990
extension PDFDocument {
    func addPages(from document: PDFDocument) {
        let pageCountAddition = document.pageCount

        for pageIndex in 0..<pageCountAddition {
            guard let addPage = document.page(at: pageIndex) else {
                break
            }

            self.insert(addPage, at: self.pageCount)
        }
    }
}
