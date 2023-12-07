set_global_assignment -entity "DE10_NANO_QSYS" -library "lib_DE10_NANO_QSYS" -name IP_TOOL_NAME "Qsys"
set_global_assignment -entity "DE10_NANO_QSYS" -library "lib_DE10_NANO_QSYS" -name IP_TOOL_VERSION "22.1"
set_global_assignment -entity "DE10_NANO_QSYS" -library "lib_DE10_NANO_QSYS" -name IP_TOOL_ENV "Qsys"
set_global_assignment -library "lib_DE10_NANO_QSYS" -name SPD_FILE [file join $::quartus(sip_path) "../DE10_NANO_QSYS.spd"]
set_global_assignment -library "lib_DE10_NANO_QSYS" -name MISC_FILE [file join $::quartus(sip_path) "../../DE10_NANO_QSYS.qsys"]

set_global_assignment -library "lib_DE10_NANO_QSYS" -name MISC_FILE [file join $::quartus(sip_path) "DE10_NANO_QSYS.v"]
