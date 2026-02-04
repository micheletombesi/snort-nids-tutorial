-- ============================================================================
-- Minimal Snort 3 configuration (offline PCAP analysis)
-- ============================================================================

-- HOME_NET definition (any network for tutorial purposes)
HOME_NET = 'any'
EXTERNAL_NET = 'any'

-- Include local rules
RULE_PATH = './snort/rules'
include 'snort_defaults.lua'

-- Enable rule-based detection
ips =
{
  rules = RULE_PATH .. '/local.rules'
}

-- Output alerts to console
alert_fast =
{
  file = true,
  packet = false
}
