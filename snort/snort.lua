-- ============================================================================
-- Minimal Snort 3 configuration (offline PCAP analysis)
-- ============================================================================

-- HOME_NET definition (any network for tutorial purposes)
HOME_NET = 'any'
EXTERNAL_NET = 'any'

-- Include local rules
-- RULE_PATH = './snort/rules'
-- include '/usr/local/etc/snort/snort_defaults.lua'
--include '/media/sf__ISNCODES/snort-nids-tutorial/snort/rules/local.rules' 
-- Enable rule-based detection
ips =
{
  include  = '/media/sf__ISNCODES/snort-nids-tutorial/snort/rules/local.rules'
}

-- Output alerts to console
alert_fast =
{
  file = true
}
