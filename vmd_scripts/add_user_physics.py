#! /usr/bin/python -E
#
# This program is free software; you can redistribute it and/or
# modify it under the terms of the GNU General Public License as
# published by the Free Software Foundation; version 2 only
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program; if not, write to the Free Software
# Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA 02111-1307 USA
#

import os,sys
try:
    from optparse import OptionParser
    import commands
    import getpass
    import kerberos
    import ldap
    import ldap.modlist
    import shutil
    import random
    import string
except ImportError:
    print >> sys.stderr, "\n Problem importing needed module\n\n %s\n" % (sys.exc_value)
    sys.exit(1)

def secure_password(passwd):
    """ Check if password has sufficient character
        classes to be used as a Kerberos password.
    """
    types = 0
    for letter in string.ascii_lowercase:
        if passwd.find(letter) is not -1:
            types+=1
            break
    for letter in string.ascii_uppercase:
        if passwd.find(letter) is not -1:
            types+=1
            break
    for digit in string.digits:
        if passwd.find(digit) is not -1:
            types+=1
            break
    for symbol in string.punctuation:
        if passwd.find(symbol) is not -1:
            types+=1
            break

    if types>1:
        return True
    else:
        return False

def random_password(length):
    """ Create a random password of 8 characters
        constructed of both numbers and letters.
    """
    # The characters to make up the random password
    chars = string.ascii_letters + string.digits
    #chars = string.ascii_letters + string.digits + string.punctuation

    while True:
        passwd = "".join(random.choice(chars) for x in range(length))
        if secure_password(passwd):
            break
    return passwd

def parse_options():
    usage = "%prog [options] [user]"
    parser = OptionParser(usage=usage)
    parser.add_option("-f", "--firstname", dest="fn",
                      help="User's first name")
    parser.add_option("-l", "--lastname", dest="ln",
                      help="User's last name")
    parser.add_option("-s", "--shell", dest="shell",
                      help="Set user's login shell to shell")
    parser.add_option("-g", "--gidName", dest="gidName",
                      help="Set users primary group id number")
    parser.add_option("-G", "--groups", dest="groups",
                      help="Add user to other groups (comma-separated)")
    parser.add_option("-u", "--username", dest="username",
                      help="Set user's username")
    parser.add_option("-M", "--mailAddress", dest="mail",
                      help="Set user's e-mail address")
    parser.add_option("-q", "--quota", dest="quota",
                      help="User's disk quota")

    options, args = parser.parse_args()

    if len(args) > 1:
        parser.error("too many arguments")

    return options, args

def user_input(prompt, default = None, allow_empty = True):
    """Process and return user input"""
    if default == None:
        while True:
            ret = raw_input("%s: " % prompt)
            if allow_empty or ret.strip():
                return ret
    if isinstance(default, basestring):
        while True:
            ret = raw_input("%s [%s]: " % (prompt, default))
            if not ret and (allow_empty or default):
                return default
            elif ret.strip():
                return ret
    if isinstance(default, bool):
        if default:
            choice = "yes"
        else:
            choice = "no"
        while True:
            ret = raw_input("%s [%s]: " % (prompt, choice))
            if not ret:
                return default
            elif ret.lower()[0] == "y":
                return True
            elif ret.lower()[0] == "n":
                return False
    if isinstance(default, int):
        while True:
            try:
                ret = raw_input("%s [%s]: " % (prompt, default))
                if not ret:
                    return default
                ret = int(ret)
            except ValueError:
                pass
            else:
                return ret

def add_AFS_user(username,quota):
    """Add an AFS user and volume and mount appropriately"""

    uidNumber=0

    ## Create user in AFS database
    status, output = commands.getstatusoutput("/usr/bin/pts createuser %s" % username)
    if status is not 0:
        print "Error creating pts entry: ", str(output)
        return os.EX_USAGE, uidNumber
    else:
        uidNumber=commands.getoutput("/usr/bin/pts listentries | grep -iw %s | awk '{print $2}'" % username)
        print "OpenAFS user %s with uid %s added" % (username,uidNumber)

    ## quota of 1000000 kB should be default, or 1 GB
    status, output = commands.getstatusoutput("/usr/bin/vos create -server fermi.physics.buffalo.edu -partition /vicepa -name user.%s -maxquota %s" % (username, quota) )
    if status is not 0:
        print "Error creating vol entry: ", str(output)
        return os.EX_USAGE, uidNumber

    ## Put volume on mount pt
    try:
        os.mkdir("/afs/physics.buffalo.edu/user/%s" % username[0])
    except OSError:
        pass
    try:
        os.mkdir("/afs/physics.buffalo.edu/user/%s/%s" % (username[0],username[0:2]))
    except OSError:
        pass
    status, output = commands.getstatusoutput("/usr/bin/fs mkmount -dir /afs/.physics.buffalo.edu/user/%s/%s/%s -vol user.%s -rw" % (username[0],username[0:2],username,username))
    if status is not 0:
        print "Error creating mount point:  ", str(output)
        return os.EX_USAGE, uidNumber

    ## Release user
