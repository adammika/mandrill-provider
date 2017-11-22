import HTTP
import SMTP
import Vapor
import Foundation

//MARK: Mandrill
public final class Mandrill: MailProtocol {
    public let clientFactory: ClientFactoryProtocol
    public let apiKey: String
    
    public init(_ clientFactory: ClientFactoryProtocol, apiKey: String) throws {
        self.apiKey = apiKey
        self.clientFactory = clientFactory
    }
}

//MARK: Sending Emails

extension Mandrill {
    public func send(_ emails: [Email]) throws {
        try emails.forEach(_send)
    }
    
    private func _send(_ mail: Email) throws {
        let req = Request(method: .post, uri: "https://mandrillapp.com/api/1.0/messages/send.json")
        
        var json = JSON()
        try json.set("key", apiKey)
        try json.set("message", _message(mail))
        
        req.body = try Body(json)
        let response = try clientFactory.respond(to: req)
        
        let successRange = 200...299
        if !successRange.contains(response.status.statusCode) {
            if let errorInfo = MandrillError.ErrorInfo(json: response.json) {
                throw MandrillError.badRequest(errorInfo)
            } else {
                switch response.status.statusCode {
                case 401:
                    throw MandrillError.unauthorized
                case 413:
                    throw MandrillError.payloadTooLarge
                case 429:
                    throw MandrillError.tooManyRequests
                case 500...599:
                    throw MandrillError.serverError
                default:
                    throw MandrillError.unexpectedServerResponse
                }
            }
        }
    }
    
    private func _message(_ mail: Email) -> [String : Any] {
        var message: [String: Any] = ["subject" : mail.subject,
                                      "from_email" : mail.from.address,
                                      "to" : mail.to.map{ ["email" : $0.address] }]
        
        switch (mail.body.type) {
        case .html:
            message["html"] = mail.body.content
        case .plain:
            message["text"] = mail.body.content
        }
        
        if !mail.attachments.isEmpty {
            let attachments = mail.attachments.map {
                return ["type" : $0.emailAttachment.contentType,
                        "name" : $0.emailAttachment.filename,
                        "content" : String(bytes: $0.emailAttachment.body.base64Encoded)]
            }
            
            message["attachments"] = attachments
        }
        
        return message
    }
}

extension Mandrill: ConfigInitializable {
    public convenience init(config: Config) throws {
        guard let mandrill = config["mandrill"] else {
            throw ConfigError.missingFile("mandrill")
        }
        guard let apiKey = mandrill["apiKey"]?.string else {
            throw ConfigError.missing(key: ["apiKey"], file: "mandrill", desiredType: String.self)
        }
        let client = try config.resolveClient()
        try self.init(client, apiKey: apiKey)
    }
}

