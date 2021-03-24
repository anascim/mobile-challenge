//
//  ConversionsViewModel.swift
//  CurrencyConverterBTG
//
//  Created by Alex Nascimento on 23/03/21.
//

import Foundation

class ConversionsViewModel {
    
    var conversions: [Conversion]?
    
    static private let originDefaultText = "Choose a currency to convert from"
    static private let destinyDefaultText = "Choose a currency to convert to"

    private var validatedAmount: Box<Double?> = Box(nil)
    var originCurrency: Box<Currency?> = Box(nil)
    var destinyCurrency: Box<Currency?> = Box(nil)
    
    var resultText: Box<String?> = Box(nil)
    var originText: Box<String> = Box(ConversionsViewModel.originDefaultText)
    var destinyText: Box<String> = Box(ConversionsViewModel.destinyDefaultText)
    
    
    weak var viewController: ConversionsViewController?
    
    init() {
        fetchConversions()
        
        originCurrency.bind { [unowned self] currency in
            if let currency = currency {
                self.originText.value = currency.code
                tryCalculation()
            } else {
                self.originText.value = ConversionsViewModel.originDefaultText
            }
        }
        
        destinyCurrency.bind { [unowned self] currency in
            if let currency = currency {
                self.destinyText.value = currency.code
                tryCalculation()
            } else {
                self.destinyText.value = ConversionsViewModel.destinyDefaultText
            }
        }
    }
    
    func didUpdateTextField(with text: String?) {
        if let text = text {
            if let amount = Double(text) {
                validatedAmount.value = amount
                tryCalculation()
            }
        } else {
            validatedAmount.value = nil
        }
    }
    
    private func tryCalculation() {
        if let origin = originCurrency.value,
           let destiny = destinyCurrency.value,
           let amount = validatedAmount.value {
            CurrencyLayerAPI.shared.fetchConversions { [unowned self] conversions in
                if let conversions = conversions {
                    self.conversions = conversions
                    
                    guard let oneDolarInOriginCurrency = conversions.filter({ conversion in
                        conversion.code == "USD" + origin.code
                    }).first?.value else {
                        Debugger.warning("No conversion found")
                        self.resultText.value = "Error"
                        return
                    }
                    
                    guard let oneDolarInDestinyCurrency = conversions.filter({ conversion in
                        conversion.code == "USD" + destiny.code
                    }).first?.value else {
                        Debugger.warning("No conversion found")
                        self.resultText.value = "Error"
                        return
                    }
                    
                    let result = (oneDolarInDestinyCurrency / oneDolarInOriginCurrency) * amount
                    resultText.value = String(result)
                }
            }
        }
    }
    
    private func fetchConversions() {
        CurrencyLayerAPI.shared.fetchConversions { [unowned self] conversions in
            if let conversions = conversions {
                self.conversions = conversions
            }
        }
    }
}
