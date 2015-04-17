class Numeric
	# Degrees to radians.
	def to_rad
		self * Math::PI / 180.0
	end
	# Radians to degrees.
	def to_deg
		self * 180.0 / Math::PI
	end
end

def sunPosition( lat = 46.5, long = 6.5 )
	
	# Latitude [rad]
	lat_rad = lat.to_rad

	# Get Julian date - 2400000
  day = Time.now.gmtime.yday
  hour = Time.now.gmtime.hour + \
         Time.now.gmtime.min/60.0 + \
         Time.now.gmtime.sec/3600.0
  delta = Time.now.gmtime.year - 1949 # => 66
  leap = delta / 4 # => 16
  jd = 32916.5 + delta * 365 + leap + day + hour / 24

  # The input to the Atronomer's almanach is the difference between
  # the Julian date and JD 2451545.0 (noon, 1 January 2000)
  t = jd - 51545

  # Ecliptic coordinates

  # Mean longitude
  mnlong_deg = (280.460 + 0.9856474 * t) % 360

  # Mean anomaly
  mnanom_rad = ( ( 357.528 + 0.9856003 * t ) % 360 ).to_rad

  # Ecliptic longitude and obliquity of ecliptic
  eclong = ( ( mnlong_deg + 
                           1.915 * Math.sin( mnanom_rad ) + 
                           0.020 * Math.sin( 2 * mnanom_rad )
                          ) % 360 ).to_rad
  oblqec_rad = (23.439 - 0.0000004 * t).to_rad

  # Celestial coordinates
  # Right ascension and declination
  num = Math.cos(oblqec_rad) * Math.sin(eclong)
  den = Math.cos(eclong)
  ra_rad = Math.atan(num / den)
	if den < 0 then
		ra_rad = ra_rad + Math::PI
	elsif num < 0
		ra_rad = ra_rad + 2 * Math::PI
	end
  dec_rad = Math.asin( Math.sin( oblqec_rad ) * Math.sin( eclong ) )

  # Local coordinates
  # Greenwich mean sidereal time
  gmst = ( 6.697375 + 0.0657098242 * t + hour ) % 24
  # Local mean sidereal time
  lmst = (gmst + long / 15) % 24
  lmst_rad = (15 * lmst).to_rad

  # Hour angle (rad)
  ha_rad = (lmst_rad - ra_rad) % (2 * Math::PI )

  # Elevation
  el_rad = Math.asin(
      Math.sin( dec_rad ) * Math.sin( lat_rad ) + \
      Math.cos( dec_rad ) * Math.cos( lat_rad ) * Math.cos( ha_rad ) )

  # Azimuth
  az_rad = Math.asin( - Math.cos(dec_rad) * Math.sin(ha_rad) / Math.cos(el_rad) )

	if (Math.sin(dec_rad) - Math.sin(el_rad) * Math.sin(lat_rad) < 0)
		az_rad = Math::PI - az_rad
	elsif ( Math.sin( az_rad ) < 0)
		az_rad += 2 * Math::PI
	end
		
	return [ el_rad, az_rad ]
end

# 47.15155, 9.51240
LAT = 45
LON = 8

alt, azi = sunPosition( LAT, LON )

alt.to_deg # => 30.479972178065108
azi.to_deg  # => 106.98739982916855
