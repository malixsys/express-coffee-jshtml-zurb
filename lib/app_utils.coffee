i18n = require("i18n")
cryptos =  require("./cryptos")

i18n_config = { locales: ['fr', 'en'],  extension: '.coffee' }
i18n.configure i18n_config 

i18n.setLocale 'fr'
  
merge = (options, overrides) ->
  extend (extend {}, options), overrides

extend = exports.extend = (object, properties) ->
  for key, val of properties
    object[key] = val
  object

exports.extend = extend
exports.merge = merge
exports.i18n = i18n
exports.say = (word) ->
  if word.indexOf("!") is 0
    return word.substring 1
  i18n.__(word)
  
exports.captcha = cryptos.captcha  

exports.timestring = cryptos.timestring

exports.new_token = cryptos.new_token

LAT_LONG_REGEX =  /^-?[0-9]{1,3}(?:\.[0-9]{1,16})?,-?[0-9]{1,3}(?:\.[0-9]{1,16})?$/i
PHONE_REGEX = /^\+?1?[-\(\.]?(\d{3,3})[-\)\.\s]{0,2}(\d{3,3})[-\.]?(\d{4,4})$/
POSTAL_REGEX = /^([ABCEGHJKLMNPRSTVXY]\d[ABCEGHJKLMNPRSTVWXYZ]) ?(\d[ABCEGHJKLMNPRSTVWXYZ]\d)$/i

exports.extractLatLong = (val) ->
  parts = val.split(",")
  ret =
    __type: 'GeoPoint'
    latitude: parseFloat(parts[0])
    longitude: parseFloat(parts[1])
  return ret


exports.extractPhone = (val) ->
  phone = PHONE_REGEX.exec(val)
  return phone[1] + phone[2] + phone[3]

exports.extractPostalCode = (val) ->
  [postal1,postal2,postal3] = POSTAL_REGEX.exec(val.toUpperCase())
  return "#{postal2} #{postal3}"

exports.getNetworkIPs = (bypassCache,callback) ->
  ignoreRE = /^(127\.0\.0\.1|::1|fe80(:1)?::1(%.*)?)$/i
  exec = require("child_process").exec
  cached = undefined
  command = undefined
  filterRE = undefined

  switch process.platform
    when "win32"

    #case 'win64': // TODO: test
      command = "ipconfig"
      filterRE = /\bIPv[46][^:\r\n]+:\s*([^\s]+)/g
    when "darwin"
      command = "ifconfig"
      filterRE = /\binet\s+([^\s]+)/g

  # filterRE = /\binet6\s+([^\s]+)/g; // IPv6
    else
      command = "ifconfig"
      filterRE = /\binet\b[^:]+:\s*([^\s]+)/g

  # filterRE = /\binet6[^:]+:\s*([^\s]+)/g; // IPv6

  if cached and not bypassCache
    callback null, cached
    return

  # system call
  exec command, (error, stdout, sterr) ->
    cached = []
    ip = undefined
    matches = stdout.match(filterRE) or []

    #if (!error) {
    i = 0

    while i < matches.length
      ip = matches[i].replace(filterRE, "$1")
      cached.push ip  unless ignoreRE.test(ip)
      i++

    #}
    callback error, cached

