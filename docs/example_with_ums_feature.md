Overview of UMS feature

The UMS integration enables FortiManager administrators to scale FortiGate-VM instances by adjusting instance-count thresholds. When UMS provisions new instances, FortiManager can automatically onboard
the devices into a specified ADOM, deploy configuration templates, and apply a FortiFlex or BYOL license.

All examples support the UMS feature. To enable it, uncomment any license-related settings and add the fmg_integration block inside the `fortigate_scaleset` section of your `terraform.tfvars` file:

```
fortigate_scaleset = {
  byol = {
    fmg_integration = {
      ip = "<FMG Public IP>"
      sn = "<FMG Serial Number>"
      ums = {
        fmg_register_password = "<Password_for_FGT_register>"
        hb_interval           = 30
        api_key               = "FMG_API_User_Key"
      }
    }
  }
}
```