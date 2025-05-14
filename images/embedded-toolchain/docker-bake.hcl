# ---------------  GLOBAL VARS  ------------------
#         Overridden by images/globals.hcl

variable "REGISTRY" {
  description = "The Docker registry to push to."
}

variable "REPO" {
  description = "The repository URL"
}

variable "GO_VERSION" {
  description = "The version of Go to use."
}

variable "BASE_IMAGE" {
  description = "The base image to use"
}

# ------------------ PUBLISHING -------------------

variable "TAG" {
  description = "An additional tag to use for the images."
}

# ------------------ VERSIONS ---------------------
# ESP IDF 
variable "ESP_IDF_VERSION" {
  description = "The version of ESP-IDF to use."
  default     = "v5.4.1"
}

# NRF Connect SDK
variable "NRF_CONNECT_SDK_VERSION" {
  description = "The version of NRF Connect SDK to use."
  default     = "v3.0.1"
}

variable "JLINK_TOOLS_VERSION" {
  description = "The version of SEGGER J-Link tools to use."
  default     = "V818"
}

variable "NRF_UDEV_VERSION" {
  description = "The version of nrf-udev to use."
  default     = "1.0.1"
}

# -------------------------------------------------

group "default" {
  targets = [
    "esp-idf",
    "nrf-connect"
    ]
}

target "esp-idf" {
  context    = "./esp-idf"
  dockerfile = "Dockerfile"
  tags       = [
    "${REGISTRY}/esp-idf:${ESP_IDF_VERSION}",
    notequal("",TAG) ? "${REGISTRY}/esp-idf:${TAG}" : ""
  ]
  description = "Build and flash applications for Espressif ESP32 devices"
  args = {
    GO_VERSION = "${GO_VERSION}"
    ESP_IDF_VERSION = "${ESP_IDF_VERSION}"
  }
  platforms = [
    "linux/amd64",
    "linux/arm64"
  ]
  labels = {
    "org.opencontainers.image.source" = "${REPO}"
  }
  output = [
    {
      type = "registry",
      name = "${REGISTRY}/esp-idf:${ESP_IDF_VERSION}",
      push = true
    }
  ]
  cache_from = [
    {
      type = "registry",
      ref = "${REGISTRY}/esp-idf:buildcache-${ESP_IDF_VERSION}",
    }
  ]
  cache_to   = [
    {
      type = "registry",
      ref = "${REGISTRY}/esp-idf:buildcache-${ESP_IDF_VERSION}",
      mode = "max"
    }
  ]
}

# The nRF Connect SDK is only available for linux/amd64
target "nrf-connect" {
  context    = "./nrf-connect"
  dockerfile = "Dockerfile"
  tags       = [
    "${REGISTRY}/nrf-connect:${NRF_CONNECT_SDK_VERSION}",
    notequal("",TAG) ? "${REGISTRY}/nrf-connect:${TAG}" : "",
    ]
  description = "Build and flash applications for Nordic nRF devices"
  args = {
    GO_VERSION = "${GO_VERSION}"
    BASE_IMAGE             = "${BASE_IMAGE}"
    NRF_CONNECT_SDK_VERSION = "${NRF_CONNECT_SDK_VERSION}"
    NRF_UDEV_VERSION       = "${NRF_UDEV_VERSION}"
    JLINK_TOOLS_VERSION = "${JLINK_TOOLS_VERSION}"
  }
  platforms = [
    "linux/amd64",
  ] # nrftool is only available for linux/amd64
  labels = {
    "org.opencontainers.image.source" = "${REPO}"
  }
  output = [
    {
      type = "registry",
      name = "${REGISTRY}/nrf-connect:${NRF_CONNECT_SDK_VERSION}",
      push = true
    }
  ]
  cache_from = [
    {
      type = "registry",
      ref = "${REGISTRY}/nrf-connect:buildcache-${NRF_CONNECT_SDK_VERSION}",
    }
  ]
  cache_to   = [
    {
      type = "registry",
      ref = "${REGISTRY}/nrf-connect:buildcache-${NRF_CONNECT_SDK_VERSION}"
    }
  ]
}
