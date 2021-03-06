[![Build Status](https://travis-ci.org/allynfolksjr/netid-tools.png)](https://travis-ci.org/allynfolksjr/netid-tools)

NetID Tools
===========

NetID Tools is a Ruby Gem that contains various methods for supporting Uniform Access computing at the University of Washington. These are mainly methods that I've found useful to create during the course of my job, but may be useful to others as well.

Currently the focus is on finding and displaying information on any MySQL database server(s) that users may be running, as well as highlight potential quota issues.

## Installing

	gem install netid-tools

## Usage Notes

* Using keybased SSH authentication is highly recommended, both from your system->UA, and for UA->UA.
** To accomplish this, copy the contents of your ~/.ssh/id_rsa.pub to your ~/.ssh/authorized_keys
* You may need membership of certain Unix Groups in order to run some of these checks.

## Dependencies

* Ruby 1.9
* Nokogiri
* Colored

Executables
===========

`ua_check` is provided as an included executable.

## Example

	nikky@uvb76:~/Repositories/www ☿  on default at tip % ua_check nikky
	Running UA Check for NetID nikky on behalf of nikky

	MySQLd detected on ovid02.u.washington.edu:5280
	/ov03/d20/nikky

	Disk quotas for nikky (uid 247520):
	Filesystem        Usage      Quota      Limit       Grace   Files  Limit
	/cg32a           15.574   5120.000   105120.0                 219  10000
	/da21            17.523   1937.254     5370.0                1535  10000
	etc

Methods
=======

## Netid::validate_netid?(netid) / Netid#validate_netid?(netid)

### What it does

This class method will return a true/false depending on if a given string could potentially be a NetID. It does not check to see if the NetID exists; only if a NetID has a valid structure. Namely:

* 1-8 Characters in length
* First character is *not* a number
* Only a word characters [a-zA-Z0-9]

### Example

	>> require 'netid-tools'
	=> true
	>> Netid.validate_netid?("nikky")
	=> true
	>> Netid.validate_netid?("1nikky")
	=> false
	>> Netid.validate_netid?("1nikky111")
	=> false
	>> Netid.validate_netid?("nikky@1")
	=> false

## Netid#check_for_mysql_presence(host,user,system_user)

### What it does

This class method will check to see if a specific NetID is running a MySQL instance on a specified host. It will return false if no MySQL server is found, and return [host,port] if true.

### Method variables

#### host

The FQDN of the server you want to check for MySQL

#### user

The NetID you want to check

#### system_user

*Your* NetID, required for login to the host.

### Example

	>> Netid.check_for_mysql_presence("ovid02.u.washington.edu","nikky","nikky")
	=> ["ovid02.u.washington.edu", "5280"]

## Netid#check_for_localhome(user,system_user)

### What it does

Checks to see if a user has a localhome, and if they do, return the location.

### Method variables

#### user

The NetID you want to check

#### system_user

*Your* NetID, required for login to the host.

### Example

	>> Netid.check_for_localhome("nikky","nikky")
	=> "/ov03/d20/nikky"

## Netid#check_quota(user,system_user)

### What it does

Spits out various quota information, and highlights a line in red if a user is over quota. This writes directly to stdout.

## Netid#get_processes(host,user,system_user)

### What it does

Retrieves running processes for specified NetID

##Netid#check_webtype(user,system_user)

### What it does

Retrieves webtype(s) for specified NetID

### Method variables

#### user

The NetID you want to check

#### system_user

*Your* NetID, required for login to the host.

Version History
===============

### 0.7.0

* [API] Convert netid-tools to use hash for initialization
* [API] Switch to response objects for all methods
* [Improvement/Experimental] Add ability to pre-load connections. See commit e328e1 for more details


### 0.6.3

* Spec fix

### 0.6.2

* Fix executable

### 0.6.1

* Add TravisCI

### 0.6.0

* Add tests; refactor various methods
* Switch more commands to use Response objects rather than bare responses. Documentation pending.

### 0.5.5

* Switch process listing to individual class

### 0.5.4

* Switch table formatting on ua_check binary

### 0.5.3

* Remove debug function

### 0.5.2

* Expand cluster paths if available in quota output

### 0.5.0

* Switch to new SSH connection method; reuse already existing SSH connection for host if it exists
* Tighten up code
* Fix bugs

### 0.4.2

* Rename check_quota -> quota_check

### 0.4.0

* Switch most methods from Class->Instance

### 0.3.10

* Add -p flag for full process check on hosts.

### 0.3.9

* Add webtype check to list of returned results in ua_check executable
* Add Netid.check_webtype method

### 0.3.8

* Remove ovid21.u.washington.edu from host list; retired system

### 0.3.7

* Allow validate_netid? to return true for NetIDs that have a hyphen in them

### 0.3.6

* Add concise mode via -c flag to ua_check (skips quota results)
* Add OptionParser to ua_check
* Tweak formatting for results
* Allow multiple lookups per execption

### 0.3.3

* Fix broken code so that it properly displays localhome

### 0.3.2

* Added install notes

### 0.3.1

* Initial documented release
* Swich to Apache License

### 0.3.0

Initial release
