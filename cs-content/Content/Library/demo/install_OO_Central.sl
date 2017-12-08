########################################################################################################################
#!!
#! @description: Deploys a machine in AWS EC2; prepares the environment, installs OO Central, keeps it running
#!               for some time and then deprovisions the machine
#!
#! @result SUCCESS: Flow completed successfully.
#! @result FAILURE: Failure occurred during execution.
#!!#
########################################################################################################################

namespace: io.cloudslang.demo
imports:
  base: io.cloudslang.base
  ec2: io.cloudslang.amazon.aws.ec2
flow:
    name: install_OO_Central

    inputs:
      - identity
      - credential
      - image_id: 'ami-55ef662f'  # amazon linux us-east-1c
      - instance_type: 't2.small'  # at least 2 GBs RAM is necessary
      - value_tags_string: 'type_your_name_oo_demo_presenter'
      - security_group: 'sg-f2c11c87'  # allows SSH and HTTPS traffic
      - key_pair_name: 'oo-demo-key-pair'
      - instance_name_prefix: 'Provisioned by OO demo; contact PP '
      - repo_path: '/C:/Dev/local-file-repository/'  # local repo containing the installer binary file, the installer property file and the private key file
      - installer_file: 'installer-linux64.bin'
      - private_key_file: ${repo_path + 'oo-demo-key-pair.ppk'}
      - properties_file: 'silent.properties'
      - username: 'ec2-user'
      - proxy_host: 'proxy.hpswdemoportal.com'
      - proxy_port: '8088'
      - oo_central_to_live_seconds: '600'

    workflow:
      - deploy_instance:
          do:
            ec2.deploy_instance:
              - identity
              - credential
              - image_id
              - instance_type
              - availability_zone: 'us-east-1c'  # N.Virginia
              - key_tags_string: 'owner'
              - value_tags_string
              - security_group_ids_string: ${security_group}
              - key_pair_name
              - instance_name_prefix
          publish:
            - instance_id
            - ip_address
            - return_result
            - return_code
            - exception
          navigate:
            - SUCCESS: let_instance_initialize
            - FAILURE: FAILURE
      - let_instance_initialize:
          do:
            base.utils.sleep:
              - seconds: '20'
          navigate:
            - SUCCESS: copy_installation_file
            - FAILURE: FAILURE
      - copy_installation_file:
          do:
            base.remote_file_transfer.remote_secure_copy:
              - source_path: ${repo_path + installer_file}
              - destination_host: ${ip_address}
              - destination_path: ${'/home/'+username}
              - destination_username: ${username}
              - destination_private_key_file: ${private_key_file}
              - proxy_host
              - proxy_port
              - timeout: '300000'   # give it 5 mins to complete
          publish:
              - return_result
          navigate:
            - SUCCESS: copy_properties_file
            - FAILURE: FAILURE
      - copy_properties_file:
          do:
            base.remote_file_transfer.remote_secure_copy:
              - source_path: ${repo_path + properties_file}
              - destination_host: ${ip_address}
              - destination_path: ${'/home/'+username}
              - destination_username: ${username}
              - destination_private_key_file: ${private_key_file}
              - proxy_host
              - proxy_port
          publish:
              - return_result
          navigate:
            - SUCCESS: make_binaries_executable
            - FAILURE: FAILURE
      - make_binaries_executable:
          do:
            base.ssh.ssh_command:
              - host: ${ip_address}
              - username
              - private_key_file
              - proxy_host
              - proxy_port
              - command: ${'sudo chmod 755 /home/' + username + '/' + installer_file}
          publish:
              - return_result
              - standard_out
              - standard_err
          navigate:
            - SUCCESS: install_java
            - FAILURE: FAILURE
      - install_java:
          do:
            base.ssh.ssh_command:
              - host: ${ip_address}
              - username
              - private_key_file
              - proxy_host
              - proxy_port
              - command: ${'sudo yum -y install java'}
          publish:
              - return_result
              - standard_out
              - standard_err
          navigate:
            - SUCCESS: install_bzip2
            - FAILURE: FAILURE
      - install_bzip2:
          do:
            base.ssh.ssh_command:
              - host: ${ip_address}
              - username
              - private_key_file
              - proxy_host
              - proxy_port
              - timeout: '300000'   # give it 5 mins to complete installation
              - command: ${'sudo yum -y install bzip2'}
          publish:
              - return_result
              - standard_out
              - standard_err
          navigate:
            - SUCCESS: install_oo
            - FAILURE: FAILURE
      - install_oo:
          do:
            base.ssh.ssh_command:
              - host: ${ip_address}
              - username
              - private_key_file
              - proxy_host
              - proxy_port
              - ip_address          # to calculate url string
              - timeout: '300000'   # give it 5 mins to complete installation
              - command: ${'sudo ./' + installer_file + ' -s ' + properties_file}
          publish:
              - return_result
              - standard_out
              - standard_err
              - url: "${'https://' + ip_address + '/oo'}"
          navigate:
            - SUCCESS: echo_url
            - FAILURE: FAILURE
      - echo_url:
          do:
            base.print.print_text:
              - text: ${'For the next '+oo_central_to_live_seconds+' seconds, OO Central is running at '+ url}
          navigate:
            - SUCCESS: let_central_run
      - let_central_run:
          do:
            base.utils.sleep:
              - seconds: ${oo_central_to_live_seconds}
          navigate:
            - SUCCESS: deprovision
            - FAILURE: FAILURE
      - deprovision:
          do:
            ec2.undeploy_instance:
              - identity
              - credential
              - instance_id
          publish:
            - return_result
            - return_code
            - exception
          navigate:
            - SUCCESS: SUCCESS
            - FAILURE: FAILURE

    outputs:
        - instance_id
        - ip_address
        - exception
        - url

    results:
      - SUCCESS
      - FAILURE