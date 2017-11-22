//
//  MandrillError.swift
//  MandrillProviderPackageDescription
//
//  Created by Adam Mika on 11/28/17.
//

import Vapor

public enum MandrillError: Error {
    
    public struct ErrorInfo {
        public let status: String
        public let code: Int
        public let name: String
        public let message: String
        
        public init?(json: JSON?) {
            guard let json = json else {
                return nil
            }
            
            do {
                status = try json.get("status")
                code = try json.get("code") as Int
                name = try json.get("name")
                message = try json.get("message")
            } catch {
                return nil
            }
        }
    }
    
    case badRequest(ErrorInfo)
    case unauthorized
    case payloadTooLarge
    case tooManyRequests
    case serverError
    
    // Catch-all error
    case unexpectedServerResponse
}

extension MandrillError: Debuggable {
    
    public var identifier: String {
        switch self {
        case .badRequest: return "badRequest"
        case .unauthorized: return "unauthorized"
        case .payloadTooLarge: return "payloadTooLarge"
        case .tooManyRequests: return "tooManyRequests"
        case .serverError: return "serverError"
        case .unexpectedServerResponse: return "unexpectedServerResponse"
        }
    }
    
    public var reason: String {
        switch self {
        case .badRequest:
            return "There was a problem with your request."
        case .unauthorized:
            return "You do not have authorization to make the request."
        case .payloadTooLarge:
            return "The JSON payload you have included in your request is too large."
        case .tooManyRequests:
            return "The number of requests you have made exceeds Mandrill’s rate limitations."
        case .serverError:
            return "An error occurred on a Mandrill server, or the Mandrill Web API is not available."
        case .unexpectedServerResponse:
            return "The Mandrill API returned an undocumented response."
        }
    }
    
    public var possibleCauses: [String] {
        switch self {
        case .badRequest(let info):
            return ["\(info.name) : \(info.message)"]
        case .unauthorized:
            return ["Your API key may be expired or set incorrectly."]
        case .payloadTooLarge:
            return ["You may be sending too many emails at once."]
        case .tooManyRequests:
            return ["You are making requests too frequently for your plan."]
        case .serverError:
            return ["An internal Mandrill server error occurred."]
        case .unexpectedServerResponse:
            return ["The API may have undergone a breaking change."]
        }
    }
    
    public var suggestedFixes: [String] {
        switch self {
        case .badRequest(let info):
            return ["\(info.name) : \(info.message)"]
        case .unauthorized:
            return ["Check your API key is current in the Mandrill dashboard."]
        case .payloadTooLarge:
            return ["Send several requests with fewer emails in each."]
        case .tooManyRequests:
            return ["Combine multiple emails into a single request."]
        case .serverError:
            return ["Check the Mandrill dashboard for any further information."]
        case .unexpectedServerResponse:
            return ["Check the Mandrill dashboard for any further information."]
        }
    }
    
    public var documentationLinks: [String] {
        return ["https://mandrillapp.com/api/docs/"]
    }
    
}

