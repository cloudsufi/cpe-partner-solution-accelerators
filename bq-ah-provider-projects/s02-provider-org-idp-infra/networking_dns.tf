# Copyright 2024 Google LLC
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     https://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.


resource "google_dns_record_set" "keycloak-address" {
  name = "keycloak.${var.dns_domain_name}."
  type = "A"
  ttl  = 300

  managed_zone = var.dns_zone_name
  project      = "dns-hosting-project-poc"
  rrdatas = [google_compute_global_address.gateway.address]
}

resource "google_certificate_manager_dns_authorization" "managed-zone-wildcard" {
  name        = "managed-zone-wildcard-dns-auth"
  description = "*.${var.base_dns_name} dns auth"
  domain      = var.base_dns_name
}

resource "google_dns_record_set" "acme-challenge" {
  name = try(google_certificate_manager_dns_authorization.managed-zone-wildcard.dns_resource_record[0].name, null)
  type = try(google_certificate_manager_dns_authorization.managed-zone-wildcard.dns_resource_record[0].type, null)
  ttl  = 60

  managed_zone = var.dns_zone_name
  project      = "dns-hosting-project-poc"
  rrdatas = try([google_certificate_manager_dns_authorization.managed-zone-wildcard.dns_resource_record[0].data], null)
  count = try(length(google_certificate_manager_dns_authorization.managed-zone-wildcard.dns_resource_record), 0) > 0 ? 1 : 0
  depends_on = [google_certificate_manager_dns_authorization.managed-zone-wildcard]
}

resource "google_certificate_manager_certificate" "managed-zone-wildcard" {
  name        = "managed-zone-wildcard-cert"
  description = "*.${var.base_dns_name} cert"
  scope       = "DEFAULT"
  labels = {
    env = "test"
  }

  managed {

    domains = [
      var.base_dns_name,
      "*.${var.base_dns_name}",
    ]
    dns_authorizations = [
      google_certificate_manager_dns_authorization.managed-zone-wildcard.id,
    ]
  }

  depends_on = [
    google_certificate_manager_dns_authorization.managed-zone-wildcard,
    google_dns_record_set.acme-challenge
  ]
}

resource "google_certificate_manager_certificate_map" "managed-zone-crt-map" {
  name        = "managed-zone-crt-map"
  description = "managed-zone certificate map"

}

resource "google_certificate_manager_certificate_map_entry" "managed-zone-wildcard-entry" {
  name        = "managed-zone-wildcard-entry"
  description = "managed-zone-wildcard certificate map entry"
  map         = google_certificate_manager_certificate_map.managed-zone-crt-map.name

  certificates = [google_certificate_manager_certificate.managed-zone-wildcard.id]
  matcher      = "PRIMARY"
  depends_on = [google_certificate_manager_certificate.managed-zone-wildcard]
}
