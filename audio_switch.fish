#!/usr/bin/env fish

set device_nick 'HD-Audio Generic'
set headphones 'analog-output-headphones'
set speakers 'analog-output-lineout'

set basic_preset 'Basic preset'
set eq_correction_preset 'Speaker EQ correction'

function main
    set device_dump (pw-dump | jq -c ".[] | select(.info.props.\"device.nick\" == \"$device_nick\")")

    set device_id (echo "$device_dump" | jq ".id")
    set current_port (echo "$device_dump" | jq -r ".info.params.Route[].name")
    set current_device (echo "$device_dump" | jq ".info.params.Route[].device")

    if test "$current_port" = "$headphones"
        set next_port "$speakers"
        set ee_preset "$eq_correction_preset"
    else
        set next_port "$headphones"
        set ee_preset "$basic_preset"
    end

    set next_port_id (echo "$device_dump" | jq ".info.params.EnumRoute[] | select(.name == \"$next_port\") | .index")

    pw-cli set-param "$device_id" Route "{\"index\": $next_port_id, \"device\": $current_device}" > /dev/null
    easyeffects --load-preset "$ee_preset"
end

main
