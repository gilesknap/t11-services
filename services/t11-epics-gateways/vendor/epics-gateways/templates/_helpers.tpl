{{- define "allocateIpFromName" -}}
  {{- $name := printf "%s.%s" .name .namespace -}}
  {{- $baseIpParts := split "/" .baseIp -}}
  {{- $baseIp := index $baseIpParts "_0" -}}
  {{- $cidrRange := index $baseIpParts "_1" | int -}}
  {{- $octets := split "." $baseIp -}}
  {{- $firstOctet := index $octets "_0" | int -}}
  {{- $secondOctet := index $octets "_1" | int -}}
  {{- $thirdOctet := index $octets "_2" | int -}}
  {{- $fourthOctet := index $octets "_3" | int -}}
  {{- $totalIps := 1 }}
  {{- range $i, $k := until (sub 32 $cidrRange | int) }}
    {{- $totalIps = mul $totalIps 2 }}
  {{- end }}
  {{- $ipSuffix := add (.startIp | int) (mod (atoi (adler32sum $name)) $totalIps) -}}
  {{- $secondOctet = add $secondOctet (div $ipSuffix 65536) -}}
  {{- $ipSuffix = mod $ipSuffix 65536 -}}
  {{- $thirdOctet = add $thirdOctet (div $ipSuffix 256) -}}
  {{- $fourthOctet = mod $ipSuffix 256 -}}
  {{- if gt $fourthOctet 255 }}
    {{- $fourthOctet = mod $fourthOctet 256 -}}
  {{- end }}
  {{- if gt $thirdOctet 255 }}
    {{- $thirdOctet = mod $thirdOctet 256 -}}
    {{- $secondOctet = add $secondOctet 1 -}}
  {{- end }}
  {{- if gt $secondOctet 255 }}
    {{- $secondOctet = mod $secondOctet 256 -}}
  {{- end }}
  {{- printf "%d.%d.%d.%d" $firstOctet $secondOctet $thirdOctet $fourthOctet -}}
{{- end -}}
