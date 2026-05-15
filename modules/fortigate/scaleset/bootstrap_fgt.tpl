Content-Type: multipart/mixed; boundary="===============0086047718136476635=="
MIME-Version: 1.0

--===============0086047718136476635==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment; filename="preconfig"

## This is an example of FortiGate configuration. The following configuration is necessary for the Terraform examples, but users can assign different values for them and add additional settings as needed.

## In this design, Port1 acts as the public port for internet communication, while Port2 functions as the private port for communication with internal load balancers. Users can adjust these settings to suit your project needs.

config system sdn-connector
	edit AzureSDN
		set type azure
	end
end

config vpn ssl settings
    set port 7443
end

config sys global
    set hostname "fgtvmss"
    set admin-sport 443
end

config system interface
    edit ${coalesce(public_interface_name, "port1")}
        set alias public
        set allowaccess ping https ssh probe-response
    next
end

config system interface
    edit ${coalesce(private_interface_name, "port2")}
        set alias private
        set allowaccess probe-response
        set description "Provider"
        set defaultgw disable
        set mtu-override enable
        set mtu 1570
    next
end

config router static
    edit 0
        set distance 5
        set dst 168.63.129.16 255.255.255.255
        set gateway ${private_interface_gateway_ip_address}
        set device ${coalesce(private_interface_name, "port2")}
    next
    edit 0
        set dst 0.0.0.0/0
        set gateway ${public_interface_gateway_ip_address}
        set device ${coalesce(public_interface_name, "port1")}
    next
    edit 0
        set distance 5
        set dst 168.63.129.16 255.255.255.255
        set gateway ${public_interface_gateway_ip_address}
        set device ${coalesce(public_interface_name, "port1")}
    next
end

config system probe-response
    set port 8008
    set http-probe-value "OK"
    set mode http-probe
end

%{ if fmg_integration != null ~}
config system central-management
    set type fortimanager
    set fmg ${fmg_integration.ip}
    set serial-number ${fmg_integration.sn}
end

%{ if fmg_integration.ums != null ~}
config system auto-scale
    set status enable
    set sync-interface port1
    set hb-interval ${fmg_integration.ums.hb_interval}
    set role primary
    set callback-url ${fmg_integration.ip}
    set cloud-mode ums
    set psksecret ${fortigate_autoscale_psksecret}
end
%{ endif ~}
%{ endif ~}

%{ if gwlb_frontend_ip_address != "" ~}
config system vxlan
    edit "extvxlan"
        set interface ${coalesce(private_interface_name, "port2")}
        set vni 801
        set dstport 2001
        set remote-ip ${gwlb_frontend_ip_address}
    next
    edit "intvxlan"
        set interface ${coalesce(private_interface_name, "port2")}
        set vni 800
        set dstport 2000
        set remote-ip ${gwlb_frontend_ip_address}
    next
end

config system switch-interface
    edit int-ext-vxlan
        set vdom root
        set member intvxlan extvxlan
        set intra-switch-policy explicit
    next
end

config firewall policy
    edit 0
        set name "int-ext_vxlan"
        set srcintf "intvxlan" "extvxlan"
        set dstintf "intvxlan" "extvxlan"
        set action accept
        set srcaddr "all"
        set dstaddr "all"
        set schedule "always"
        set service "ALL"
        set utm-status enable
        set ssl-ssh-profile "certificate-inspection"
        set ips-sensor "default"
        set logtraffic all
    next
end

config system settings
    set asymroute enable
end
%{ endif ~}

## start custom config
${custom_config}


--===============0086047718136476635==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment; filename="license"

LICENSE-TOKEN:DUMMY


--===============0086047718136476635==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment; filename="postconfig"

%{ if fmg_integration != null ~}
%{ if fmg_integration.ums != null ~}
%{ if license_type == "payg" ~}
exec central-mgmt register-device ${fmg_integration.sn} ${fmg_integration.ums.fmg_register_password}
%{ else ~}
%{ if try(tonumber(split(".", trimspace(tostring(image_version)))[0]), 0) >= 8 ~}
exec central-mgmt register-device-by-address ${fmg_integration.ip} ${fmg_integration.ums.api_key}
%{ else ~}
exec central-mgmt register-device-by-ip ${fmg_integration.ip} ${fmg_integration.ums.api_key}
%{ endif ~}
exec update-now
%{ endif ~}
%{ endif ~}
%{ endif ~}

--===============0086047718136476635==--
