########################################################################################################################
#!!
#! @description: Creates an incident in Service Now.
#!
#! @input description: Incident description
#!
#! @output number: Number of the created incident
#!
#! @result SUCCESS: Flow completed successfully.
#! @result FAILURE: Failure occurred during execution.
#!!#
########################################################################################################################

namespace: io.cloudslang.demo

flow:
  name: reset_ldap_password

  inputs:
    - host : "ldap"
    - root_password: "go.HP.software"
    - ldap_admin_user: "cn=admin, dc=hpswdemo, dc=com"
    - ldap_admin_password: "go.HP.software"
    - user: "hpadmin"
    - new_password: "go.MF.software"

  workflow:
    - reset_password:
        do:
          io.cloudslang.base.ssh.ssh_command:
            - host
            - username: "root"
            - password: ${root_password}
            - command: ${'/usr/bin/ldappasswd -x -h \"' + host + '\" -D \"' + ldap_admin_user + '\" -w \"' + ldap_admin_password + '\" -s \"' + new_password + '\" \"uid=' + user +',ou=Users,dc=hpswdemo,dc=com\"'}
        publish:
          - return_result
          - return_code
          - standard_out
          - standard_err
          - exception
          - command_return_code
  outputs:
    - return_result
    - return_code
    - standard_out
    - standard_err
    - exception
    - command_return_code

  results:
    - SUCCESS
    - FAILURE