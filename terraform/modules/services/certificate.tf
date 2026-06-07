
# mục đích test, cách này không bảo mật.

resource "azurerm_key_vault_certificate" "appgw" {
  name         = "appgw-selfsigned-cert"
  key_vault_id = azurerm_key_vault.main.id

  certificate {
    contents = filebase64("${path.module}/appgw.pfx")
    password = "Azure123456!"
  }

  certificate_policy {
    issuer_parameters {
      name = "Unknown"
    }

    key_properties {
      exportable = true
      key_size   = 2048
      key_type   = "RSA"
      reuse_key  = true
    }

    secret_properties {
      content_type = "application/x-pkcs12"
    }
  }
}

output "ssl_cert_secret_id" {
  value = azurerm_key_vault_certificate.appgw.secret_id
}