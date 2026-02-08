-- ============================================================================
-- Minimal Snort 3 configuration (offline PCAP analysis)
-- ============================================================================

-- HOME_NET definition (any network for tutorial purposes)
HOME_NET = '192.168.10.0/24'
EXTERNAL_NET = 'any'
stream = { }
stream_tcp = {
   policy = 'first',
   session_timeout = 180
}
stream_udp = { }

http_inspect = { }
http_server = { }
http_client = { }


binder = {
   { when = { proto = 'tcp', ports = '80' }, use = { type = 'http_inspect'}},
   { use = { type = 'stream_tcp' }}
}

-- Include local rules
-- RULE_PATH = './snort/rules'
-- include '/usr/local/etc/snort/snort_defaults.lua'
--include '/media/sf__ISNCODES/snort-nids-tutorial/snort/rules/local.rules' 
-- Enable rule-based detection
ips =
{
 -- variables = {
  --  net = {
    --HOME_NET = HOME_NET,
   -- EXTERNAL_NET = EXTERNAL_NET
--    }
--  },
  include  = '/media/sf__ISNCODES/snort-nids-tutorial/snort/rules/local.rules'
}

-- Output alerts to console
alert_fast =
{
  file = true
}

