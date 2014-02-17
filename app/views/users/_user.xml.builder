xml.admin user.admin?, type: "boolean"
xml.tag! "avatar-url", user.avatar_url
xml.tag! "created-at", user.created_at.xmlschema, type: "datetime"
xml.tag! "email-address", user.email_address
xml.id user.id, type: "integer"
xml.name user.name
xml.type "Member"
