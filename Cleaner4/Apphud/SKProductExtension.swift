import StoreKit

extension SKProduct {
    func getProductDuration() -> String {
        var unit = ""
        switch self.subscriptionPeriod?.unit {
        case .day:
            unit = "Weekly"
        case .week:
            unit = "Weekly"
        case .month:
            unit = "Monthly"
        case .year:
            unit = "Yearly"
        default:
            unit = "Weekly"
        }
        return unit
    }
    
    func getProductDurationTypeAndUnit() -> String {
        var unit = ""
        switch self.subscriptionPeriod?.unit {
        case .day:
            unit = "Weekly"
        case .week:
            unit = "Weekly"
        case .month:
            unit = "Monthly"
        case .year:
            unit = "Yearly"
        default:
            unit = "Weekly"
        }
        if self.subscriptionPeriod?.unit == .month {
            return "\((self.subscriptionPeriod?.numberOfUnits ?? 0) > 1 ? "\(self.subscriptionPeriod?.numberOfUnits ?? 0) " : "")" + unit + ((self.subscriptionPeriod?.numberOfUnits ?? 0) > 1 ? "s" : "")
        } else {
            return unit
        }
    }
    
    func getProductPrice() -> String {
        let numberFormatter = NumberFormatter()
        numberFormatter.numberStyle = .currency
        numberFormatter.locale = priceLocale
        numberFormatter.currencyCode = priceLocale.currencyCode
        numberFormatter.currencySymbol = priceLocale.currencySymbol
        let priceString = numberFormatter.string(from: price)
        return priceString ?? ""
    }
    
    func getProductWeeklyPrice() -> String {
        let numberFormatter = NumberFormatter()
        numberFormatter.numberStyle = .currency
        numberFormatter.locale = priceLocale
        numberFormatter.currencyCode = priceLocale.currencyCode
        numberFormatter.currencySymbol = priceLocale.currencySymbol
        var divideBy: NSDecimalNumber = 1
        let u = Double(subscriptionPeriod?.numberOfUnits ?? 1)
        switch self.subscriptionPeriod?.unit {
        case .day:
            divideBy = 1
        case .month:
            divideBy = NSDecimalNumber(decimal: Decimal(Double(4.28 * u)))
        case .year:
            divideBy = NSDecimalNumber(decimal: Decimal(Double(4.28 * 12 * u)))
        default:
            divideBy = NSDecimalNumber(decimal:Decimal(Double(1 * u)))
        }
        
        let weeklyPrice = price.dividing(by: divideBy)
        
        let priceString = numberFormatter.string(from: weeklyPrice)
        return priceString ?? ""
    }
    
    private func unitStringFrom(unitValue: SKProduct.PeriodUnit) -> String {
        var unit = ""
        switch unitValue {
        case .day:
            unit = "Weekly"
        case .week:
            unit = "Weekly"
        case .month:
            unit = "Monthly"
        case .year:
            unit = "Yearly"
        default:
            break
        }
        return unit
    }
    
    func getUnit() -> String {
        var unit = ""
        switch self.subscriptionPeriod!.unit {
        case .day:
            unit = "Weekly"
        case .week:
            unit = "Weekly"
        case .month:
            unit = "Monthly"
        case .year:
            unit = "Yearly"
        default:
            break
        }
        return unit
    }
    
    private func localizedPriceFrom(price: NSDecimalNumber) -> String {
        let numberFormatter = NumberFormatter()
        numberFormatter.numberStyle = .currency
        numberFormatter.locale = priceLocale
        numberFormatter.currencyCode = priceLocale.currencyCode
        numberFormatter.currencySymbol = priceLocale.currencySymbol
        let priceString = numberFormatter.string(from: price)
        return priceString ?? ""
    }
}

