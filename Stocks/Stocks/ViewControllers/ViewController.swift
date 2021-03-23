//
//  ViewController.swift
//  Stocks
//
//  Created by Stepan Ostapenko on 19.03.2021.
//

import UIKit

class ViewController: UIViewController, UIPickerViewDataSource, UIPickerViewDelegate {

    private let companies: [String: String] = ["Apple": "AAPL", "Microsoft": "MSFT", "Google": "GOOG",
                                               "Amazon": "AMZN", "Facebook":  "FB"]
    
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var companyPickerView: UIPickerView!
    @IBOutlet weak var companyNameLabel: UILabel!
    @IBOutlet weak var companySymbolLabel: UILabel!
    @IBOutlet weak var companyPriceSymbol: UILabel!
    @IBOutlet weak var companyPriceChangedLabel: UILabel!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.companyPickerView.dataSource = self
        self.companyPickerView.delegate = self
        self.activityIndicator.hidesWhenStopped  = true
        self.activityIndicator.startAnimating()
        self.requestQuote(for: "AAPL")
        
        self.requestQuoteUpdate()
    }

    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return self.companies.keys.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return Array(self.companies.keys)[row]
    }
    
    private func requestQuote(for symbol: String){
        let url = URL(string: "https://cloud.iexapis.com/stable/stock/\(symbol)/quote?token=sk_4a9ac45eba3d4e6fbf7d3bfe0185cb84")!
        let dataTask = URLSession.shared.dataTask(with: url) { data, response, error in
            guard
                error == nil,
                let data = data
            else{
                print("Network Error")
                return
            }
            
            self.parseQuote(data: data)
        }
        dataTask.resume()
    }
    
    private func displayStockInfo(companyName: String, symbol: String, price: Double, priceChanged: Double){
        self.activityIndicator.stopAnimating()
        self.companyNameLabel.text = companyName
        self.companyPriceSymbol.text = "\(price)"
        self.companySymbolLabel.text = symbol
        self.companyPriceChangedLabel.text = "\(priceChanged)"
    }
    
    private func parseQuote(data: Data){
        do{
            let jsonObject = try JSONSerialization.jsonObject(with: data)
            
            guard
                let json = jsonObject as? [String: Any],
                let companyName = json["companyName"] as? String,
                let companySymbol = json["symbol"] as? String,
                let price = json["latestPrice"] as? Double,
                let priceChange = json["change"] as? Double
            else{
                print("Invalid Json format")
                return
            }
            
            DispatchQueue.main.async {
                self.displayStockInfo(companyName: companyName, symbol: companySymbol, price: price, priceChanged: priceChange)
            }
        }
        catch{
            print("Json parsing error. " + error.localizedDescription)
        }
    }
    
    private func requestQuoteUpdate(){
        self.activityIndicator.startAnimating()
        self.companyNameLabel.text = "-"
        self.companySymbolLabel.text = "-"
        self.companyPriceSymbol.text = "-"
        self.companyPriceChangedLabel.text = "-"
        let selectedRow = self.companyPickerView.selectedRow(inComponent: 0)
        let selectedSymbol = Array(self.companies.values)[selectedRow]
        self.requestQuote(for: selectedSymbol)
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        self.requestQuoteUpdate()
    }
}