#    status, output = commands.getstatusoutput("/usr/bin/vos release user")
#    if not status == 0:
#        print "Error releasing user:  ", repr(output)
#        rvalue=885

    ## Make backup of directory
#    status, output = commands.getstatusoutput("/usr/bin/fs checkvolumes")
#    status, output = commands.getstatusoutput("/usr/bin/vos backup user.%s" % username)
#    if status is not 0:
#        print "Error making backup: ", repr(output)
#        return os.EX_USAGE

    ## Mount backup in backup volume
#    commands.getstatusoutput("/usr/bin/fs mkm /afs/physics.buffalo.edu/user/%s/%s/%s/.backup user.%s.backup" % (username[0],username[0:2],username,username))
#    #commands.getstatusoutput("/usr/bin/fs mkm /afs/physics.buffalo.edu/backup/user/%s/%s/%s/ user.%s.backup" % (username[0],username[0:2],username,username))
#    commands.getstatusoutput("/usr/bin/vos release bkroot")
#    commands.getstatusoutput("/usr/bin/fs checkvolumes")

    ## Populate user volume
    for file in os.listdir("/etc/skel/"):
        shutil.copy("/etc/skel/"+file, "/afs/physics.buffalo.edu/user/%s/%s/%s/" % (username[0],username[0:2],username))
    os.mkdir("/afs/physics.buffalo.edu/user/%s/%s/%s/Downloads" % (username[0],username[0:2],username))
    os.mkdir("/afs/physics.buffalo.edu/user/%s/%s/%s/Documents" % (username[0],username[0:2],username))
    os.mkdir("/afs/physics.buffalo.edu/user/%s/%s/%s/Desktop" % (username[0],username[0:2],username))
    #os.mkdir("/afs/physics.buffalo.edu/user/%s/%s/%s/Research" % (username[0],username[0:2],username))

    ## Final backup and release
#    commands.getstatusoutput("/usr/bin/vos backup user.%s" % username)
#    commands.getstatusoutput("/usr/bin/vos release bkroot")
    commands.getstatusoutput("/usr/bin/fs checkvolumes")

    ## Check if user has files on dirac
    print 
    print "Don't forget to check if user has files located on dirac.physics.buffalo.edu!!"
    print

    return os.EX_OK, uidNumber                

def add_krbV_user(username,password):
    """Add a Kerberos principal"""

    #adminPW = getpass.getpass("Password for afsadm/admin:  \n")
    #password = getpass.getpass("New password for %s:  \n" % username)
    #status, output = commands.getstatusoutput('/usr/sbin/kadmin.local -p root/admin -w %s -q "addprinc -policy user -pw %s %s"' % (adminPW,password,username))
    status, output = commands.getstatusoutput('/usr/sbin/kadmin.local -q \"add_principal -policy user -pw %s %s\"' % (password,username))
    #status, output = commands.getstatusoutput('/usr/sbin/kadmin -p root/admin -q \"add_principal -policy user -pw %s %s\"' % (password,username))
    if status is not 0:
        print
        print "Error adding kerberos principal!\n", str(output)
        print
        return os.EX_USAGE
    else:
        print
        print "Kerberos principal %s successfully added!" % username
        print "user password: %s" % password
        print
        print "command output: %s" % str(output)
        print
        return os.EX_OK

def add_ldap_user(username,uidNumber,gidNumber,group_list,firstname,lastname,shell,mail):
    """Add an LDAP user"""

    ## get LDAP admin passwd
    ldap_host = 'ldap://fermi.physics.buffalo.edu'
    ldap_base_dn = 'dc=physics,dc=buffalo,dc=edu'
    admin_cred = 'cn=admin,dc=physics,dc=buffalo,dc=edu'
    admin_passwd = getpass.getpass("Enter LDAP admin password: ")

    try:
        l = ldap.initialize(ldap_host)
        l.protocol_version = 3
        ## In case you misspell the password
        while True:
            admin_passwd = getpass.getpass("Enter LDAP admin password: ")
            try:
                l.simple_bind_s(admin_cred, admin_passwd)
                break
            except ldap.INVALID_CREDENTIALS:
                print "Your username or password is incorrect."
            except ldap.LDAPError, e:
                if type(e.message) == dict:
                    for (k, v) in e.message.iteritems():
                        sys.stderr.write("%s: %sn" % (k, v) )
                else:
                    sys.stderr.write(e.message)
                return os.EX_USAGE

        # The dn of our new entry/object
        dn = "uid=%s,ou=People,%s" % (username,ldap_base_dn)

        # A dict to help build the "body" of the object
        attrs = {}
        attrs['objectclass'] = ['top','person','posixAccount']
        attrs['uid'] = '%s' % username
        attrs['cn'] = '%s %s' % (firstname,lastname)
        attrs['sn'] = '%s' % lastname
        attrs['homeDirectory'] = '/afs/physics.buffalo.edu/user/%s/%s/%s' % (username[0],username[0:2],username),
        attrs['loginShell'] = '%s' % shell
        attrs['uidNumber'] = '%s' % uidNumber
        attrs['gidNumber'] = '%s' % gidNumber

        print "Adding user", repr(dn)

        # Convert our dict to nice syntax for the add-function using modlist-module
        ldif = ldap.modlist.addModlist(attrs)
        try:
            l.add_s(dn,ldif)
        except ldap.LDAPError,e:
            print "Error Adding LDAP user: ", str(e)
            return os.EX_USAGE

        for group in group_list:
            try:
                dn = "cn=%s,ou=Group,%s" % (group,ldap_base_dn)
                print "Modifying Group", repr(dn)
                l.modify_s(dn,[(ldap.MOD_ADD, "memberUid", "%s" % username)])
            except ldap.LDAPError,e:
                print 'Error Modifying Group %s' % dn
                print str(e)
    finally:
        try:
            l.unbind_s()
        except:
            pass

    return os.EX_OK

