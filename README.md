# check_radius
Monitor a RADIUS server using radclient.

## Setup
You need to have radclient installed, on systems using apt, use:
```
apt install freeradius-utils
```

## Usage
```
Usage: check_radius [OPTIONS]
  [OPTIONS]:
  -H HOST           IP or Hostname
  -S SECRET         Shared Secret
  -W WARNING        Warning threshold in milliseconds (default: 700)
  -C CRITICAL       Critical threshold in milliseconds (default: 2000)
```

## Command Template
```
object CheckCommand "check-radius" {
  command = [ ConfigDir + "/scripts/check_radius.sh" ]
  arguments += {
    "-H" = "$crad_host$"
    "-S" = "$crad_secret$"
  }
}
```

## Example Host Config
```
object Host "Radius Server" {
  check_command = "check-radius"
  vars.crad_host = "172.1.33.7"
  vars.crad_secret = "t0pS3CR3T!"
}
```
