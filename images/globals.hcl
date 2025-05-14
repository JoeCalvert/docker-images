# --- PUBLISHING

variable "REGISTRY" {
  description = "The Docker registry to push to."
  default     = "ghcr.io/joecalvert"
}

variable "REPO" {
  description = "The repository URL"
  default     = "https://github.com/JoeCalvert/docker-images"
}

# --- TOOLING

variable "GO_VERSION" {
  description = "The version of Go to use."
  default = "1.24.3"
}

# --- IMAGES

variable "BASE_IMAGE" {
  description = "The base image to use"
  default     = "ubuntu:22.04"
}