def main():
    """ """
    print
    print "Reminder: This script requires sudo privaledges and the root/admin krbtgt to run."
    print

    options, args = parse_options()

    ## Username
    if not options.username:
        username = user_input("User name", allow_empty = False)
    else:
        username = options.username
    ## Firstname
    if not options.fn:
        firstname = user_input("First name", allow_empty = False)
    else:
        firstname = options.fn
    ## Lastname
    if not options.ln:
        lastname = user_input("Last name", allow_empty = False)
    else:
        lastname = options.ln
    ## Shell
    if not options.shell:
        shell = user_input("User shell", default = "/bin/bash", allow_empty = False)
    else:
        shell = options.shell
    ## gidName
    if not options.gidName:
        gidName = user_input("User primary group", default = "phygrads", allow_empty = False)
    else:
        gidName = options.gidName
    ## Groups
    if not options.groups:
        groups = user_input("Add user to alternate groups (comma-seperated)", allow_empty = True)
    else:
        groups = options.groups
    ## Mail
    if not options.mail:
        mail = user_input("User email address", allow_empty = True)
    else:
        mail = options.mail
    ## Quota
    if not options.quota:
        quota = user_input("User disk quota (in kB)", default = "1000000", allow_empty = False)
    else:
        quota = options.quota

    ## Print user input
    print
    print "You entered the below information"
    print 
    print "username = %s" % (username)
    print "firstname = %s" % (firstname)
    print "lastame = %s" % (lastname)
    print "shell = %s" % (shell)
    print "gidName = %s" % (gidName)
    print "groups = %s" % (groups)
    print "mail = %s" % (mail)
    print "quota = %s kB" % (quota)
    print

    ## Confirm user input
    confirm = raw_input("Is this information correct [Y/n]?: ")
    if confirm.find("y")!=-1:
        if confirm.find("Y") !=-1:
            print username + " not added"
            return os.EX_USAGE
    if confirm.find("n")!=-1 or confirm.find("N")!=-1:
        print username + " not added"
        return os.EX_USAGE

    ## Translate gidName to gidNumber
    gidbook = {'phygrads':10010,'phyfaculty':10011,'phypostdocs':10012,'phystaff':10013,'phyalumni':10014}
    groupbook = {'admin':10001} #,'webadmin':10002,'cluster':10003}

    if not gidbook.has_key(gidName):
        print "ERROR: gidName %s is not an acceptable primary group name.\n" % gidName
        return os.EX_USAGE
    gidNumber = gidbook[gidName]

    group_list = []
    group_list.append( gidName )
    if groups is not "":
        for item in groups.strip().split(','):
            if not groupbook.has_key(item) or not gidbook.has_key(item):
                print "ERROR: group name %s is not an acceptable group name.\n" % item
                return os.EX_USAGE
            gid_list.append( item )

    ## Generate random password
    password = random_password(8)
    print
    print "Random user password: %s" % password
    print

    ## Add Kerberos principal
    rvalue = add_krbV_user(username,password)

    ## Add AFS user
    if rvalue is 0:
        rvalue, uidNumber = add_AFS_user(username,quota)

    ## Add LDAP user
    if rvalue is 0:
        rvalue = add_ldap_user(username,uidNumber,gidNumber,group_list,firstname,lastname,shell,mail)

    if rvalue is 0:
        print username + " successfully added"
        return os.EX_OK
    else:
        print username + " NOT added"
        return os.EX_USAGE

try:
    if __name__ == "__main__":
        sys.exit(main())
except SystemExit, e:
    print
    sys.exit(e)
except KeyboardInterrupt, e:
    print
    sys.exit(1)
except Exception, e:
    print "%s" % str(e)
    sys.exit(1)

