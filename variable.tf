variable "vm_configurations" {
  type = list(object({
    name         = string
    vm_id        = number
    disk_size_gb = number
    memory       = number
    cores        = number
  }))

  default = [
    {
      name         = "vanilla-control-plane-1"
      vm_id        = "101" 
      disk_size_gb = "20"
      memory       = "4094"
      cores        = "2"
    },
    {
      name         = "vanilla-control-plane-2"
      vm_id        = "102"
      disk_size_gb = "20"
      memory       = "4094"
      cores        = "2"
    },
    {
      name         = "vanilla-control-plane-3"
      vm_id        = "103"
      disk_size_gb = "20"
      memory       = "4094"
      cores        = "2"
    },
    {
      name         = "vanilla-worker-1"
      vm_id        = "104"
      disk_size_gb = "20"
      memory       = "4094"
      cores        = "2"
    },
    {
      name         = "vanilla-worker-2"
      vm_id        = "105"
      disk_size_gb = "20"
      memory       = "4094"
      cores        = "2"
    },
    {
      name         = "vanilla-worker-3"
      vm_id        = "106"
      disk_size_gb = "20"
      memory       = "4094"
      cores        = "2"
    },
    {
      name         = "vanilla-haproxy-1"
      vm_id        = "107"
      disk_size_gb = "20"
      memory       = "4094"
      cores        = "2"
    },
    {
      name         = "vanilla-haproxy-2"
      vm_id        = "108"
      disk_size_gb = "20"
      memory       = "4094"
      cores        = "2"
    }
  ]
}
