//
//  WidgetData.swift
//  Bootpay
//
//  Created by Taesup Yoon on 2024/12/10.
//

import Foundation

/// 위젯에서 선택된 결제 정보를 담는 데이터 모델
@objc public class WidgetData: NSObject, Codable {

    @objc public var pg: String?
    @objc public var method: String?
    @objc public var walletId: String?
    @objc public var selectTerms: [WidgetTerm]?
    @objc public var currency: String? // KRW, USD
    @objc public var termPassed: Bool = false
    @objc public var completed: Bool = false
    @objc public var extra: WidgetExtra?

    public override init() {
        super.init()
    }

    enum CodingKeys: String, CodingKey {
        case pg
        case method
        case walletId = "wallet_id"
        case selectTerms = "select_terms"
        case currency
        case termPassed = "term_passed"
        case completed
        case extra
    }

    /// Dictionary에서 WidgetData 생성
    @objc public convenience init?(JSON: [String: Any]) {
        self.init()

        self.pg = JSON["pg"] as? String
        self.method = JSON["method"] as? String
        self.walletId = JSON["wallet_id"] as? String
        self.currency = JSON["currency"] as? String
        self.termPassed = JSON["term_passed"] as? Bool ?? false
        self.completed = JSON["completed"] as? Bool ?? false

        if let termsArray = JSON["select_terms"] as? [[String: Any]] {
            self.selectTerms = termsArray.compactMap { WidgetTerm(JSON: $0) }
        }

        if let extraData = JSON["extra"] as? [String: Any] {
            self.extra = WidgetExtra(JSON: extraData)
        }
    }

    @objc public func toJSON() -> [String: Any] {
        var result: [String: Any] = [:]

        if let pg = pg { result["pg"] = pg }
        if let method = method { result["method"] = method }
        if let walletId = walletId { result["wallet_id"] = walletId }
        if let currency = currency { result["currency"] = currency }
        result["term_passed"] = termPassed
        result["completed"] = completed

        if let selectTerms = selectTerms {
            result["select_terms"] = selectTerms.map { $0.toJSON() }
        }

        if let extra = extra {
            result["extra"] = extra.toJSON()
        }

        return result
    }
}

/// 위젯에서 선택된 약관 정보
@objc public class WidgetTerm: NSObject, Codable {

    @objc public var termId: String?
    @objc public var pk: String?
    @objc public var title: String?
    @objc public var agree: Bool = false
    @objc public var termType: Int = 0

    public override init() {
        super.init()
    }

    enum CodingKeys: String, CodingKey {
        case termId = "term_id"
        case pk
        case title
        case agree
        case termType = "term_type"
    }

    @objc public convenience init?(JSON: [String: Any]) {
        self.init()

        self.termId = JSON["term_id"] as? String
        self.pk = JSON["pk"] as? String
        self.title = JSON["title"] as? String
        self.agree = JSON["agree"] as? Bool ?? false
        self.termType = JSON["term_type"] as? Int ?? 0
    }

    @objc public func toJSON() -> [String: Any] {
        var result: [String: Any] = [:]

        if let termId = termId { result["term_id"] = termId }
        if let pk = pk { result["pk"] = pk }
        if let title = title { result["title"] = title }
        result["agree"] = agree
        result["term_type"] = termType

        return result
    }
}

/// 위젯 추가 설정 정보
@objc public class WidgetExtra: NSObject, Codable {

    @objc public var directCardCompany: String?
    @objc public var directCardQuota: Int = 0
    @objc public var cardQuota: Int = 0

    public override init() {
        super.init()
        self.directCardCompany = "-1"
    }

    enum CodingKeys: String, CodingKey {
        case directCardCompany = "direct_card_company"
        case directCardQuota = "direct_card_quota"
        case cardQuota = "card_quota"
    }

    @objc public convenience init?(JSON: [String: Any]) {
        self.init()

        self.directCardCompany = JSON["direct_card_company"] as? String ?? "-1"
        self.directCardQuota = JSON["direct_card_quota"] as? Int ?? 0
        self.cardQuota = JSON["card_quota"] as? Int ?? 0
    }

    @objc public func toJSON() -> [String: Any] {
        return [
            "direct_card_company": directCardCompany ?? "-1",
            "direct_card_quota": directCardQuota,
            "card_quota": cardQuota
        ]
    }
}
